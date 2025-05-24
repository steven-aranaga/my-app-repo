"""
API routes for the backend application.
"""
import json
from typing import Dict, List, Optional, Any, Union

from backend.app.models import User, Item
from backend.app.utils import logger, validate_api_token
from backend.app.config import get_setting

# API token for authentication
API_TOKEN = get_setting("API_TOKEN")

def handle_request(method: str, path: str, headers: Dict[str, str], body: Optional[str] = None) -> Dict[str, Any]:
    """
    Handle an API request.
    
    Args:
        method: HTTP method
        path: Request path
        headers: Request headers
        body: Request body
        
    Returns:
        Dict[str, Any]: Response data
    """
    # Validate API token
    auth_header = headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return {
            "status": 401,
            "content_type": "application/json",
            "body": json.dumps({"error": "Unauthorized"})
        }
        
    token = auth_header.replace("Bearer ", "")
    if token != API_TOKEN:
        return {
            "status": 401,
            "content_type": "application/json",
            "body": json.dumps({"error": "Invalid token"})
        }
    
    # Parse request body
    data = {}
    if body:
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            return {
                "status": 400,
                "content_type": "application/json",
                "body": json.dumps({"error": "Invalid JSON"})
            }
    
    # Route request
    try:
        if path == "/api/users":
            return handle_users(method, data)
        elif path.startswith("/api/users/"):
            user_id = int(path.split("/")[-1])
            return handle_user(method, user_id, data)
        elif path == "/api/items":
            return handle_items(method, data)
        elif path.startswith("/api/items/"):
            item_id = int(path.split("/")[-1])
            return handle_item(method, item_id, data)
        elif path == "/api/health":
            return {
                "status": 200,
                "content_type": "application/json",
                "body": json.dumps({"status": "ok"})
            }
        else:
            return {
                "status": 404,
                "content_type": "application/json",
                "body": json.dumps({"error": "Not found"})
            }
    except Exception as e:
        logger.exception(f"Error handling request: {e}")
        return {
            "status": 500,
            "content_type": "application/json",
            "body": json.dumps({"error": "Internal server error"})
        }

def handle_users(method: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle requests to /api/users.
    
    Args:
        method: HTTP method
        data: Request data
        
    Returns:
        Dict[str, Any]: Response data
    """
    if method == "GET":
        # Get all users
        users = User.get_all()
        return {
            "status": 200,
            "content_type": "application/json",
            "body": json.dumps([user.to_dict() for user in users])
        }
    elif method == "POST":
        # Create a new user
        if not all(k in data for k in ["username", "email", "password"]):
            return {
                "status": 400,
                "content_type": "application/json",
                "body": json.dumps({"error": "Missing required fields"})
            }
            
        # Check if user already exists
        if User.get_by_username(data["username"]):
            return {
                "status": 409,
                "content_type": "application/json",
                "body": json.dumps({"error": "Username already exists"})
            }
            
        if User.get_by_email(data["email"]):
            return {
                "status": 409,
                "content_type": "application/json",
                "body": json.dumps({"error": "Email already exists"})
            }
            
        # Create user
        user = User(
            username=data["username"],
            email=data["email"],
            password_hash=User.hash_password(data["password"]),
            is_active=data.get("is_active", True),
            is_admin=data.get("is_admin", False)
        )
        user.save()
        
        return {
            "status": 201,
            "content_type": "application/json",
            "body": json.dumps(user.to_dict())
        }
    else:
        return {
            "status": 405,
            "content_type": "application/json",
            "body": json.dumps({"error": "Method not allowed"})
        }

def handle_user(method: str, user_id: int, data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle requests to /api/users/{user_id}.
    
    Args:
        method: HTTP method
        user_id: User ID
        data: Request data
        
    Returns:
        Dict[str, Any]: Response data
    """
    # Get user
    user = User.get_by_id(user_id)
    if not user:
        return {
            "status": 404,
            "content_type": "application/json",
            "body": json.dumps({"error": "User not found"})
        }
        
    if method == "GET":
        # Get user
        return {
            "status": 200,
            "content_type": "application/json",
            "body": json.dumps(user.to_dict())
        }
    elif method == "PUT":
        # Update user
        if "username" in data:
            user.username = data["username"]
        if "email" in data:
            user.email = data["email"]
        if "password" in data:
            user.password_hash = User.hash_password(data["password"])
        if "is_active" in data:
            user.is_active = data["is_active"]
        if "is_admin" in data:
            user.is_admin = data["is_admin"]
            
        user.save()
        
        return {
            "status": 200,
            "content_type": "application/json",
            "body": json.dumps(user.to_dict())
        }
    elif method == "DELETE":
        # Delete user
        user.delete()
        
        return {
            "status": 204,
            "content_type": "application/json",
            "body": ""
        }
    else:
        return {
            "status": 405,
            "content_type": "application/json",
            "body": json.dumps({"error": "Method not allowed"})
        }

def handle_items(method: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle requests to /api/items.
    
    Args:
        method: HTTP method
        data: Request data
        
    Returns:
        Dict[str, Any]: Response data
    """
    if method == "GET":
        # Get all items
        items = Item.get_all()
        return {
            "status": 200,
            "content_type": "application/json",
            "body": json.dumps([item.to_dict() for item in items])
        }
    elif method == "POST":
        # Create a new item
        if not all(k in data for k in ["name", "user_id"]):
            return {
                "status": 400,
                "content_type": "application/json",
                "body": json.dumps({"error": "Missing required fields"})
            }
            
        # Check if user exists
        user = User.get_by_id(data["user_id"])
        if not user:
            return {
                "status": 404,
                "content_type": "application/json",
                "body": json.dumps({"error": "User not found"})
            }
            
        # Create item
        item = Item(
            name=data["name"],
            description=data.get("description"),
            user_id=data["user_id"]
        )
        item.save()
        
        return {
            "status": 201,
            "content_type": "application/json",
            "body": json.dumps(item.to_dict())
        }
    else:
        return {
            "status": 405,
            "content_type": "application/json",
            "body": json.dumps({"error": "Method not allowed"})
        }

def handle_item(method: str, item_id: int, data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle requests to /api/items/{item_id}.
    
    Args:
        method: HTTP method
        item_id: Item ID
        data: Request data
        
    Returns:
        Dict[str, Any]: Response data
    """
    # Get item
    item = Item.get_by_id(item_id)
    if not item:
        return {
            "status": 404,
            "content_type": "application/json",
            "body": json.dumps({"error": "Item not found"})
        }
        
    if method == "GET":
        # Get item
        return {
            "status": 200,
            "content_type": "application/json",
            "body": json.dumps(item.to_dict())
        }
    elif method == "PUT":
        # Update item
        if "name" in data:
            item.name = data["name"]
        if "description" in data:
            item.description = data["description"]
        if "user_id" in data:
            # Check if user exists
            user = User.get_by_id(data["user_id"])
            if not user:
                return {
                    "status": 404,
                    "content_type": "application/json",
                    "body": json.dumps({"error": "User not found"})
                }
                
            item.user_id = data["user_id"]
            
        item.save()
        
        return {
            "status": 200,
            "content_type": "application/json",
            "body": json.dumps(item.to_dict())
        }
    elif method == "DELETE":
        # Delete item
        item.delete()
        
        return {
            "status": 204,
            "content_type": "application/json",
            "body": ""
        }
    else:
        return {
            "status": 405,
            "content_type": "application/json",
            "body": json.dumps({"error": "Method not allowed"})
        }

