use actix_cors::Cors;
use actix_web::{App, HttpServer, middleware, web};
use env_logger::Env;
use log::{info, error};

mod config;
mod handlers;
mod middleware;
mod models;
mod utils;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Initialize environment
    dotenv::dotenv().ok();
    
    // Initialize logger
    env_logger::init_from_env(Env::default().default_filter_or(&config::get_config().log_level));
    
    // Get configuration
    let config = config::get_config();
    
    info!("Starting API server in {} mode", config.environment);
    info!("Listening on {}:{}", config.api_host, config.api_port);
    
    // Start HTTP server
    HttpServer::new(|| {
        // Configure CORS
        let cors = Cors::default()
            .allowed_origin("http://localhost")
            .allowed_origin("http://localhost:80")
            .allowed_origin("http://localhost:3000")
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE"])
            .allowed_headers(vec!["Authorization", "Content-Type"])
            .max_age(3600);
            
        App::new()
            // Enable logger
            .wrap(middleware::Logger::default())
            // Enable CORS
            .wrap(cors)
            // Enable authentication middleware
            .wrap(middleware::auth::Authentication)
            
            // API routes
            .service(
                web::scope("/api")
                    // Health check
                    .service(handlers::health::health_check)
                    // Users
                    .service(
                        web::scope("/users")
                            .service(handlers::users::get_users)
                            .service(handlers::users::get_user)
                            .service(handlers::users::create_user)
                            .service(handlers::users::update_user)
                            .service(handlers::users::delete_user)
                    )
                    // Items
                    .service(
                        web::scope("/items")
                            .service(handlers::items::get_items)
                            .service(handlers::items::get_item)
                            .service(handlers::items::create_item)
                            .service(handlers::items::update_item)
                            .service(handlers::items::delete_item)
                    )
            )
    })
    .bind(format!("{}:{}", config.api_host, config.api_port))?
    .run()
    .await
}
