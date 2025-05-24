"""
Item model.
"""
from typing import Dict, List, Optional, Any

from backend.app.db import execute_query
from backend.app.utils import logger

class Item:
    """Item model."""
    
    def __init__(
        self,
        id: Optional[int] = None,
        name: Optional[str] = None,
        description: Optional[str] = None,
        user_id: Optional[int] = None,
        created_at: Optional[str] = None,
        updated_at: Optional[str] = None,
    ):
        self.id = id
        self.name = name
        self.description = description
        self.user_id = user_id
        self.created_at = created_at
        self.updated_at = updated_at
        
    @classmethod
    def get_by_id(cls, item_id: int) -> Optional["Item"]:
        """
        Get an item by ID.
        
        Args:
            item_id: Item ID
            
        Returns:
            Optional[Item]: Item if found, None otherwise
        """
        query = "SELECT * FROM items WHERE id = ?"
        result = execute_query(query, (item_id,), fetch_one=True)
        
        if result:
            return cls(**result)
        return None
        
    @classmethod
    def get_by_user_id(cls, user_id: int) -> List["Item"]:
        """
        Get items by user ID.
        
        Args:
            user_id: User ID
            
        Returns:
            List[Item]: List of items
        """
        query = "SELECT * FROM items WHERE user_id = ?"
        results = execute_query(query, (user_id,), fetch=True)
        
        return [cls(**result) for result in results]
        
    @classmethod
    def get_all(cls) -> List["Item"]:
        """
        Get all items.
        
        Returns:
            List[Item]: List of items
        """
        query = "SELECT * FROM items"
        results = execute_query(query, fetch=True)
        
        return [cls(**result) for result in results]
        
    @classmethod
    def create(
        cls,
        name: str,
        user_id: int,
        description: Optional[str] = None,
    ) -> Optional["Item"]:
        """
        Create a new item.
        
        Args:
            name: Item name
            user_id: User ID
            description: Item description
            
        Returns:
            Optional[Item]: Created item if successful, None otherwise
        """
        # Insert item
        query = """
            INSERT INTO items (name, description, user_id)
            VALUES (?, ?, ?)
        """
        result = execute_query(
            query,
            (name, description, user_id),
        )
        
        if result and "id" in result:
            return cls.get_by_id(result["id"])
        return None
        
    def update(self, **kwargs: Any) -> bool:
        """
        Update the item.
        
        Args:
            **kwargs: Fields to update
            
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.id:
            logger.warning("Cannot update item without ID")
            return False
            
        # Build query
        fields = []
        values = []
        
        for key, value in kwargs.items():
            if key in ["name", "description", "user_id"]:
                fields.append(f"{key} = ?")
                values.append(value)
                
        if not fields:
            logger.warning("No valid fields to update")
            return False
            
        # Update item
        query = f"UPDATE items SET {', '.join(fields)} WHERE id = ?"
        values.append(self.id)
        
        execute_query(query, tuple(values))
        
        # Refresh item
        updated_item = self.get_by_id(self.id)
        if updated_item:
            self.__dict__.update(updated_item.__dict__)
            return True
        return False
        
    def delete(self) -> bool:
        """
        Delete the item.
        
        Returns:
            bool: True if successful, False otherwise
        """
        if not self.id:
            logger.warning("Cannot delete item without ID")
            return False
            
        # Delete item
        query = "DELETE FROM items WHERE id = ?"
        execute_query(query, (self.id,))
        
        return True
        
    def to_dict(self) -> Dict[str, Any]:
        """
        Convert item to dictionary.
        
        Returns:
            Dict[str, Any]: Item as dictionary
        """
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "user_id": self.user_id,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }

