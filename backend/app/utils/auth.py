"""
Authentication utilities.
"""
import base64
import hashlib
import hmac
import os
import time
from typing import Dict, Optional, Tuple

import jwt

from backend.app.config import get_setting
from backend.app.utils.logging import logger

# Get JWT settings
JWT_SECRET = get_setting("JWT_SECRET", "dev_jwt_secret")
ACCESS_TOKEN_EXPIRE_MINUTES = int(get_setting("ACCESS_TOKEN_EXPIRE_MINUTES", 30))

def hash_password(password: str) -> str:
    """
    Hash a password using PBKDF2.
    
    Args:
        password: Password to hash
        
    Returns:
        str: Hashed password
    """
    salt = os.urandom(16)
    iterations = 100000
    
    # Hash password using PBKDF2
    key = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        iterations,
        dklen=32,
    )
    
    # Encode salt and key
    salt_b64 = base64.b64encode(salt).decode("utf-8")
    key_b64 = base64.b64encode(key).decode("utf-8")
    
    # Return formatted hash
    return f"pbkdf2:sha256:{iterations}${salt_b64}${key_b64}"

def verify_password(password: str, password_hash: str) -> bool:
    """
    Verify a password against a hash.
    
    Args:
        password: Password to verify
        password_hash: Hashed password
        
    Returns:
        bool: True if password matches hash, False otherwise
    """
    try:
        # Parse hash
        algorithm, iterations, salt_key = password_hash.split("$", 2)
        method, hash_name, iterations = algorithm.split(":")
        iterations = int(iterations)
        
        # Decode salt and key
        salt = base64.b64decode(salt_key.split("$")[0])
        key = base64.b64decode(salt_key.split("$")[1])
        
        # Hash password
        new_key = hashlib.pbkdf2_hmac(
            hash_name,
            password.encode("utf-8"),
            salt,
            iterations,
            dklen=len(key),
        )
        
        # Compare keys
        return hmac.compare_digest(key, new_key)
    except Exception as e:
        logger.error(f"Password verification error: {e}")
        return False

def create_access_token(data: Dict, expires_delta: Optional[int] = None) -> str:
    """
    Create a JWT access token.
    
    Args:
        data: Data to encode in token
        expires_delta: Token expiration time in minutes
        
    Returns:
        str: JWT access token
    """
    to_encode = data.copy()
    
    # Set expiration time
    expire = time.time() + (expires_delta or ACCESS_TOKEN_EXPIRE_MINUTES) * 60
    to_encode.update({"exp": expire})
    
    # Encode token
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET, algorithm="HS256")
    
    return encoded_jwt

def decode_access_token(token: str) -> Tuple[bool, Optional[Dict], Optional[str]]:
    """
    Decode a JWT access token.
    
    Args:
        token: JWT access token
        
    Returns:
        Tuple[bool, Optional[Dict], Optional[str]]: (success, payload, error)
    """
    try:
        # Decode token
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return True, payload, None
    except jwt.ExpiredSignatureError:
        return False, None, "Token expired"
    except jwt.InvalidTokenError:
        return False, None, "Invalid token"

