"""
Configuration utilities.
"""
import os
from typing import Any, Dict, Optional

from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration dictionary
_config: Dict[str, Any] = {}

def get_setting(key: str, default: Optional[Any] = None) -> Any:
    """
    Get a configuration setting.
    
    Args:
        key: Setting key
        default: Default value
        
    Returns:
        Any: Setting value
    """
    # Check if setting is already loaded
    if key in _config:
        return _config[key]
        
    # Get setting from environment
    value = os.environ.get(key, default)
    
    # Cache setting
    _config[key] = value
    
    return value

def set_setting(key: str, value: Any) -> None:
    """
    Set a configuration setting.
    
    Args:
        key: Setting key
        value: Setting value
    """
    _config[key] = value

def reload_settings() -> None:
    """
    Reload all settings from environment.
    """
    # Clear configuration
    _config.clear()
    
    # Reload environment variables
    load_dotenv(override=True)

