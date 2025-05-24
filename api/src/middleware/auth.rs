use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpMessage, HttpResponse,
};
use futures::future::{ok, Ready};
use log::error;
use std::future::{ready, Future, Ready as StdReady};
use std::pin::Pin;
use std::task::{Context, Poll};

use crate::config::get_config;

// Authentication middleware
pub struct Authentication;

impl<S, B> Transform<S, ServiceRequest> for Authentication
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type InitError = ();
    type Transform = AuthenticationMiddleware<S>;
    type Future = Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        ok(AuthenticationMiddleware { service })
    }
}

pub struct AuthenticationMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for AuthenticationMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<B>;
    type Error = Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        // Skip authentication for health check
        if req.path() == "/api/health" {
            return Box::pin(self.service.call(req));
        }
        
        // Get API token from configuration
        let config = get_config();
        let api_token = config.api_token.clone();
        
        // Get authorization header
        let auth_header = req.headers().get("Authorization");
        
        // Check if authorization header exists
        if let Some(auth_header) = auth_header {
            // Convert header to string
            if let Ok(auth_str) = auth_header.to_str() {
                // Check if header starts with "Bearer "
                if auth_str.starts_with("Bearer ") {
                    // Extract token
                    let token = auth_str.trim_start_matches("Bearer ").trim();
                    
                    // Check if token matches API token
                    if token == api_token {
                        // Token is valid, proceed with request
                        return Box::pin(self.service.call(req));
                    }
                }
            }
        }
        
        // Token is invalid, return unauthorized
        error!("Unauthorized request: Invalid or missing API token");
        Box::pin(ready(Ok(req.into_response(
            HttpResponse::Unauthorized()
                .json(serde_json::json!({
                    "error": "Unauthorized",
                    "message": "Invalid or missing API token"
                }))
                .into_body(),
        ))))
    }
}

