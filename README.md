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
├── Dockerfile.dev        # Development container definition
├── docker-compose.yml    # Production container orchestration
├── Makefile              # Convenience commands
└── README.md             # Project documentation
```

## Database

The application uses SQLite for data storage. The database file is stored in the `data` directory.

### Database Schema

- **users**: User accounts
- **items**: User items
- **api_tokens**: API authentication tokens

## API Endpoints

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

## License

This project is licensed under the MIT License - see the LICENSE file for details.

