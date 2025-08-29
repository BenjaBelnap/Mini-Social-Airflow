# Mini-Social-Airflow

A horizontally scalable, modular data pipeline using Apache Airflow to move data from MongoDB posts collection to PostgreSQL vector table for content analysis and semantic search.

## 🎯 Project Overview

This project implements a modern ETL pipeline that:
- Extracts posts from MongoDB with incremental loading
- Transforms content into vector embeddings for semantic analysis
- Loads data into PostgreSQL with pgvector for efficient similarity search
- Provides horizontal scalability through distributed task execution
- Maintains modularity for easy component replacement and testing

## 🏗️ Architecture

```
MongoDB (posts) → Apache Airflow → PostgreSQL (vector table)
     ↓              ↓                    ↓
 Source Data    Orchestration        Destination
 - Posts        - DAGs              - Vectors
 - Content      - Tasks             - Embeddings
 - Metadata     - Scheduling        - Search Index
```

### Core Components

- **Source**: MongoDB posts collection with schema validation
- **Orchestration**: Apache Airflow with CeleryExecutor/KubernetesExecutor
- **Destination**: PostgreSQL with pgvector extension for vector operations
- **Scalability**: Distributed task execution and batch processing
- **Modularity**: Decoupled ETL components with reusable operators

## 🚀 Pipeline Steps

### 1. Extraction
- **Operator**: Custom MongoHook/PythonOperator
- **Strategy**: Incremental loading using timestamps or MongoDB change streams
- **Features**: 
  - Configurable batch sizes for parallel processing
  - Connection pooling for high throughput
  - Error handling and retry logic

### 2. Transformation
- **Operator**: PythonOperator with embedding models
- **Features**:
  - Content preprocessing and cleaning
  - Vector embedding generation (OpenAI, HuggingFace, or local models)
  - Modular embedding logic for easy model swapping
  - Batch processing for efficiency

### 3. Loading
- **Operator**: PostgresOperator/Custom PythonOperator
- **Features**:
  - Bulk inserts with upsert capabilities
  - Idempotency guarantees
  - Vector index optimization
  - Data validation and quality checks

## 🔧 Setup and Installation

### Prerequisites
- Docker and Docker Compose
- Python 3.8+
- Apache Airflow 2.0+
- MongoDB instance
- PostgreSQL with pgvector extension

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/BenjaBelnap/Mini-Social-Airflow.git
   cd Mini-Social-Airflow
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. **Initialize the database:**
   ```bash
   cd db/setup
   ./setup-db.ps1
   ```

4. **Start Airflow:**
   ```bash
   # Install dependencies
   pip install -r requirements.txt
   
   # Initialize Airflow
   airflow db init
   
   # Start services
   airflow webserver --port 8080
   airflow scheduler
   ```

5. **Access the Airflow UI:**
   Navigate to `http://localhost:8080`

## 📋 DAG Architecture

### Main Pipeline DAG
```python
posts_etl_dag = DAG(
    'posts_mongodb_to_postgres',
    schedule_interval='@hourly',
    catchup=False
)

# Extraction Task
extract_posts >> 

# Transformation Tasks (parallel)
[clean_content, generate_embeddings] >> 

# Loading Task
load_to_postgres >> 

# Validation Task
validate_data_quality
```

### Task Dependencies
- **extract_posts**: Incremental extraction from MongoDB
- **clean_content**: Text preprocessing and validation
- **generate_embeddings**: Vector embedding generation
- **load_to_postgres**: Bulk insert with upserts
- **validate_data_quality**: Data integrity checks

## 🔄 Horizontal Scalability

### Executor Configuration
- **CeleryExecutor**: Redis/RabbitMQ backend for distributed workers
- **KubernetesExecutor**: Container-based scaling on Kubernetes
- **LocalExecutor**: Development and testing (single machine)

### Scaling Strategies
- **Batch Processing**: Configurable chunk sizes for parallel execution
- **Worker Pools**: Dedicated workers for different task types
- **Resource Management**: CPU/memory limits per task
- **Auto-scaling**: Dynamic worker scaling based on queue depth

## 🧩 Modularity & Configuration

### Custom Operators
- `MongoExtractOperator`: Reusable MongoDB extraction logic
- `EmbeddingTransformOperator`: Pluggable embedding models
- `VectorLoadOperator`: PostgreSQL vector operations

### Configuration Management
- **Airflow Variables**: Pipeline parameters and batch sizes
- **Connections**: Database and service credentials
- **Secrets Backend**: Secure credential management
- **Environment Files**: Local development configuration

## 📊 Monitoring & Observability

### Built-in Monitoring
- Airflow Web UI dashboard
- Task execution logs and metrics
- Data lineage visualization
- Alert configuration for failures

### Data Quality
- Schema validation tasks
- Data freshness checks
- Vector embedding quality metrics
- Anomaly detection

### Performance Metrics
- Pipeline execution time
- Throughput monitoring
- Resource utilization
- Error rates and retry patterns

## 🗄️ Database Schema

### MongoDB Source (posts collection)
```javascript
{
  id: String,
  userId: String,
  content: String (1-1000 chars),
  createdAt: Date,
  updatedAt: Date
}
```

### PostgreSQL Destination (posts table)
```sql
CREATE TABLE posts (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    content VARCHAR(1000) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    content_vector tsvector,
    embedding_vector vector(1536)  -- pgvector extension
);
```

## 🧪 Testing

### Unit Tests
```bash
pytest tests/unit/
```

### Integration Tests
```bash
pytest tests/integration/
```

### DAG Validation
```bash
airflow dags test posts_mongodb_to_postgres 2025-01-01
```

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our development workflow, coding standards, and pull request process.

### Development Workflow
1. Create feature branch: `git checkout -b feature/your-feature`
2. Follow TDD practices with comprehensive testing
3. Use semantic commit messages
4. Submit PR with detailed description

## 📚 Documentation

- [Pipeline Architecture](docs/architecture.md)
- [Operator Development](docs/operators.md)
- [Deployment Guide](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🔒 Security

- Secure credential management through Airflow Secrets Backend
- Network isolation for database connections
- Input validation and SQL injection prevention
- Audit logging for compliance

## 📈 Roadmap

- [ ] Implement real-time streaming with Kafka integration
- [ ] Add support for multiple embedding models
- [ ] Implement data versioning and rollback capabilities
- [ ] Add GraphQL API for vector search
- [ ] Machine learning model deployment integration
- [ ] Advanced data quality monitoring

## 🐛 Troubleshooting

### Common Issues
- **Connection Errors**: Check database credentials in `.env`
- **Memory Issues**: Adjust batch sizes in Airflow Variables
- **Performance**: Monitor task parallelism and worker resources

### Useful Commands
```bash
# Check Airflow configuration
airflow config list

# Test database connections
airflow connections test mongo_default
airflow connections test postgres_default

# View task logs
airflow tasks log posts_mongodb_to_postgres extract_posts 2025-01-01
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apache Airflow community for the robust orchestration platform
- pgvector team for efficient vector operations in PostgreSQL
- Open source embedding model contributors
