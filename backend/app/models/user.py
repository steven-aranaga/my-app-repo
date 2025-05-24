"""
User model.
"""
from typing import Dict, List, Optional, Any

from backend.app.db import execute_query
from backend.app.utils import hash_password, verify_password, logger

class User:
    """User model."""
    
    def __init__(
        self,
        id: Optional[int] = None,
        username: Optional[str] = None,
        email: Optional[str] = None,
        password_hash: Optional[str] = None,
        is_active: bool = True,
        is_admin: bool = False,
        created_at: Optional[str] = None,
        updated_at: Optional[str] = None,
    ):
        self.id = id
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.is_active = is_active
        self.is_admin = is_admin
        self.created_at = created_at
        self.updated_at = updated_at
        
    @classmethod
    def get_by_id(cls, user_id: int) -> Optional["User"]:
        """
        Get a user by ID.
        
        Args:
            user_id: User ID
            
        Returns:
            Optional[User]: User if found, None otherwise
        """
        query = "SELECT * FROM users WHERE id = ?"
        result = execute_query(query, (user_id,), fetch_one=True)
        
        if result:
            return cls(**result)
        return None
        
    @classmethod
    def get_by_username(cls, username: str) -> Optional["User"]:
        """
        Get a user by username.
        
        Args:
            username: Username
            
        Returns:
            Optional[User]: User if found, None otherwise
        """
        query = "SELECT * FROM users WHERE username = ?"
        result = execute_query(query, (username,), fetch_one=True)
        
        if result:
            return cls(**result)
        return None
        
    @classmethod
    def get_by_email(cls, email: str) -> Optional["User"]:
        """
        Get a user by email.
        
        Args:
            email: Email
            
        Returns:
            Optional[User]: User if found, None otherwise
        """
        query = "SELECT * FROM users WHERE email = ?"
        result = execute_query(query, (email,), fetch_one=True)
        
        if result:
            return cls(**result)
        return None
        
    @classmethod
    def get_all(cls) -> List["User"]:
        """
        Get all users.
        
        Returns:
            List[User]: List of users
        """
        query = "SELECT * FROM users"
        results = execute_query(query, fetch=True)
        
        return [cls(**result) for result in results]
        
    @classmethod
    def create(
        cls,
        username: str,
        email: str,
        password: str,
        is_active: bool = True,
        is_admin: bool = False,
    ) -> Optional["User"]:
        """
        Create a new user.
        
        Args:
            username: Username
            email: Email
            password: Password
            is_active: Whether the user is active
            is_admin: Whether the user is an admin
            
        Returns:
            Optional[User]: Created user if successful, None otherwise
        """
        # Check if username or email already exists
        if cls.get_by_username(username) or cls.get_by_email(email):
            logger.warning(f"User with username '{username}' or email '{email}' already exists")
            return None
            
        # Hash password
        password_hash = hash_password(password)
        
        # Insert user
        query = """
            INSERT INTO users (username, email, password_hash, is_active, is_admin)
            VALUES (?, ?, ?, ?, ?)
        """
        result = execute_query(
            query,
            (username, email, password_hash, is_active, is_admin),
        )
        
        if result and "id" in result:
            return cls.get_by_id(result["id"])
        return None
        
    def update(self, **kwargs: Any) -> bool:
        """
        Update the user.
        
        Args:
            **kwargs: Fields to update
            
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.id:
            logger.warning("Cannot update user without ID")
            return False
            
        # Build query
        fields = []
        values = []
        
        for key, value in kwargs.items():
            if key == "password":
                fields.append("password_hash = ?")
                values.append(hash_password(value))
            elif key in ["username", "email", "is_active", "is_admin"]:
                fields.append(f"{key} = ?")
                values.append(value)
                
        if not fields:
            logger.warning("No valid fields to update")
            return False
            
        # Update user
        query = f"UPDATE users SET {', '.join(fields)} WHERE id = ?"
        values.append(self.id)
        
        execute_query(query, tuple(values))
        
        # Refresh user
        updated_user = self.get_by_id(self.id)
        if updated_user:
            self.__dict__.update(updated_user.__dict__)
            return True
        return False
        
    def delete(self) -> bool:
        """
        Delete the user.
        
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.id:
            logger.warning("Cannot delete user without ID")
            return False
            
        # Delete user
        query = "DELETE FROM users WHERE id = ?"
        execute_query(query, (self.id,))
        
        return True
        
    def verify_password(self, password: str) -> bool:
        """
        Verify a password.
        
        Args:
            password: Password to verify
            
        Returns:
            bool: True if password matches, False otherwise
        """
        if not self.password_hash:
            return False
            
        return verify_password(password, self.password_hash)
        
    def to_dict(self) -> Dict[str, Any]:
        """
        Convert user to dictionary.
        
        Returns:
            Dict[str, Any]: User as dictionary
        """
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "is_active": self.is_active,
            "is_admin": self.is_admin,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }

