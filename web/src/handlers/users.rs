use actix_web::{get, HttpResponse, Responder};
use askama::Template;
use log::{error, info};

use crate::config::get_config;
use crate::models::{PageData, User, UsersPageData};
use crate::utils::ApiClient;

#[derive(Template)]
#[template(path = "users.html")]
struct UsersTemplate {
    page_data: UsersPageData,
}

#[get("/users")]
pub async fn users_page() -> impl Responder {
    let config = get_config();
    
    // Create API client
    let api_client = ApiClient::new();
    
    // Get users from API
    let users = match api_client.get::<Vec<User>>("/api/users").await {
        Ok(users) => users,
        Err(e) => {
            error!("Failed to get users: {}", e);
            Vec::new()
        }
    };
    
    info!("Fetched {} users", users.len());
    
    // Create page data
    let page_data = UsersPageData {
        page: PageData {
            title: "Users".to_string(),
            description: Some("User management".to_string()),
            environment: config.environment.clone(),
        },
        users,
    };
    
    // Render template
    let template = UsersTemplate { page_data };
    
    match template.render() {
        Ok(html) => HttpResponse::Ok().content_type("text/html").body(html),
        Err(e) => {
            error!("Template error: {}", e);
            HttpResponse::InternalServerError().body("Template error")
        }
    }
}

