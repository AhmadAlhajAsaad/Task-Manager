use actix_cors::Cors;
use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use serde::{Serialize, Deserialize};

// Model (Model) for a single task that we send/receive as JSON
#[derive(Serialize)]
struct Task {
    id: i32,
    title: String,
    completed: bool,
}

// Sample data coming from the Frontend when creating a new task
#[derive(Deserialize)]
struct NewTask {
    title: String,
}

// Endpoint is simple to make sure the API is working
#[get("/")]
async fn health_check() -> impl Responder {
    HttpResponse::Ok().body("Rust Task Manager API is running 🚀")
}

// GET /tasks → Returns a static task list (Dummy data)
async fn get_tasks() -> impl Responder {
    let tasks = vec![
        Task { id: 1, title: "Learn Rust".to_string(), completed: false },
        Task { id: 2, title: "Build Task Manager backend".to_string(), completed: false },
        Task { id: 3, title: "Connect React frontend".to_string(), completed: false },
    ];

    HttpResponse::Ok().json(tasks)
}

// POST /tasks → Receives the address of a new task and returns it as a data-complete task
async fn create_task(task: web::Json<NewTask>) -> impl Responder {
    let created_task = Task {
        id: 1,
        title: task.title.clone(),
        completed: false,
    };

    HttpResponse::Created().json(created_task)
}

// Application entry point
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("🚀 Server running at http://127.0.0.1:8080");

    HttpServer::new(|| {
        App::new()
        // Allow frontend to access backend (CORS)
            .wrap(
                Cors::default()
                    .allow_any_origin()
                    .allow_any_method()
                    .allow_any_header()
            )
            .service(health_check)                         // GET /
            .route("/tasks", web::get().to(get_tasks))     // GET /tasks
            .route("/tasks", web::post().to(create_task))  // POST /tasks
    })
    .bind(("127.0.0.1", 8080))?//if you use 8081, modify here and in React
    .run()
    .await
}
