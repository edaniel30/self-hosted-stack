# n8n with some services

Educational project for workflow automation using n8n and PostgreSQL database with pgvector extension for vector support.

> **⚠️ EDUCATIONAL PURPOSE ONLY**
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

## Installation
### 1. Start Portainer (Docker Management UI)

```bash
docker-compose -f docker-compose.portainer.yml up -d
```

This will start Portainer on ports `9000` (HTTP) and `9443` (HTTPS).

**Access Portainer:**
- HTTPS: `https://localhost:9443` or `https://YOUR_SERVER_IP:9443`
- HTTP: `http://localhost:9000` or `http://YOUR_SERVER_IP:9000`

On first access, you'll need to create an admin user.

### 2. Start PostgreSQL

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

### 3. Start n8n
```bash
docker-compose -f docker-compose.n8n.yml up -d
```

This will start n8n on port `5678`.

### 4. Start Ollama
```bash
docker-compose -f docker-compose.ollama.yml up -d
```

This will start Ollama on port `11434` and accept external connections.

### Start all services at once

```bash
docker-compose -f docker-compose.portainer.yml up -d
docker-compose -f docker-compose.db.yml up -d
docker-compose -f docker-compose.n8n.yml up -d
docker-compose -f docker-compose.ollama.yml up -d
```

### Stop Services

```bash
docker-compose -f docker-compose.portainer.yml down
docker-compose -f docker-compose.n8n.yml down
docker-compose -f docker-compose.db.yml down
docker-compose -f docker-compose.ollama.yml down
```
### Restart services

```bash
docker-compose -f docker-compose.portainer.yml restart
docker-compose -f docker-compose.n8n.yml restart
docker-compose -f docker-compose.db.yml restart
docker-compose -f docker-compose.ollama.yml restart
```


## Usage

### Access Services

**Portainer (Docker Management):**
- HTTPS: `https://localhost:9443` or `https://YOUR_SERVER_IP:9443`
- HTTP: `http://localhost:9000` or `http://YOUR_SERVER_IP:9000`
- On first access, create an admin user (username and password)
- You can manage all Docker containers, images, volumes, and networks from here

**n8n (Workflow Automation):**
- `http://localhost:5678` or `http://YOUR_SERVER_IP:5678`

**Ollama (LLM API):**
- API: `http://localhost:11434` or `http://YOUR_SERVER_IP:11434`

**PostgreSQL:**
- Host: `localhost` or `YOUR_SERVER_IP`
- Port: `5434`

#### Environment Variables (n8n)
- `N8N_HOST`: Hostname for n8n (default: localhost)
- `N8N_PORT`: Internal n8n port (default: 5678)
- `N8N_PROTOCOL`: HTTP/HTTPS protocol (default: http)
- `N8N_RUNNERS_ENABLED`: Enable runners for execution (default: true)
- `DB_SQLITE_POOL_SIZE`: SQLite connection pool size (default: 5)
- `N8N_SECURE_COOKIE`: Disabled for HTTP access (default: false)

### Managing Ollama Models
#### Install a New Model
Once Ollama is running, you can install models using the CLI:

```bash
# Execute command inside the Ollama container
docker exec -it ollama ollama pull llama3.2

# Or pull other models
docker exec -it ollama ollama pull mistral
docker exec -it ollama ollama pull codellama
docker exec -it ollama ollama pull phi3
```

#### List Installed Models

```bash
docker exec -it ollama ollama list
```

#### Remove a Model

```bash
docker exec -it ollama ollama rm model-name
```

#### Test a Model

```bash
docker exec -it ollama ollama run llama3.2 "Hello, how are you?"
```

#### Access Ollama API from External Hosts

Ollama is configured to accept external connections on port `11434`. You can access it from:

- **From your local machine**: `http://localhost:11434`
- **From another computer on your network**: `http://YOUR_SERVER_IP:11434`
- **From n8n workflows**: Use `http://ollama:11434` (container name) or `http://YOUR_SERVER_IP:11434`

#### Test API Connection

```bash
# From any machine on your network
curl http://YOUR_SERVER_IP:11434/api/tags

# Test generation
curl http://YOUR_SERVER_IP:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Why is the sky blue?"
}'
```

#### Popular Models to Try

- **llama3.2** (3B/8B): Meta's latest Llama model, good for general tasks
- **mistral**: 7B parameter model, excellent for coding and reasoning
- **phi3**: Microsoft's small but powerful model (3.8B)
- **codellama**: Specialized for code generation
- **gemma2**: Google's efficient model (2B/9B)
- **qwen2**: Alibaba's multilingual model

#### GPU Support (Optional)

If your server has an NVIDIA GPU, uncomment the `deploy` section in `docker-compose.ollama.yml` to enable GPU acceleration. You'll also need:

```bash
# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

## Portainer Features

With Portainer you can:
- **View all running containers** and their status
- **Start/stop/restart** containers with one click
- **View logs** from any container in real-time
- **Access container console** to execute commands
- **Manage Docker images** (pull, delete, inspect)
- **Monitor resource usage** (CPU, memory, network)
- **Manage volumes and networks**
- **View container stats** and performance metrics

This is especially useful for:
- Monitoring Ollama model downloads
- Checking n8n workflow execution logs
- Managing PostgreSQL database container
- Viewing resource usage of all services

## Notes

- n8n data is stored in the Docker volume `n8n-data`
- PostgreSQL data is stored in the local folder `./postgres_data`
- Ollama models are stored in the Docker volume `ollama-data`
- Portainer data is stored in the Docker volume `portainer-data`
- All data directories are ignored in version control
- pgvector allows storing embeddings and performing vector similarity searches
- Ollama models can be quite large (2GB-10GB each), ensure you have sufficient disk space

## Security Warning

⚠️ **This configuration is NOT secure for production use:**
- Uses default/weak passwords
- No SSL/TLS encryption for most services
- No firewall rules
- No authentication restrictions
- Ollama API is exposed without authentication
- Portainer exposed without additional security layers
- Simplified security settings for educational purposes

**For production environments, you must:**
- Use strong, unique passwords
- Enable SSL/TLS encryption
- Implement proper firewall rules
- Use secrets management
- Follow security best practices
- Conduct security audits

## Service Ports Summary

| Service    | Port(s)          | Protocol   | Access URL                              |
|------------|------------------|------------|-----------------------------------------|
| Portainer  | 9000, 9443, 8000 | HTTP/HTTPS | `http://SERVER_IP:9000` or `:9443`      |
| n8n        | 5678             | HTTP       | `http://SERVER_IP:5678`                 |
| PostgreSQL | 5434             | TCP        | `SERVER_IP:5434`                        |
| Ollama     | 11434            | HTTP       | `http://SERVER_IP:11434`                |

## License

This is an educational project for the Advanced Topics master's program. Not intended for commercial or production use.
