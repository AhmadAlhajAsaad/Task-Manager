use actix_cors::Cors;
use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use serde::{Serialize, Deserialize};
use sqlx::{FromRow, PgPool};
use std::time::Duration;
use tokio::time::sleep;
use sqlx::postgres::PgPoolOptions;

// Model (Model) for a single task that we send/receive as JSON
#[derive(Serialize, FromRow)]
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
    HttpResponse::Ok().body("Rust Task Manager API is running!")
}

// GET /tasks → Fetch tasks from database
async fn get_tasks(db_pool: web::Data<PgPool>) -> impl Responder {
    let result = sqlx::query_as::<_, Task>(
        "SELECT id, title, completed FROM tasks ORDER BY id"
    )
    .fetch_all(db_pool.get_ref())
    .await;

    match result {
        Ok(tasks) => HttpResponse::Ok().json(tasks),
        Err(e) => {
            println!("DB error in get_tasks: {e}");
            HttpResponse::InternalServerError().body("Failed to fetch tasks")
        }
    }
}

// POST /tasks → Creates a new task in the database and returns it
async fn create_task(
    db_pool: web::Data<PgPool>,
    task: web::Json<NewTask>
) -> impl Responder {
    let result = sqlx::query_as::<_, Task>(
        "INSERT INTO tasks (title, completed) VALUES ($1, false)
         RETURNING id, title, completed"
    )
    .bind(&task.title)
    .fetch_one(db_pool.get_ref())
    .await;

    match result {
        Ok(created_task) => HttpResponse::Created().json(created_task),
        Err(e) => {
            println!("DB error in create_task: {e}");
            HttpResponse::InternalServerError().body("Failed to create task")
        }
    }
}

// Application entry point
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Read DATABASE_URL from environment variables
    let database_url = match std::env::var("DATABASE_URL") {
        Ok(url) => url,
        Err(_) => {
            eprintln!("ERROR: DATABASE_URL must be set. Example: postgres://user:pass@localhost:5432/task_manager");
            std::process::exit(1);
        }
    };

    // Create a pool to connect to the database
    // Try to connect to Postgres with a simple retry/backoff strategy.
    let mut attempts = 0u8;
    let db_pool = loop {
        match PgPoolOptions::new().max_connections(5).connect(&database_url).await {
            Ok(pool) => break pool,
            Err(err) => {
                attempts += 1;
                eprintln!("ERROR: Failed to connect to database on attempt {}: {}", attempts, err);
                if attempts >= 5 {
                    eprintln!("ERROR: Giving up after {} attempts.", attempts);
                    std::process::exit(1);
                }
                // Wait a bit before retrying
                sleep(Duration::from_secs(2)).await;
            }
        }
    };

    println!("✅ Connected to PostgreSQL");
    println!("🚀 Server running at http://127.0.0.1:8080");

    HttpServer::new(move || {
        App::new()
            .wrap(
                Cors::default()
                    .allow_any_origin()
                    .allow_any_method()
                    .allow_any_header()
            )
            .app_data(web::Data::new(db_pool.clone()))
            .service(health_check)                         // GET /
            .route("/tasks", web::get().to(get_tasks))     // GET /tasks
            .route("/tasks", web::post().to(create_task))  // POST /tasks
    })
    .bind(("127.0.0.1", 8080))? // Change the port if you need    
    .run()
    .await
}