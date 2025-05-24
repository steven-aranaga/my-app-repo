"""
Backend application entry point.
"""
import os
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from backend.app import init_app
from backend.app.utils import logger

if __name__ == "__main__":
    # Initialize application
    init_app()
    
    logger.info("Backend application started")

