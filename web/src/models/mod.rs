use serde::{Deserialize, Serialize};

// User model
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct User {
    pub id: i64,
    pub username: String,
    pub email: String,
    pub is_active: bool,
    pub is_admin: bool,
    pub created_at: String,
    pub updated_at: String,
}

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

// Page data model
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct PageData {
    pub title: String,
    pub description: Option<String>,
    pub environment: String,
}

// Users page data model
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct UsersPageData {
    pub page: PageData,
    pub users: Vec<User>,
}

// Items page data model
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ItemsPageData {
    pub page: PageData,
    pub items: Vec<Item>,
}

