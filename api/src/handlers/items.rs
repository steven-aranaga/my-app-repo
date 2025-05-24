use actix_web::{delete, get, post, put, web, HttpResponse, Responder};
use log::{error, info};
use serde_json::json;

use crate::models::{CreateItemRequest, UpdateItemRequest, ItemResponse};

#[get("")]
pub async fn get_items() -> impl Responder {
    // TODO: Implement database query
    // For now, return mock data
    let items = vec![
        ItemResponse {
            id: 1,
            name: "Item 1".to_string(),
            description: Some("Description for Item 1".to_string()),
            user_id: 1,
            created_at: "2023-01-01T00:00:00Z".to_string(),
            updated_at: "2023-01-01T00:00:00Z".to_string(),
        },
        ItemResponse {
            id: 2,
            name: "Item 2".to_string(),
            description: Some("Description for Item 2".to_string()),
            user_id: 2,
            created_at: "2023-01-02T00:00:00Z".to_string(),
            updated_at: "2023-01-02T00:00:00Z".to_string(),
        },
    ];
    
    HttpResponse::Ok().json(items)
}

#[get("/{id}")]
pub async fn get_item(path: web::Path<i64>) -> impl Responder {
    let item_id = path.into_inner();
    
    // TODO: Implement database query
    // For now, return mock data
    if item_id == 1 {
        let item = ItemResponse {
            id: 1,
            name: "Item 1".to_string(),
            description: Some("Description for Item 1".to_string()),
            user_id: 1,
            created_at: "2023-01-01T00:00:00Z".to_string(),
            updated_at: "2023-01-01T00:00:00Z".to_string(),
        };
        
        HttpResponse::Ok().json(item)
    } else if item_id == 2 {
        let item = ItemResponse {
            id: 2,
            name: "Item 2".to_string(),
            description: Some("Description for Item 2".to_string()),
            user_id: 2,
            created_at: "2023-01-02T00:00:00Z".to_string(),
            updated_at: "2023-01-02T00:00:00Z".to_string(),
        };
        
        HttpResponse::Ok().json(item)
    } else {
        HttpResponse::NotFound().json(json!({
            "error": "Item not found"
        }))
    }
}

#[post("")]
pub async fn create_item(item: web::Json<CreateItemRequest>) -> impl Responder {
    // TODO: Implement database query
    // For now, return mock data
    let item_response = ItemResponse {
        id: 3,
        name: item.name.clone(),
        description: item.description.clone(),
        user_id: item.user_id,
        created_at: "2023-01-03T00:00:00Z".to_string(),
        updated_at: "2023-01-03T00:00:00Z".to_string(),
    };
    
    info!("Created item: {}", item.name);
    
    HttpResponse::Created().json(item_response)
}

#[put("/{id}")]
pub async fn update_item(path: web::Path<i64>, item: web::Json<UpdateItemRequest>) -> impl Responder {
    let item_id = path.into_inner();
    
    // TODO: Implement database query
    // For now, return mock data
    if item_id == 1 || item_id == 2 {
        let item_response = ItemResponse {
            id: item_id,
            name: item.name.clone().unwrap_or_else(|| if item_id == 1 { "Item 1".to_string() } else { "Item 2".to_string() }),
            description: item.description.clone().or_else(|| if item_id == 1 { Some("Description for Item 1".to_string()) } else { Some("Description for Item 2".to_string()) }),
            user_id: item.user_id.unwrap_or_else(|| if item_id == 1 { 1 } else { 2 }),
            created_at: if item_id == 1 { "2023-01-01T00:00:00Z".to_string() } else { "2023-01-02T00:00:00Z".to_string() },
            updated_at: "2023-01-03T00:00:00Z".to_string(),
        };
        
        info!("Updated item: {}", item_response.name);
        
        HttpResponse::Ok().json(item_response)
    } else {
        HttpResponse::NotFound().json(json!({
            "error": "Item not found"
        }))
    }
}

#[delete("/{id}")]
pub async fn delete_item(path: web::Path<i64>) -> impl Responder {
    let item_id = path.into_inner();
    
    // TODO: Implement database query
    // For now, return mock data
    if item_id == 1 || item_id == 2 {
        info!("Deleted item with ID: {}", item_id);
        
        HttpResponse::NoContent().finish()
    } else {
        HttpResponse::NotFound().json(json!({
            "error": "Item not found"
        }))
    }
}

