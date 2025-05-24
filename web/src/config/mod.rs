use dotenv::dotenv;
use lazy_static::lazy_static;
use std::env;
use std::sync::RwLock;

#[derive(Debug, Clone)]
pub struct Config {
    pub environment: String,
    pub log_level: String,
    pub web_host: String,
    pub web_port: u16,
    pub api_url: String,
    pub api_token: String,
}

impl Config {
    pub fn new() -> Self {
        dotenv().ok();
        
        Self {
            environment: env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string()),
            log_level: env::var("LOG_LEVEL").unwrap_or_else(|_| "info".to_string()),
            web_host: env::var("WEB_HOST").unwrap_or_else(|_| "127.0.0.1".to_string()),
            web_port: env::var("WEB_PORT").unwrap_or_else(|_| "3000".to_string()).parse().unwrap_or(3000),
            api_url: env::var("API_URL").unwrap_or_else(|_| "http://localhost:8000".to_string()),
            api_token: env::var("API_TOKEN").unwrap_or_else(|_| "dev_api_token".to_string()),
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

