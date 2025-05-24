.PHONY: build-dev run-dev stop-dev build-prod run-prod stop-prod clean

# Development environment
build-dev:
	docker build -t my-app-dev -f Dockerfile.dev .

run-dev:
	docker run -d --name my-app-dev -p 80:80 -v $(PWD):/app my-app-dev

stop-dev:
	docker stop my-app-dev || true
	docker rm my-app-dev || true

# Production environment
build-prod:
	docker-compose build

run-prod:
	docker-compose up -d

stop-prod:
	docker-compose down

# Clean up
clean:
	docker-compose down -v
	docker rmi my-app-dev || true
	docker rmi my-app-web || true
	docker rmi my-app-api || true
	docker rmi my-app-backend || true
	rm -rf data/app.db logs/*.log

# Utility commands
logs:
	docker-compose logs -f

shell-backend:
	docker-compose exec backend /bin/bash

shell-api:
	docker-compose exec api /bin/bash

shell-web:
	docker-compose exec web /bin/bash

# Database commands
db-init:
	docker-compose exec backend python -c "from backend.app.db import init_db; init_db()"

db-shell:
	docker-compose exec backend sqlite3 /app/data/app.db

