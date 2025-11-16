import { useEffect, useState } from "react";

interface Task {
  id: number;
  title: string;
  completed: boolean;
}

function App() {
  const [tasks, setTasks] = useState<Task[]>([]);

// Fetch tasks from Rust API
  useEffect(() => {
    fetch("http://127.0.0.1:8080/tasks")
      .then((response) => response.json())
      .then((data) => setTasks(data))
      .catch((err) => console.error("Error fetching tasks:", err));
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Task Manager (Rust + React)</h1>

      <h2>Tasks:</h2>
      <ul>
        {tasks.map((t) => (
          <li key={t.id}>
            {t.title} — {t.completed ? "✔️ Done" : "⏳ Pending"}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
