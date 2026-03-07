.PHONY: help setup start stop restart destroy status clean validate network \
       start-n8n stop-n8n restart-n8n start-postgres stop-postgres restart-postgres \
       start-ollama stop-ollama restart-ollama start-portainer stop-portainer restart-portainer \
       logs ollama-pull ollama-list ollama-rm

# Load environment variables from .env if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

# All compose files for combined operations
COMPOSE_FILES = -f docker-compose.n8n.yml -f docker-compose.db.yml -f docker-compose.ollama.yml -f docker-compose.portainer.yml

# Default target
help: ## Show this help message
	@echo "Self Hosted Stack - Available Commands:"
	@echo ""
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Setup and Configuration
setup: ## Initial setup - copy .env.example to .env
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Created .env file from .env.example"; \
		echo "Please edit .env with your configuration"; \
		echo ""; \
		echo "Next steps:"; \
		echo "  1. Edit .env and change default passwords"; \
		echo "  2. Run 'make network' to create the shared network (if needed)"; \
		echo "  3. Run 'make start' to start the stack"; \
	else \
		echo ".env file already exists"; \
	fi

network: ## Create the shared Docker network (if it doesn't exist)
	@if ! docker network ls --format '{{.Name}}' | grep -qx $(NETWORK_NAME); then \
		docker network create $(NETWORK_NAME); \
		echo "Created network: $(NETWORK_NAME)"; \
	else \
		echo "Network $(NETWORK_NAME) already exists"; \
	fi

# Container Management - All Services
start: ## Start all services
	@if [ ! -f .env ]; then \
		echo ".env file not found. Run 'make setup' first"; \
		exit 1; \
	fi
	@echo "Starting stack..."
	@docker compose $(COMPOSE_FILES) up -d
	@echo "Stack started"
	@echo ""
	@echo "Access points:"
	@echo "  - n8n:        http://localhost:$(N8N_PORT)"
	@echo "  - Portainer:  https://localhost:$(PORTAINER_PORT_HTTPS)"
	@echo "  - PostgreSQL: localhost:$(POSTGRES_PORT)"
	@echo "  - Ollama API: http://localhost:$(OLLAMA_PORT)"

stop: ## Stop all services
	@echo "Stopping stack..."
	@docker compose $(COMPOSE_FILES) down
	@echo "Stack stopped"

restart: ## Restart all services
	@echo "Restarting stack..."
	@docker compose $(COMPOSE_FILES) restart
	@echo "Stack restarted"

destroy: ## Remove all containers and volumes (WARNING: destroys data)
	@echo "WARNING: This will remove all containers and volumes!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker compose $(COMPOSE_FILES) down -v
	@echo "All containers and volumes removed"

# Individual Service Management
start-n8n: ## Start only n8n service
	@docker compose -f docker-compose.n8n.yml up -d
	@echo "n8n started on http://localhost:$(N8N_PORT)"

stop-n8n: ## Stop only n8n service
	@docker compose -f docker-compose.n8n.yml down
	@echo "n8n stopped"

restart-n8n: ## Restart only n8n service
	@docker compose -f docker-compose.n8n.yml restart
	@echo "n8n restarted"

start-postgres: ## Start only PostgreSQL service
	@docker compose -f docker-compose.db.yml up -d
	@echo "PostgreSQL started on localhost:$(POSTGRES_PORT)"

stop-postgres: ## Stop only PostgreSQL service
	@docker compose -f docker-compose.db.yml down
	@echo "PostgreSQL stopped"

restart-postgres: ## Restart only PostgreSQL service
	@docker compose -f docker-compose.db.yml restart
	@echo "PostgreSQL restarted"

start-ollama: ## Start only Ollama service
	@docker compose -f docker-compose.ollama.yml up -d
	@echo "Ollama started on http://localhost:$(OLLAMA_PORT)"

stop-ollama: ## Stop only Ollama service
	@docker compose -f docker-compose.ollama.yml down
	@echo "Ollama stopped"

restart-ollama: ## Restart only Ollama service
	@docker compose -f docker-compose.ollama.yml restart
	@echo "Ollama restarted"

start-portainer: ## Start only Portainer service
	@docker compose -f docker-compose.portainer.yml up -d
	@echo "Portainer started on https://localhost:$(PORTAINER_PORT_HTTPS)"

stop-portainer: ## Stop only Portainer service
	@docker compose -f docker-compose.portainer.yml down
	@echo "Portainer stopped"

restart-portainer: ## Restart only Portainer service
	@docker compose -f docker-compose.portainer.yml restart
	@echo "Portainer restarted"

# Logs
logs: ## Show logs for all services (usage: make logs or make logs SERVICE=n8n)
	@docker compose $(COMPOSE_FILES) logs -f $(SERVICE)

# Status and Validation
status: ## Show status of all services
	@echo "Self Hosted Stack Status:"
	@echo ""
	@docker compose $(COMPOSE_FILES) ps
	@echo ""
	@echo "Network: $(NETWORK_NAME)"
	@docker network inspect $(NETWORK_NAME) --format '{{range .Containers}}  - {{.Name}}{{"\n"}}{{end}}' 2>/dev/null || echo "  Network not found"

validate: ## Validate docker-compose configuration
	@echo "Validating docker-compose configuration..."
	@docker compose $(COMPOSE_FILES) config --quiet && echo "Configuration is valid" || echo "Configuration has errors"

# Cleanup
clean: ## Clean up data directories (WARNING: destroys data)
	@echo "WARNING: This will remove all local data directories!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@rm -rf ./postgres_data
	@echo "Cleaned up data directories"

# Ollama Model Management
ollama-pull: ## Pull an Ollama model (usage: make ollama-pull MODEL=llama3.2)
	@if [ -z "$(MODEL)" ]; then \
		echo "Usage: make ollama-pull MODEL=<model-name>"; \
		echo "Example: make ollama-pull MODEL=llama3.2"; \
		exit 1; \
	fi
	@docker exec -it $(CONTAINER_NAME_OLLAMA) ollama pull $(MODEL)

ollama-list: ## List installed Ollama models
	@docker exec -it $(CONTAINER_NAME_OLLAMA) ollama list

ollama-rm: ## Remove an Ollama model (usage: make ollama-rm MODEL=llama3.2)
	@if [ -z "$(MODEL)" ]; then \
		echo "Usage: make ollama-rm MODEL=<model-name>"; \
		exit 1; \
	fi
	@docker exec -it $(CONTAINER_NAME_OLLAMA) ollama rm $(MODEL)
