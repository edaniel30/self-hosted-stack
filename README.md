# n8n with PostgreSQL + pgvector

Educational project for workflow automation using n8n and PostgreSQL database with pgvector extension for vector support.

> **⚠️ EDUCATIONAL PURPOSE ONLY**
>
> This project is intended **solely for educational purposes** as part of an Advanced Topics master's program. It is **NOT designed for production use**. The configurations, credentials, and security settings are simplified for learning purposes and should not be used in production environments.

## Description

This project sets up a development environment with:
- **n8n**: Workflow automation platform
- **PostgreSQL with pgvector**: Database with support for vector searches (useful for AI/ML)

## Prerequisites

- Docker
- Docker Compose

## Project Structure

```
.
├── docker-compose.n8n.yml      # n8n configuration
├── docker-compose.db.yml       # PostgreSQL with pgvector configuration
├── .n8n-data/                  # n8n persistent data (ignored in git)
├── postgres_data/              # PostgreSQL persistent data (ignored in git)
└── init-scripts/               # Database initialization scripts
```

## Installation and Usage

### 1. Start PostgreSQL

```bash
docker-compose -f docker-compose.db.yml up -d
```

This will start PostgreSQL with pgvector on port `5434`.

**Default credentials:**
- Host: `localhost`
- Port: `5434`
- Database: `vectordb`
- User: `postgres`
- Password: `password123`

### 2. Start n8n

```bash
docker-compose -f docker-compose.n8n.yml up -d
```

This will start n8n on port `5678`.

### 3. Access n8n

Open your browser and visit: [http://localhost:5678](http://localhost:5678)

### Start both services

```bash
docker-compose -f docker-compose.db.yml up -d
docker-compose -f docker-compose.n8n.yml up -d
```

## Stop Services

```bash
docker-compose -f docker-compose.n8n.yml down
docker-compose -f docker-compose.db.yml down
```

## Environment Variables (n8n)

- `N8N_HOST`: Hostname for n8n (default: localhost)
- `N8N_PORT`: Internal n8n port (default: 5678)
- `N8N_PROTOCOL`: HTTP/HTTPS protocol (default: http)
- `N8N_RUNNERS_ENABLED`: Enable runners for execution (default: true)
- `DB_SQLITE_POOL_SIZE`: SQLite connection pool size (default: 5)

## Check Service Status

```bash
# View n8n logs
docker logs n8n

# View PostgreSQL logs
docker logs postgres_pgvector

# Verify services are running
docker ps
```

## Connect n8n with PostgreSQL

To connect n8n with the PostgreSQL database, use the following credentials in your workflows:

- **Host**: `postgres_pgvector` (container name) or `localhost` (from host)
- **Port**: `5432` (internal) or `5434` (from host)
- **Database**: `vectordb`
- **User**: `postgres`
- **Password**: `password123`

## Notes

- n8n data is stored in the Docker volume `n8n-data`
- PostgreSQL data is stored in the local folder `./postgres_data`
- Both directories are ignored in version control
- pgvector allows storing embeddings and performing vector similarity searches

## Security Warning

⚠️ **This configuration is NOT secure for production use:**
- Uses default/weak passwords
- No SSL/TLS encryption
- No firewall rules
- No authentication restrictions
- Simplified security settings for educational purposes

**For production environments, you must:**
- Use strong, unique passwords
- Enable SSL/TLS encryption
- Implement proper firewall rules
- Use secrets management
- Follow security best practices
- Conduct security audits

## Troubleshooting

### Port already in use

If ports 5678 or 5434 are already in use, you can change them in the docker-compose files:

```yaml
ports:
  - "NEW_PORT:5678"  # For n8n
  - "NEW_PORT:5432"  # For PostgreSQL
```

### Restart services

```bash
docker-compose -f docker-compose.n8n.yml restart
docker-compose -f docker-compose.db.yml restart
```

## License

This is an educational project for the Advanced Topics master's program. Not intended for commercial or production use.
