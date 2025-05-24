# Coding Conventions

This document outlines the coding conventions and best practices for the My App project.

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| File names | kebab-case | `generate-data.py`, `user-service.rs` |
| Module & template names | snake_case | `data_handlers.rs`, `user_utils.py` |
| Class & Enum names | PascalCase | `DataMonitor`, `UserRole` |
| Method & function names | camelCase | `getValue()`, `fetchUserData()` |
| Variable & property names | snake_case | `last_active`, `user_count` |
| Constants & enum cases | SCREAMING_SNAKE_CASE | `MAX_VALUE`, `DEFAULT_TIMEOUT` |

## Language-Specific Guidelines

### Python

1. **Code Style**
   - Follow PEP 8 style guide
   - Use 4 spaces for indentation
   - Maximum line length of 88 characters (Black formatter standard)
   - Use docstrings for all modules, classes, and functions

2. **Type Hints**
   - Use type hints for all function parameters and return values
   - Use `Optional[Type]` for parameters that can be None
   - Use `Union[Type1, Type2]` for parameters that can be multiple types
   - Use `List[Type]`, `Dict[KeyType, ValueType]`, etc. for container types

3. **Imports**
   - Group imports in the following order:
     1. Standard library imports
     2. Related third-party imports
     3. Local application/library specific imports
   - Use absolute imports within the project

4. **Error Handling**
   - Use specific exception types
   - Always log exceptions with context
   - Use context managers (`with` statements) for resource management

5. **Testing**
   - Write unit tests for all functions and methods
   - Use pytest for testing
   - Aim for at least 80% code coverage

### Rust

1. **Code Style**
   - Follow Rust standard style guide
   - Use 4 spaces for indentation
   - Use `rustfmt` for formatting
   - Use `clippy` for linting

2. **Error Handling**
   - Use the `Result` type for functions that can fail
   - Prefer `?` operator for error propagation
   - Create custom error types for complex error handling

3. **Documentation**
   - Use doc comments (`///`) for public API
   - Include examples in doc comments
   - Document all public functions, structs, and traits

4. **Testing**
   - Write unit tests for all functions
   - Use `#[test]` attribute for test functions
   - Use `#[cfg(test)]` module for test code

5. **Dependencies**
   - Pin dependency versions in `Cargo.toml`
   - Regularly audit dependencies with `cargo audit`
   - Minimize dependency count

### HTML/CSS/JavaScript

1. **HTML**
   - Use HTML5 semantic elements
   - Validate HTML with W3C validator
   - Use lowercase for element names and attributes
   - Use double quotes for attribute values

2. **CSS**
   - Use kebab-case for class and ID names
   - Use a consistent color scheme
   - Use responsive design principles
   - Minimize use of !important

3. **JavaScript**
   - Use ES6+ features
   - Use camelCase for variables and functions
   - Use PascalCase for classes
   - Use strict mode (`'use strict';`)

## Development Guidelines

### Security

1. **Authentication & Authorization**
   - Use JWT for API authentication
   - Store passwords using strong hashing (bcrypt/Argon2)
   - Implement proper role-based access control
   - Use HTTPS in production

2. **Data Validation**
   - Validate all user input
   - Use parameterized queries for database access
   - Sanitize data before displaying to prevent XSS

3. **API Security**
   - Implement rate limiting
   - Use proper CORS configuration
   - Set secure HTTP headers
   - Validate request content types

### Performance

1. **Database**
   - Use indexes for frequently queried fields
   - Optimize queries for performance
   - Use connection pooling
   - Implement caching for frequent queries

2. **API**
   - Implement pagination for list endpoints
   - Use compression for responses
   - Cache responses where appropriate
   - Minimize payload size

3. **Frontend**
   - Optimize asset loading
   - Minimize DOM manipulations
   - Use lazy loading for images and components
   - Implement proper error boundaries

### Development Workflow

1. **Version Control**
   - Use feature branches for development
   - Write clear commit messages
   - Squash commits before merging
   - Use pull requests for code review

2. **CI/CD**
   - Run tests on every pull request
   - Automate deployment process
   - Use environment-specific configuration
   - Implement smoke tests after deployment

3. **Documentation**
   - Keep README up to date
   - Document API endpoints
   - Maintain change log
   - Document environment setup process

## Tools and Technologies

- **Languages & Frameworks**
  - Python 3.x for backend scripts
  - Rust + Actix-Web for API and server-side rendering
  - HTML5, CSS3, vanilla JavaScript + HTMX for interactivity
  - Askama templates for server-side rendering

- **Security & DX**
  - Enforce strict type hints in Python; run `pip-audit` regularly
  - Use `cargo audit` and lock Cargo dependencies
  - Configure strong Content Security Policy on all sites
  - Write comprehensive docblocks for all modules/functions
