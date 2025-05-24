## Coding Conventions for my-app

### File naming
file-names = "kebab-case"        # e.g., generate-data.py

### Module & template naming
modules = "snake_case"           # e.g., data_handlers.rs

### Class & Enum names
classes_and_enums = "PascalCase" # e.g., DataMonitor

### Method & function names
methods = "camelCase"            # e.g., getValue()

### Variable & property names
variables = "snake_case"         # e.g., last_active

### Constants & enum cases
constants = "SCREAMING_SNAKE_CASE" # e.g., MAX_VALUE

## Development Guidelines
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

