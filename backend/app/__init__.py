"""
Backend application package initialization.
"""
from backend.app.config import get_setting
from backend.app.db import init_db
from backend.app.utils import logger

__all__ = [
    "init_app"
]

def init_app() -> None:
    """
    Initialize the application.
    """
    # Log application start
    environment = get_setting("ENVIRONMENT", "development")
    logger.info(f"Starting application in {environment} mode")
    
    # Initialize database
    init_db()
    
    logger.info("Application initialized")

