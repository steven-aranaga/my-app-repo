use actix_web::{delete, get, post, put, web, HttpResponse, Responder};
use log::{error, info};
use serde_json::json;

use crate::models::{CreateUserRequest, UpdateUserRequest, UserResponse};
use crate::utils::password;

#[get("")]
pub async fn get_users() -> impl Responder {
    // TODO: Implement database query
    // For now, return mock data
    let users = vec![
        UserResponse {
            id: 1,
            username: "admin".to_string(),
            email: "admin@example.com".to_string(),
            is_active: true,
            is_admin: true,
            created_at: "2023-01-01T00:00:00Z".to_string(),
            updated_at: "2023-01-01T00:00:00Z".to_string(),
        },
        UserResponse {
            id: 2,
            username: "user".to_string(),
            email: "user@example.com".to_string(),
            is_active: true,
            is_admin: false,
            created_at: "2023-01-02T00:00:00Z".to_string(),
            updated_at: "2023-01-02T00:00:00Z".to_string(),
        },
    ];
    
    HttpResponse::Ok().json(users)
}

#[get("/{id}")]
pub async fn get_user(path: web::Path<i64>) -> impl Responder {
    let user_id = path.into_inner();
    
    // TODO: Implement database query
    // For now, return mock data
    if user_id == 1 {
        let user = UserResponse {
            id: 1,
            username: "admin".to_string(),
            email: "admin@example.com".to_string(),
            is_active: true,
            is_admin: true,
            created_at: "2023-01-01T00:00:00Z".to_string(),
            updated_at: "2023-01-01T00:00:00Z".to_string(),
        };
        
        HttpResponse::Ok().json(user)
    } else if user_id == 2 {
        let user = UserResponse {
            id: 2,
            username: "user".to_string(),
            email: "user@example.com".to_string(),
            is_active: true,
            is_admin: false,
            created_at: "2023-01-02T00:00:00Z".to_string(),
            updated_at: "2023-01-02T00:00:00Z".to_string(),
        };
        
        HttpResponse::Ok().json(user)
    } else {
        HttpResponse::NotFound().json(json!({
            "error": "User not found"
        }))
    }
}

#[post("")]
pub async fn create_user(user: web::Json<CreateUserRequest>) -> impl Responder {
    // Hash password
    let password_hash = match password::hash_password(&user.password) {
        Ok(hash) => hash,
        Err(e) => {
            error!("Failed to hash password: {}", e);
            return HttpResponse::InternalServerError().json(json!({
                "error": "Failed to hash password"
            }));
        }
    };
    
    // TODO: Implement database query
    // For now, return mock data
    let user_response = UserResponse {
        id: 3,
        username: user.username.clone(),
        email: user.email.clone(),
        is_active: true,
        is_admin: user.is_admin.unwrap_or(false),
        created_at: "2023-01-03T00:00:00Z".to_string(),
        updated_at: "2023-01-03T00:00:00Z".to_string(),
    };
    
    info!("Created user: {}", user.username);
    
    HttpResponse::Created().json(user_response)
}

#[put("/{id}")]
pub async fn update_user(path: web::Path<i64>, user: web::Json<UpdateUserRequest>) -> impl Responder {
    let user_id = path.into_inner();
    
    // TODO: Implement database query
    // For now, return mock data
    if user_id == 1 || user_id == 2 {
        let user_response = UserResponse {
            id: user_id,
            username: user.username.clone().unwrap_or_else(|| if user_id == 1 { "admin".to_string() } else { "user".to_string() }),
            email: user.email.clone().unwrap_or_else(|| if user_id == 1 { "admin@example.com".to_string() } else { "user@example.com".to_string() }),
            is_active: user.is_active.unwrap_or(true),
            is_admin: user.is_admin.unwrap_or_else(|| user_id == 1),
            created_at: if user_id == 1 { "2023-01-01T00:00:00Z".to_string() } else { "2023-01-02T00:00:00Z".to_string() },
            updated_at: "2023-01-03T00:00:00Z".to_string(),
        };
        
        info!("Updated user: {}", user_response.username);
        
        HttpResponse::Ok().json(user_response)
    } else {
        HttpResponse::NotFound().json(json!({
            "error": "User not found"
        }))
    }
}

#[delete("/{id}")]
pub async fn delete_user(path: web::Path<i64>) -> impl Responder {
    let user_id = path.into_inner();
    
    // TODO: Implement database query
    // For now, return mock data
    if user_id == 1 || user_id == 2 {
        info!("Deleted user with ID: {}", user_id);
        
        HttpResponse::NoContent().finish()
    } else {
        HttpResponse::NotFound().json(json!({
            "error": "User not found"
        }))
    }
}

