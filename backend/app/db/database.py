"""
Database utilities.
"""
import os
import sqlite3
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

from backend.app.config import get_setting
from backend.app.utils.logging import logger

# Get database settings
DATABASE_URL = get_setting("DATABASE_URL", "sqlite:///app/data/app.db")

def get_db_path() -> str:
    """
    Get the database path from the URL.
    
    Returns:
        str: Database path
    """
    # Parse database URL
    if DATABASE_URL.startswith("sqlite:///"):
        db_path = DATABASE_URL[10:]
        
        # Ensure directory exists
        db_dir = os.path.dirname(db_path)
        if db_dir:
            os.makedirs(db_dir, exist_ok=True)
            
        return db_path
    else:
        raise ValueError(f"Unsupported database URL: {DATABASE_URL}")

def get_connection() -> sqlite3.Connection:
    """
    Get a database connection.
    
    Returns:
        sqlite3.Connection: Database connection
    """
    db_path = get_db_path()
    
    # Connect to database
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    
    return conn

def execute_query(
    query: str,
    params: Optional[Tuple[Any, ...]] = None,
    fetch: bool = False,
    fetch_one: bool = False,
) -> Union[Dict[str, Any], List[Dict[str, Any]], None]:
    """
    Execute a database query.
    
    Args:
        query: SQL query
        params: Query parameters
        fetch: Whether to fetch results
        fetch_one: Whether to fetch a single result
        
    Returns:
        Union[Dict[str, Any], List[Dict[str, Any]], None]: Query results
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Execute query
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
            
        # Fetch results
        if fetch_one:
            result = cursor.fetchone()
            if result:
                return dict(result)
            return None
        elif fetch:
            results = cursor.fetchall()
            return [dict(row) for row in results]
        else:
            # For INSERT, get the last inserted ID
            if query.strip().upper().startswith("INSERT"):
                return {"id": cursor.lastrowid}
            return None
    except Exception as e:
        logger.error(f"Database error: {e}")
        conn.rollback()
        raise
    finally:
        conn.commit()
        conn.close()

def init_db() -> None:
    """
    Initialize the database.
    """
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Read schema
        schema_path = Path(__file__).parent / "schema.sql"
        with open(schema_path, "r") as f:
            schema = f.read()
            
        # Execute schema
        cursor.executescript(schema)
        
        logger.info("Database initialized")
    except Exception as e:
        logger.error(f"Database initialization error: {e}")
        conn.rollback()
        raise
    finally:
        conn.commit()
        conn.close()

