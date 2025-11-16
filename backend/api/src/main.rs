use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use serde::Serialize;

// Model (Model) for a single task
#[derive(Serialize)]
struct Task {
    id: i32,
    title: String,
    completed: bool,
}

// Endpoint is simple to make sure the API is working
#[get("/")]
async fn health_check() -> impl Responder {
    HttpResponse::Ok().body("Rust Task Manager API is running 🚀")
}

// Endpoint Returns a fixed to-do list (Dummy data) 
async fn get_tasks() -> impl Responder {
    // Interim experimental data 
    let tasks = vec![
        Task { id: 1, title: "Learn Rust".to_string(), completed: false },
        Task { id: 2, title: "Build Task Manager backend".to_string(), completed: false },
        Task { id: 3, title: "Connect React frontend".to_string(), completed: false },
    ];
  //http://127.0.0.1:8080/tasks
    HttpResponse::Ok().json(tasks) // return JSON  response
}

// Application entry point
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("🚀 Server running at http://127.0.0.1:8080");

    HttpServer::new(|| {
        App::new()
            .service(health_check)                 // GET /
            .route("/tasks", web::get().to(get_tasks)) // GET /tasks
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
