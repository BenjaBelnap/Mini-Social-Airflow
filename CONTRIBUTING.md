# Contributing to Mini-Social-Airflow

## Development Workflow

We follow a feature branch workflow with comprehensive data pipeline validation and testing.

### Branch Strategy

- `main` - Production-ready code, protected branch
- `develop` - Integration branch for features (optional)
- `feature/*` - Feature development branches
- `fix/*` - Bug fix branches
- `chore/*` - Maintenance and tooling updates

### Creating a Feature

1. **Create a branch from main:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Follow TDD practices:**
   - Write failing tests first (Red)
   - Implement minimal code to pass (Green)  
   - Refactor and improve (Refactor)

3. **Commit frequently with semantic messages:**
   ```bash
   git commit -m "feat(pipeline): add MongoDB to PostgreSQL data transformation"
   git commit -m "test: add data validation tests for posts migration"
   git commit -m "fix(db): handle missing content_vector field in posts table"
   ```

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

**Types:**
- `feat` - New features
- `fix` - Bug fixes
- `docs` - Documentation updates
- `test` - Adding or updating tests
- `refactor` - Code refactoring
- `chore` - Maintenance tasks
- `ci` - CI/CD updates

**Scopes:**
- `pipeline` - Airflow DAGs and data pipeline logic
- `db` - Database migrations and setup
- `transform` - Data transformation scripts
- `infrastructure` - Docker, environment setup
- `tests` - Test-related changes

### Pull Request Process

1. **Ensure all tests pass:**
   ```bash
   pytest tests/
   ```

2. **Validate data pipeline:**
   ```bash
   # Test database setup
   cd db/setup && ./setup-db.ps1
   
   # Validate Airflow DAGs
   airflow dags test
   ```

3. **Run data quality checks:**
   ```bash
   # Validate data transformations
   python -m pytest tests/test_data_quality.py
   ```

4. **Push your branch:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create PR with descriptive title and description**

6. **GitHub Actions will automatically:**
   - Run all tests
   - Validate Airflow DAGs
   - Check data pipeline integrity
   - Validate database migrations
   - Generate data quality reports

### Code Quality Standards

- **Test Coverage:** Maintain high test coverage for data transformations (aim for >90%)
- **Data Quality:** Validate data integrity and transformations
- **Documentation:** Update README and pipeline documentation as needed
- **Security:** Secure database credentials and API keys
- **Performance:** Monitor pipeline execution times and resource usage

### Local Development

```bash
# Setup database environment
cd db/setup && ./setup-db.ps1

# Install Python dependencies
pip install -r requirements.txt

# Run Airflow locally
airflow webserver --port 8080
airflow scheduler

# Test data transformations
python -m pytest tests/

# Validate specific pipeline
airflow dags test mini_social_pipeline 2025-01-01
```

### Database Development

```bash
# Create new migration
cd db/flyway
# Create V{version}__description.sql file

# Apply migrations
cd ../setup && ./setup-db.ps1

# Test migration rollback (if supported)
flyway undo
```

### Environment Setup

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Update credentials in .env file**

3. **Start services:**
   ```bash
   cd db/setup && docker-compose up -d
   ```

## Data Pipeline Guidelines

- **Idempotency:** Ensure pipeline tasks can be safely re-run
- **Monitoring:** Add logging and metrics to all pipeline steps
- **Error Handling:** Implement robust error handling and retry logic
- **Data Validation:** Validate data at each transformation step
- **Documentation:** Document data lineage and transformation logic

## Questions?

Feel free to open an issue for questions about the development process or data pipeline architecture.
