use reqwest::{Client, Error as ReqwestError, StatusCode};
use serde::{de::DeserializeOwned, Serialize};
use std::fmt;

use crate::config::get_config;

// API client error
#[derive(Debug)]
pub enum ApiError {
    RequestError(ReqwestError),
    StatusError(StatusCode, String),
    DeserializeError(String),
}

impl fmt::Display for ApiError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ApiError::RequestError(err) => write!(f, "Request error: {}", err),
            ApiError::StatusError(status, message) => write!(f, "Status error: {} - {}", status, message),
            ApiError::DeserializeError(err) => write!(f, "Deserialize error: {}", err),
        }
    }
}

impl From<ReqwestError> for ApiError {
    fn from(err: ReqwestError) -> Self {
        ApiError::RequestError(err)
    }
}

// API client
pub struct ApiClient {
    client: Client,
    base_url: String,
    token: String,
}

impl ApiClient {
    pub fn new() -> Self {
        let config = get_config();
        
        Self {
            client: Client::new(),
            base_url: config.api_url,
            token: config.api_token,
        }
    }
    
    pub async fn get<T>(&self, path: &str) -> Result<T, ApiError>
    where
        T: DeserializeOwned,
    {
        let url = format!("{}{}", self.base_url, path);
        
        let response = self.client
            .get(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .send()
            .await?;
            
        self.handle_response(response).await
    }
    
    pub async fn post<T, B>(&self, path: &str, body: &B) -> Result<T, ApiError>
    where
        T: DeserializeOwned,
        B: Serialize,
    {
        let url = format!("{}{}", self.base_url, path);
        
        let response = self.client
            .post(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .json(body)
            .send()
            .await?;
            
        self.handle_response(response).await
    }
    
    pub async fn put<T, B>(&self, path: &str, body: &B) -> Result<T, ApiError>
    where
        T: DeserializeOwned,
        B: Serialize,
    {
        let url = format!("{}{}", self.base_url, path);
        
        let response = self.client
            .put(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .json(body)
            .send()
            .await?;
            
        self.handle_response(response).await
    }
    
    pub async fn delete<T>(&self, path: &str) -> Result<T, ApiError>
    where
        T: DeserializeOwned,
    {
        let url = format!("{}{}", self.base_url, path);
        
        let response = self.client
            .delete(&url)
            .header("Authorization", format!("Bearer {}", self.token))
            .send()
            .await?;
            
        self.handle_response(response).await
    }
    
    async fn handle_response<T>(&self, response: reqwest::Response) -> Result<T, ApiError>
    where
        T: DeserializeOwned,
    {
        let status = response.status();
        
        if status.is_success() {
            let body = response.json::<T>().await.map_err(|e| {
                ApiError::DeserializeError(e.to_string())
            })?;
            
            Ok(body)
        } else {
            let error_text = response.text().await.unwrap_or_else(|_| "Unknown error".to_string());
            
            Err(ApiError::StatusError(status, error_text))
        }
    }
}

