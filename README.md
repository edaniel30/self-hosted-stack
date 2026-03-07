# Self Hosted Stack

Self-hosted services stack using Docker Compose for workflow automation, vector database, local LLM inference, and container management.

> **EDUCATIONAL PURPOSE ONLY**
>
> This project is intended **solely for educational purposes** as part of an Advanced Topics master's program. It is **NOT designed for production use**. Configurations, credentials, and security settings are simplified for learning purposes.

## Services

| Service | Description | Image |
|---------|-------------|-------|
| **n8n** | Workflow automation platform | `n8nio/n8n:latest` |
| **PostgreSQL + pgvector** | Database with vector search support (AI/ML) | `pgvector/pgvector:pg16` |
| **Ollama** | Local LLM inference engine | `ollama/ollama:latest` |
| **Portainer** | Docker management web interface | `portainer/portainer-ce:latest` |

> The stack is designed to be extensible — new services can be added by creating additional `docker-compose.<service>.yml` files.

## Architecture

```text
docker-compose.n8n.yml        # n8n
docker-compose.db.yml         # PostgreSQL + pgvector
docker-compose.ollama.yml     # Ollama
docker-compose.portainer.yml  # Portainer
scripts/postgres-vector/      # PostgreSQL initialization scripts (pgvector)
.env.example                  # Environment variables template
Makefile                      # Management commands
```

Each service has its own compose file. All services share a Docker network (`shared_network`) for inter-service communication, making it easy to add more services in the future.

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

| Command | Description |
|---------|-------------|
| `make help` | Show help message |
| `make setup` | Initial setup - copy .env.example to .env |
| `make network` | Create the shared Docker network |
| `make start` | Start all services |
| `make stop` | Stop all services |
| `make restart` | Restart all services |
| `make destroy` | Remove all containers and volumes (destructive) |
| `make status` | Show status of all services |
| `make logs` | Show logs for all services (or `make logs SERVICE=n8n`) |
| `make validate` | Validate docker-compose configuration |
| `make clean` | Clean up data directories (destructive) |

### Individual Services

| Command | Description |
|---------|-------------|
| `make start-n8n` / `make stop-n8n` / `make restart-n8n` | Start/stop/restart n8n |
| `make start-postgres` / `make stop-postgres` / `make restart-postgres` | Start/stop/restart PostgreSQL |
| `make start-ollama` / `make stop-ollama` / `make restart-ollama` | Start/stop/restart Ollama |
| `make start-portainer` / `make stop-portainer` / `make restart-portainer` | Start/stop/restart Portainer |

### Ollama Model Management

```bash
# Pull a model
make ollama-pull MODEL=llama3.2

# List installed models
make ollama-list

# Remove a model
make ollama-rm MODEL=llama3.2
```

## Configuration

All configuration is managed through the `.env` file. Key settings:

### Network
```env
NETWORK_NAME=shared_network
NETWORK_EXTERNAL=true
```

### Ports
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

| Service | Port(s) | URL |
|---------|---------|-----|
| n8n | 5678 | http://localhost:5678 |
| Portainer | 9000, 9443 | https://localhost:9443 |
| PostgreSQL | 5434 | `localhost:5434` |
| Ollama | 11434 | http://localhost:11434 |

## GPU Support (Ollama)

If your machine has an NVIDIA GPU, edit `docker-compose.ollama.yml` and uncomment the `deploy` section:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

Requires the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

## Data Persistence

| Service | Volume/Path | Contents |
|---------|-------------|----------|
| n8n | `n8n-data` | Workflows and credentials |
| PostgreSQL | `./postgres_data` | Database files |
| Ollama | `ollama-data` | Downloaded models |
| Portainer | `portainer-data` | Portainer configuration |

## Adding New Services

To extend the stack with a new service:

1. Create a `docker-compose.<service>.yml` file with the service definition
2. Connect it to the `shared_network` network
3. Add the compose file to the `COMPOSE_FILES` variable in the `Makefile`
4. Add environment variables to `.env.example`
5. Add Makefile targets for individual management

## Security Warning

**This configuration is NOT secure for production use:**
- Uses default/weak passwords
- No SSL/TLS encryption for most services
- No firewall rules
- No authentication restrictions
- Ollama API exposed without authentication

## License

Educational project for the Advanced Topics master's program. Not intended for commercial or production use.
