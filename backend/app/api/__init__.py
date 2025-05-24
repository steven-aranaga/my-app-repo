"""
API package initialization.
"""
from backend.app.api.routes import handle_request

# Export the API router
api_router = handle_request

__all__ = ["api_router"]

