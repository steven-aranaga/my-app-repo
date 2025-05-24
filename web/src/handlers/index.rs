use actix_web::{get, HttpResponse, Responder};
use askama::Template;
use log::error;

use crate::config::get_config;
use crate::models::PageData;

#[derive(Template)]
#[template(path = "index.html")]
struct IndexTemplate {
    page_data: PageData,
}

#[derive(Template)]
#[template(path = "about.html")]
struct AboutTemplate {
    page_data: PageData,
}

#[get("/")]
pub async fn index() -> impl Responder {
    let config = get_config();
    
    let page_data = PageData {
        title: "Home".to_string(),
        description: Some("Welcome to My App".to_string()),
        environment: config.environment.clone(),
    };
    
    let template = IndexTemplate { page_data };
    
    match template.render() {
        Ok(html) => HttpResponse::Ok().content_type("text/html").body(html),
        Err(e) => {
            error!("Template error: {}", e);
            HttpResponse::InternalServerError().body("Template error")
        }
    }
}

#[get("/about")]
pub async fn about() -> impl Responder {
    let config = get_config();
    
    let page_data = PageData {
        title: "About".to_string(),
        description: Some("About My App".to_string()),
        environment: config.environment.clone(),
    };
    
    let template = AboutTemplate { page_data };
    
    match template.render() {
        Ok(html) => HttpResponse::Ok().content_type("text/html").body(html),
        Err(e) => {
            error!("Template error: {}", e);
            HttpResponse::InternalServerError().body("Template error")
        }
    }
}

