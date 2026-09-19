// Relative path, proxied by nginx to the API service internally (see
// nginx.conf). This deliberately avoids baking an absolute API URL into
// the JS bundle at build time (Vite env vars are compile-time only) -
// the API's actual address doesn't exist until after deploy, so a
// build-time absolute URL would be a chicken-and-egg problem. Same-origin
// requests via the proxy also mean CORS is no longer needed in main.py.
const API_BASE = "/api";

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