import { useState } from "react";
import Login from "./components/Login";
import Items from "./components/Items";

export default function App() {
  const [token, setToken] = useState(null);

  return (
    <div style={{ fontFamily: "sans-serif", maxWidth: 600, margin: "2rem auto" }}>
      <h1>DevSecOps Demo App</h1>
      {!token && <Login onLoggedIn={setToken} />}
      {token && <p>Logged in.</p>}
      <Items token={token} />
      {/*
        NOTE: There is deliberately no "Admin" link/route here, even for an
        admin user — the app never checks is_admin client-side either.
        GET /admin/users on the API is reachable directly regardless of
        what this UI shows or hides. See VULNERABILITIES.md.
      */}
    </div>
  );
}
