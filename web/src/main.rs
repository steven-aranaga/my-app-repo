use actix_files as fs;
use actix_web::{App, HttpServer, middleware, web};
use env_logger::Env;
use log::{info, error};

mod config;
mod handlers;
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
    
    info!("Starting web server in {} mode", config.environment);
    info!("Listening on {}:{}", config.web_host, config.web_port);
    
    // Start HTTP server
    HttpServer::new(|| {
        App::new()
            // Enable logger
            .wrap(middleware::Logger::default())
            
            // Register services
            .service(handlers::index::index)
            .service(handlers::index::about)
            .service(handlers::users::users_page)
            .service(handlers::items::items_page)
            
            // Static files
            .service(fs::Files::new("/static", "./static").show_files_listing(false))
            
            // Default handler
            .default_service(web::to(|| async { "404 Not Found" }))
    })
    .bind(format!("{}:{}", config.web_host, config.web_port))?
    .run()
    .await
}

