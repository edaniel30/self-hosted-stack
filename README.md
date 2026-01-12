# n8n Stack

Educational project for workflow automation using n8n and PostgreSQL database with pgvector extension for vector support.

> **EDUCATIONAL PURPOSE ONLY**
>
> This project is intended **solely for educational purposes** as part of an Advanced Topics master's program. It is **NOT designed for production use**. The configurations, credentials, and security settings are simplified for learning purposes and should not be used in production environments.

## Description

This project sets up a development environment with:
- **n8n**: Workflow automation platform
- **PostgreSQL with pgvector**: Database with support for vector searches (useful for AI/ML)
- **Ollama**: Local LLM inference engine for running AI models
- **Portainer**: Docker management web interface

## Prerequisites

- Docker
- Docker Compose
- Make (optional, but recommended)

## Quick Start

```bash
# 1. Initial setup - creates .env from template
make setup

# 2. Edit .env with your configuration (optional)
nano .env

# 3. Create the shared network (if it doesn't exist)
make network

# 4. Start all services
make start
```

## Available Commands

Run `make help` to see all available commands:

```
n8n Stack - Available Commands:

  help                 Show this help message
  setup                Initial setup - copy .env.example to .env
  network              Create the shared Docker network (if it doesn't exist)
  start                Start all services
  stop                 Stop all services
  restart              Restart all services
  destroy              Remove all containers and volumes (WARNING: destroys data)
  start-n8n            Start only n8n service
  stop-n8n             Stop only n8n service
  start-postgres       Start only PostgreSQL service
  stop-postgres        Stop only PostgreSQL service
  start-ollama         Start only Ollama service
  stop-ollama          Stop only Ollama service
  start-portainer      Start only Portainer service
  stop-portainer       Stop only Portainer service
  status               Show status of all services
  validate             Validate docker-compose configuration
  clean                Clean up data directories (WARNING: destroys data)
  ollama-pull          Pull an Ollama model (usage: make ollama-pull MODEL=llama3.2)
  ollama-list          List installed Ollama models
  ollama-rm            Remove an Ollama model (usage: make ollama-rm MODEL=llama3.2)
```

## Installation

### Using Make (Recommended)

```bash
# Setup and start all services
make setup
make network
make start

# Or start individual services
make start-n8n
make start-postgres
make start-ollama
make start-portainer
```

## Configuration

All configuration is managed through the `.env` file. Key settings include:

### Network Configuration
```env
NETWORK_NAME=shared_network
NETWORK_EXTERNAL=true
```

### Service Ports
```env
N8N_PORT=5678
POSTGRES_PORT=5434
OLLAMA_PORT=11434
PORTAINER_PORT_HTTPS=9443
PORTAINER_PORT_HTTP=9000
```

### PostgreSQL Credentials
```env
POSTGRES_DB=vectordb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=change_me_in_production
```

## Access Services

| Service    | Port(s)          | URL                                     |
|------------|------------------|-----------------------------------------|
| n8n        | 5678             | http://localhost:5678                   |
| Portainer  | 9000, 9443       | https://localhost:9443                  |
| PostgreSQL | 5434             | localhost:5434                          |
| Ollama     | 11434            | http://localhost:11434                  |

## Managing Ollama Models

```bash
# Install a model
make ollama-pull MODEL=llama3.2

# List installed models
make ollama-list

# Remove a model
make ollama-rm MODEL=llama3.2
```


## PostgreSQL with pgvector

Connect to the database:

```bash
make psql
```

The database includes pgvector extension for vector similarity searches, useful for AI/ML applications.

## GPU Support (Ollama)

If your server has an NVIDIA GPU, edit `docker-compose.ollama.yml` and uncomment the `deploy` section:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

You'll also need the NVIDIA Container Toolkit installed.

## Data Persistence

| Service    | Volume/Path         | Description                    |
|------------|---------------------|--------------------------------|
| n8n        | n8n-data            | Workflows and credentials      |
| PostgreSQL | ./postgres_data     | Database files                 |
| Ollama     | ollama-data         | Downloaded models              |
| Portainer  | portainer-data      | Portainer configuration        |

## Security Warning

**This configuration is NOT secure for production use:**
- Uses default/weak passwords
- No SSL/TLS encryption for most services
- No firewall rules
- No authentication restrictions
- Ollama API is exposed without authentication
- Simplified security settings for educational purposes

**For production environments, you must:**
- Use strong, unique passwords
- Enable SSL/TLS encryption
- Implement proper firewall rules
- Use secrets management
- Follow security best practices

## License

This is an educational project for the Advanced Topics master's program. Not intended for commercial or production use.
