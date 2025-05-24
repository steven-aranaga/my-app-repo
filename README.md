# My App

A modern web application with Python backend and Rust frontend.

## Architecture

- **Backend**: Python with SQLite database
- **API**: Rust with Actix-web
- **Frontend**: Rust with Actix-web and dynamic elements
- **Server**: Nginx

## Development Environment

The development environment runs in a single Docker container with all services:

- Python backend
- Rust API
- Rust frontend
- Nginx server

### Prerequisites

- Docker
- Make (optional, for convenience commands)

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/my-app.git
   cd my-app
   ```

2. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```

3. Build and run the development container:
   ```bash
   make build-dev
   make run-dev
   ```

4. Access the application at http://localhost

### Development Workflow

1. Make changes to the code in your local environment
2. The changes will be reflected in the running container (for Python code)
3. For Rust code changes, you'll need to rebuild:
   ```bash
   make stop-dev
   make build-dev
   make run-dev
   ```

4. To view logs:
   ```bash
   make logs
   ```

5. To access a shell in the container:
   ```bash
   make shell-backend  # For Python backend
   make shell-api      # For Rust API
   make shell-web      # For Rust frontend
   ```

## Production Environment

The production environment uses Docker Compose to run services in separate containers:

- Python backend container
- Rust API container
- Rust frontend container
- Nginx container

### Deployment

1. Build the production containers:
   ```bash
   make build-prod
   ```

2. Start the production environment:
   ```bash
   make run-prod
   ```

3. Stop the production environment:
   ```bash
   make stop-prod
   ```

4. To initialize the database:
   ```bash
   make db-init
   ```

5. To access the database shell:
   ```bash
   make db-shell
   ```

## Configuration

The application is configured using environment variables. Copy the `.env.example` file to `.env` and modify as needed:

```
# Environment
ENVIRONMENT=development

# API settings
API_TOKEN=your_api_token
JWT_SECRET=your_jwt_secret
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Web settings
WEB_HOST=0.0.0.0
WEB_PORT=3000

# API settings
API_HOST=0.0.0.0
API_PORT=8000

# Backend settings
DATABASE_URL=sqlite:///app/data/app.db
LOG_LEVEL=info
LOG_FILE=/app/logs/backend.log
```

## Project Structure

```
my-app/
├── api/                  # Rust API service
│   ├── src/              # API source code
│   ├── Cargo.toml        # API dependencies
│   └── Dockerfile        # API container definition
├── backend/              # Python backend
│   ├── app/              # Backend application
│   │   ├── config/       # Configuration
│   │   ├── db/           # Database utilities
│   │   ├── models/       # Data models
│   │   └── utils/        # Utilities
│   ├── main.py           # Backend entry point
│   ├── requirements.txt  # Python dependencies
│   └── Dockerfile        # Backend container definition
├── web/                  # Rust frontend
│   ├── src/              # Frontend source code
│   ├── templates/        # HTML templates
│   ├── Cargo.toml        # Frontend dependencies
│   └── Dockerfile        # Frontend container definition
├── nginx/                # Nginx configuration
├── static/               # Static files
├── supervisor/           # Supervisor configuration
├── scripts/              # Utility scripts
├── Dockerfile.dev        # Development container definition
├── docker-compose.yml    # Production container orchestration
├── Makefile              # Convenience commands
└── README.md             # Project documentation
```

## Database

The application uses SQLite for data storage. The database file is stored in the `data` directory.

### Database Schema

- **users**: User accounts
  - id: Primary key
  - username: Unique username
  - email: Unique email address
  - password_hash: Hashed password
  - is_active: Whether the user is active
  - is_admin: Whether the user is an admin
  - created_at: Creation timestamp
  - updated_at: Last update timestamp

- **items**: User items
  - id: Primary key
  - name: Item name
  - description: Item description
  - user_id: Foreign key to users table
  - created_at: Creation timestamp
  - updated_at: Last update timestamp

- **api_tokens**: API authentication tokens
  - id: Primary key
  - token: Unique token
  - user_id: Foreign key to users table
  - name: Token name
  - expires_at: Expiration timestamp
  - created_at: Creation timestamp

## API Endpoints

### Authentication

All API endpoints require authentication using one of the following methods:
- API token in the `Authorization` header: `Authorization: Bearer <token>`
- JWT token in the `Authorization` header: `Authorization: Bearer <token>`

### Users

- `GET /api/users`: Get all users
- `GET /api/users/{id}`: Get a user by ID
- `POST /api/users`: Create a new user
- `PUT /api/users/{id}`: Update a user
- `DELETE /api/users/{id}`: Delete a user

### Items

- `GET /api/items`: Get all items
- `GET /api/items/{id}`: Get an item by ID
- `POST /api/items`: Create a new item
- `PUT /api/items/{id}`: Update an item
- `DELETE /api/items/{id}`: Delete an item

## Frontend Pages

- `/`: Home page
- `/users`: User management
- `/items`: Item management
- `/about`: About page

## Development Scripts

The `scripts` directory contains utility scripts:

- `setup-dev.sh`: Set up the development environment
  ```bash
  ./scripts/setup-dev.sh
  ```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
