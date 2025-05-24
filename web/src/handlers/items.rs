use actix_web::{get, HttpResponse, Responder};
use askama::Template;
use log::{error, info};

use crate::config::get_config;
use crate::models::{PageData, Item, ItemsPageData};
use crate::utils::ApiClient;

#[derive(Template)]
#[template(path = "items.html")]
struct ItemsTemplate {
    page_data: ItemsPageData,
}

#[get("/items")]
pub async fn items_page() -> impl Responder {
    let config = get_config();
    
    // Create API client
    let api_client = ApiClient::new();
    
    // Get items from API
    let items = match api_client.get::<Vec<Item>>("/api/items").await {
        Ok(items) => items,
        Err(e) => {
            error!("Failed to get items: {}", e);
            Vec::new()
        }
    };
    
    info!("Fetched {} items", items.len());
    
    // Create page data
    let page_data = ItemsPageData {
        page: PageData {
            title: "Items".to_string(),
            description: Some("Item management".to_string()),
            environment: config.environment.clone(),
        },
        items,
    };
    
    // Render template
    let template = ItemsTemplate { page_data };
    
    match template.render() {
        Ok(html) => HttpResponse::Ok().content_type("text/html").body(html),
        Err(e) => {
            error!("Template error: {}", e);
            HttpResponse::InternalServerError().body("Template error")
        }
    }
}

