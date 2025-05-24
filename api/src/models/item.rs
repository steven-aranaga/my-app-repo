use serde::{Deserialize, Serialize};

// Item model
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Item {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    pub user_id: i64,
    pub created_at: String,
    pub updated_at: String,
}

// Item creation request
#[derive(Debug, Serialize, Deserialize)]
pub struct CreateItemRequest {
    pub name: String,
    pub description: Option<String>,
    pub user_id: i64,
}

// Item update request
#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateItemRequest {
    pub name: Option<String>,
    pub description: Option<String>,
    pub user_id: Option<i64>,
}

// Item response
#[derive(Debug, Serialize, Deserialize)]
pub struct ItemResponse {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    pub user_id: i64,
    pub created_at: String,
    pub updated_at: String,
}

// Item list response
#[derive(Debug, Serialize, Deserialize)]
pub struct ItemListResponse {
    pub items: Vec<ItemResponse>,
    pub total: usize,
}

