# Task Manager - Backend (API) - Development Guide

This folder contains the Rust backend for the Task Manager app.

## Windows prerequisites (MSVC toolchain)

If you are on Windows and you see the following error when building:

```
error: linker `link.exe` not found
```

It means the MSVC linker is missing from your system. There are two common ways to fix this:

### 1) Install Visual Studio Build Tools (recommended)

1. Download the Build Tools for Visual Studio from Microsoft:
   https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Run the installer and select the **"Desktop development with C++"** workload.
3. After install, restart your terminal (PowerShell) and try building again.

### 2) Alternatively use WSL (Windows Subsystem for Linux)

1. Install WSL and a Linux distribution (Ubuntu recommended):
   - In PowerShell (as administrator): `wsl --install -d Ubuntu`
2. Open WSL (Ubuntu) and run `sudo apt update && sudo apt install build-essential`.
3. Build the project inside WSL (Linux builds don't rely on the MSVC toolchain).

### 3) Or use the GNU toolchain for Rust (MSYS2/mingw-w64)

If you prefer to not install the Visual Studio Build Tools, you can use the `gnu` toolchain.
- Install MSYS2 and mingw toolchain, then install `stable-x86_64-pc-windows-gnu` via rustup.
- Note: This is a heavier setup but avoids requiring `link.exe`.


## Run the API locally

You can bring up a local PostgreSQL database using Docker Compose (recommended):

```powershell
cd ..
docker compose up -d
```
## From Windows, check if the DB port 5433 is reachable:
```powershell
cd ..
Test-NetConnection -ComputerName 127.0.0.1 -Port 5433
```

Then configure a `DATABASE_URL`, initialize the database (if needed) and run the server:

```powershell
# From project root - start Postgres with Docker (backend/docker-compose.yml)
cd backend
docker compose up -d

# Initialize the schema (creates "tasks" table)
.\init-db.ps1

# Run the API (set DATABASE_URL and run from backend/api). Note: the compose file maps the container to host port 5433 to avoid conflicts with local Postgres instances.
#Connected to PostgreSQL
cd api
$env:DATABASE_URL = "postgres://task_user:task_pass@127.0.0.1:5433/task_manager"
cargo run
```

If you prefer to run PostgreSQL manually, you still need a valid `DATABASE_URL` env var pointing to your database.

If you do not want to run a database, you can still build locally, but runtime features depending on the DB will need a live database to function.

## Troubleshooting

- Run first cd: `$env:DATABASE_URL = "postgres://task_user:task_pass@127.0.0.1:5433/task_manager"`

- If you cannot build due to `link.exe` missing, follow the steps above.
- If `cargo run` panics because `DATABASE_URL` isn't set, set the environment variable before running.
