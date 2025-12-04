# Getting Started with Create React App

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Available Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.\
You will also see any lint errors in the console.

### `npm test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

---

# How this project works (Overview)

This is a simple full-stack task manager application built with:
- Backend: Rust, Actix Web, SQLx, PostgreSQL
- Frontend: React with TypeScript (Create React App)
- Dev tooling: Docker Compose (for Postgres), PowerShell scripts for DB init, and npm/cargo for running front/back

The app demonstrates a small but complete data flow: the React UI reads and writes tasks via a REST API provided by the Rust backend, which persists tasks in a PostgreSQL database.

# Architecture & File Structure

- backend/api - Rust HTTP API project
	- `src/main.rs` - the API server. Key parts include:
		- `Task` model (Serializable JSON + DB extractable)
		- `NewTask` model (JSON input from client)
		- `health_check` (GET `/`) - a simple API health endpoint.
		- `get_tasks` (GET `/tasks`) - fetches all tasks from PostgreSQL using `sqlx::query_as`.
		- `create_task` (POST `/tasks`) - inserts a new task and returns it.
		- Database connection pool with `PgPool` configured via `DATABASE_URL`.
	- `Cargo.toml` - Rust dependencies (actix-web, sqlx, tokio, serde)
	- `README.md` - Backend-specific developer notes and Windows tooltips.

- backend - project-level utility files
	- `docker-compose.yml` - Starts a local PostgreSQL service for dev. The compose file maps the container's 5432 to host port `5433` to avoid conflicts.
	- `init_db.sql` - Schema used to create the `tasks` table.
	- `init-db.ps1` - Powershell helper script to run the SQL into either a `task_db` container or the `postgres` compose service.
	- `check-table.ps1` - Helper script that checks if the `tasks` table exists and runs `init-db.ps1` if not.

- frontend/web - React app
	- `src/App.tsx` - main UI: fetches tasks (`GET /tasks`) on mount and sends new tasks (`POST /tasks`).
	- `src/index.tsx` - React entry point.
	- `package.json` - Node dependencies and scripts (`npm start`, `npm run build`).

# Data flow (overview)

1. The React UI mounts and sends `GET http://127.0.0.1:8080/tasks` to the backend.
2. The backend receives the request in `get_tasks`, queries Postgres, and responds with JSON tasks.
3. On the UI, tasks are saved to React state and displayed in a list.
4. When a user adds a new task, the UI sends `POST http://127.0.0.1:8080/tasks` with a JSON body like `{ "title": "Buy milk" }`.
5. The backend inserts the task into the DB and returns the newly-created row; the frontend appends it into state.

# Backend details

- The Rust backend exposes 3 endpoints:
	- `GET /` - health check (returns a string)
	- `GET /tasks` - returns a JSON array of tasks
	- `POST /tasks` - accepts JSON with `title` and creates a task; returns new task
- It uses `actix-web` for routing and `actix-cors::Cors` to set a permissive CORS policy for development.
- DB connection config is loaded from the `DATABASE_URL` environment variable. Example:

```powershell
$env:DATABASE_URL = "postgres://task_user:task_pass@127.0.0.1:5433/task_manager"
cargo run
```

- If `DATABASE_URL` is not set the backend exits with a friendly message. If it cannot connect to the DB, the server will also exit and print the error message.

# Database (Postgres)

- Use the provided `docker-compose.yml` to run a local Postgres instance (it maps host port 5433 to container 5432).
- The dev schema is in `backend/init_db.sql` (creates `tasks` table). You can run `init-db.ps1` to apply the schema into the DB container. The helper `check-table.ps1` checks if the table exists and creates it if needed.

# Frontend details

- The React app uses TypeScript and the `App.tsx` component contains the simple UI with an input form and list of tasks.
- `App.tsx` sets `API_BASE_URL = "http://127.0.0.1:8080"` which should point to where the API server runs (port 8080).

# Quick start (local development)

Prerequisites:
- Rust & Cargo or WSL if you're on Windows and don't have MSVC set up
- Node.js & npm
- Docker & Docker Compose (for running Postgres)

Steps:
1. Start Postgres from the project root (the compose file lives in `backend`):

```powershell
cd backend
docker compose up -d
```

2. Initialize the DB (apply `init_db.sql` to the running DB):

```powershell
cd backend
.\init-db.ps1
```

3. Run the backend API

```powershell
cd backend\api
$env:DATABASE_URL = "postgres://task_user:task_pass@127.0.0.1:5433/task_manager"
cargo run
```

4. Start the frontend

```powershell
cd frontend/web
npm start
```

Open http://localhost:3000 in the browser to see the UI.

# Testing the API directly

Use `curl` or Postman to exercise endpoints:

```bash
# List tasks
curl http://127.0.0.1:8080/tasks

# Create a task
curl -X POST http://127.0.0.1:8080/tasks -H "Content-Type: application/json" -d '{"title":"Buy milk"}'
```

# Troubleshooting & notes

- If you run on Windows and see `link.exe not found` during Rust compile, install Build Tools for Visual Studio (Desktop development with C++) or use WSL.
- If you get `ERROR: DATABASE_URL must be set`, make sure you set `$env:DATABASE_URL` in the same PowerShell session where you run `cargo run`.
- If the backend fails with `relation "tasks" does not exist`, run `.\init-db.ps1` to create the table (or run `check-table.ps1`, which will call `init-db.ps1` if missing).
- If you have a host Postgres that uses port 5432, our docker-compose maps host port `5433` to the container's `5432` to avoid conflict.
- For production, you should:
	- Use proper DB credentials (not the weak defaults used here), and server-managed configuration.
	- Add a database migration system (like `sqlx migrate` or Flyway) instead of ad-hoc SQL.
	- Use CORS and secrets appropriately.

# Contributing

Feel free to add features: task editing, deletion, status toggling, or user accounts. Consider:
- Adding server-side validation & error handling
- Using a proper migration tool for the DB
- Adding unit and integration tests for both backend and frontend

---