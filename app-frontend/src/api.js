const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8000";

export async function login(username, password) {
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });
  if (!res.ok) throw new Error("Login failed");
  return res.json();
}

export async function listItems() {
  const res = await fetch(`${API_BASE}/items`);
  return res.json();
}

export async function searchItems(name) {
  const res = await fetch(`${API_BASE}/items/search?name=${encodeURIComponent(name)}`);
  return res.json();
}

export async function myItems(token) {
  const res = await fetch(`${API_BASE}/items/me`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.json();
}
