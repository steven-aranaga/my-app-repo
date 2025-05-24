use dotenv::dotenv;
use lazy_static::lazy_static;
use std::env;
use std::sync::RwLock;

#[derive(Debug, Clone)]
pub struct Config {
    pub environment: String,
    pub log_level: String,
    pub api_host: String,
    pub api_port: u16,
    pub database_url: String,
    pub api_token: String,
    pub jwt_secret: String,
    pub access_token_expire_minutes: i64,
    pub backend_url: String,
}

impl Config {
    pub fn new() -> Self {
        dotenv().ok();
        
        Self {
            environment: env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string()),
            log_level: env::var("LOG_LEVEL").unwrap_or_else(|_| "info".to_string()),
            api_host: env::var("API_HOST").unwrap_or_else(|_| "127.0.0.1".to_string()),
            api_port: env::var("API_PORT").unwrap_or_else(|_| "8000".to_string()).parse().unwrap_or(8000),
            database_url: env::var("DATABASE_URL").unwrap_or_else(|_| "sqlite:///app/data/app.db".to_string()),
            api_token: env::var("API_TOKEN").unwrap_or_else(|_| "dev_api_token".to_string()),
            jwt_secret: env::var("JWT_SECRET").unwrap_or_else(|_| "dev_jwt_secret".to_string()),
            access_token_expire_minutes: env::var("ACCESS_TOKEN_EXPIRE_MINUTES").unwrap_or_else(|_| "30".to_string()).parse().unwrap_or(30),
            backend_url: env::var("BACKEND_URL").unwrap_or_else(|_| "http://localhost:5000".to_string()),
        }
    }
}

lazy_static! {
    static ref CONFIG: RwLock<Config> = RwLock::new(Config::new());
}

pub fn get_config() -> Config {
    CONFIG.read().unwrap().clone()
}

pub fn reload_config() {
    let mut config = CONFIG.write().unwrap();
    *config = Config::new();
}

