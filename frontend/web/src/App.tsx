import { useEffect, useState, FormEvent } from "react";
import "./App.css";

interface Task {
  id: number;
  title: string;
  completed: boolean;
}

function App() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [newTitle, setNewTitle] = useState<string>(""); // New task title
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  //de poort hier backend 8080 moet overeenkomen met die in backend api main.rs
  const API_BASE_URL = "http://127.0.0.1:8080";

// Fetch tasks from Rust API
  useEffect(() => {
    fetch(`${API_BASE_URL}/tasks`)
      .then((response) => response.json())
      .then((data) => setTasks(data))
      .catch((err) => {
        console.error("Error fetching tasks:", err);
        setError("Failed to load tasks from backend");
      });
  }, []);

  // Send a new task to the backend
  const handleAddTask = async (e: FormEvent) => {
    e.preventDefault(); // Prevent page reloading

    if (!newTitle.trim()) {
      return; // Do not send if the text is empty
    }

    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`${API_BASE_URL}/tasks`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ title: newTitle }),
      });

      if (!response.ok) {
        throw new Error("Failed to create task");
      }

      const createdTask: Task = await response.json();

// Add the new task to the to-do list
    setTasks((prev) => [...prev, createdTask]);
      setNewTitle(""); // Decid the input field
    } catch (err) {
      console.error(err);
      setError("Failed to create task");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app-container">
      <h1>Task Manager (Rust + React)</h1>

      {/* Display error if any */}
      {error && (
        <p className="error-text">
          {error}
        </p>
      )}

      {/*Form Add new task*/}
     <form onSubmit={handleAddTask} className="task-form">
        <input
          className="task-input"
          type="text"
          placeholder="Enter new task title..."
          value={newTitle}
          onChange={(e) => setNewTitle(e.target.value)}
        />
        <button type="submit" disabled={loading}>
          {loading ? "Adding..." : "Add Task"}
        </button>
      </form>

      <h2>Tasks:</h2>
      {tasks.length === 0 ? (
        <p>No tasks yet.</p>
      ) : (
        <ul>
          {tasks.map((t) => (
            <li key={t.id}>
              {t.title} — {t.completed ? "✔️ Done" : "⏳ Pending"}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default App;