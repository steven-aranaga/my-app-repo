use ring::{digest, pbkdf2};
use std::num::NonZeroU32;

static PBKDF2_ALG: pbkdf2::Algorithm = pbkdf2::PBKDF2_HMAC_SHA256;
const CREDENTIAL_LEN: usize = digest::SHA256_OUTPUT_LEN;
const PBKDF2_ITERATIONS: u32 = 100_000;

/// Hash a password using PBKDF2
pub fn hash_password(password: &str) -> Result<String, String> {
    let salt = generate_salt();
    let mut pbkdf2_hash = [0u8; CREDENTIAL_LEN];
    
    pbkdf2::derive(
        PBKDF2_ALG,
        NonZeroU32::new(PBKDF2_ITERATIONS).unwrap(),
        &salt,
        password.as_bytes(),
        &mut pbkdf2_hash,
    );
    
    let salt_b64 = base64::encode(&salt);
    let hash_b64 = base64::encode(&pbkdf2_hash);
    
    Ok(format!("{}:{}:{}", PBKDF2_ITERATIONS, salt_b64, hash_b64))
}

/// Verify a password against a hash
pub fn verify_password(password: &str, hash_string: &str) -> Result<bool, String> {
    let parts: Vec<&str> = hash_string.split(':').collect();
    
    if parts.len() != 3 {
        return Err("Invalid hash format".to_string());
    }
    
    let iterations = parts[0].parse::<u32>().map_err(|_| "Invalid iteration count".to_string())?;
    let salt = base64::decode(parts[1]).map_err(|_| "Invalid salt".to_string())?;
    let hash = base64::decode(parts[2]).map_err(|_| "Invalid hash".to_string())?;
    
    let result = pbkdf2::verify(
        PBKDF2_ALG,
        NonZeroU32::new(iterations).unwrap(),
        &salt,
        password.as_bytes(),
        &hash,
    );
    
    Ok(result.is_ok())
}

/// Generate a random salt
fn generate_salt() -> Vec<u8> {
    let mut salt = vec![0u8; 16];
    getrandom::getrandom(&mut salt).expect("Failed to generate random salt");
    salt
}

