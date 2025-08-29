

# Load environment variables from .env file
$envFile = "..\..\\.env"
if (Test-Path $envFile) {
    Write-Host "Loading environment variables from .env file..."
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
} else {
    Write-Host "Warning: .env file not found at $envFile"
    Write-Host "Please ensure the .env file exists in the project root with POSTGRES_* variables"
    exit 1
}

# Ensure Flyway is installed
if (-not (Get-Command flyway -ErrorAction SilentlyContinue)) {
    Write-Host "Flyway not found. Installing via Chocolatey..."
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Please install Chocolatey first."
        exit 1
    }
    choco install flyway -y
}

# Check if Postgres container is already running
$existingContainer = docker ps --filter "name=postgres" --format "table {{.Names}}" | Select-String "postgres"
if ($existingContainer) {
    Write-Host "Postgres container is already running."
} else {
    # Start Postgres via Docker Compose
    Write-Host "Starting Postgres via Docker Compose..."
    docker-compose up -d
}

# Wait for Postgres to be ready
Write-Host "Waiting for Postgres to be ready..."
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    try {
        # Use docker logs to check if postgres is ready
        $logs = docker logs setup-postgres-1 2>&1 | Select-String "database system is ready to accept connections"
        if ($logs) {
            Write-Host "Postgres is ready!"
            break
        }
    } catch {
        # Ignore errors and continue trying
    }
    Write-Host "Attempt $($attempt + 1)/$maxAttempts - waiting for Postgres..."
    Start-Sleep -Seconds 3
    $attempt++
}
if ($attempt -eq $maxAttempts) {
    Write-Host "Postgres did not become ready in time."
    Write-Host "Container logs:"
    docker logs setup-postgres-1
    exit 1
}

# Run Flyway migrations
Write-Host "Running Flyway migrations..."
flyway -url="jdbc:postgresql://localhost:5432/$env:POSTGRES_DB" -user="$env:POSTGRES_USER" -password="$env:POSTGRES_PASSWORD" -locations="filesystem:..\flyway" migrate

Write-Host "Setup complete."
