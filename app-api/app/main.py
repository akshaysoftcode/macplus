from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware

from app.database import get_conn
from app.models import LoginRequest, TokenResponse, Item, User
from app.auth import create_access_token, verify_password, get_current_user

app = FastAPI(title="DevSecOps Demo API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # fine for local demo; tighten before any real deploy
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/auth/login", response_model=TokenResponse)
def login(payload: LoginRequest):
    with get_conn() as conn:
        with conn.cursor() as cur:
            # Parameterized correctly -- contrast this with /items/search below.
            cur.execute(
                "SELECT id, username, password_hash, is_admin FROM users WHERE username = %s",
                (payload.username,),
            )
            user = cur.fetchone()

    if not user or not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token(user["username"], is_admin=user["is_admin"])
    return TokenResponse(access_token=token)


@app.get("/items", response_model=list[Item])
def list_items():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name, description, owner_id FROM items ORDER BY id")
            return cur.fetchall()


@app.get("/items/search")
def search_items(name: str = Query(...)):
    """
    --- INTENTIONAL VULN: SQL INJECTION (OWASP A03) ---
    User input is concatenated directly into the query string instead of
    being parameterized. This is the exact contrast case against login()
    above, and is what Semgrep/SonarCloud (static) and OWASP ZAP (dynamic,
    e.g. ?name=' OR '1'='1) are expected to flag. DO NOT fix this until
    Chapter 6/8 — it's the target, not a bug.
    """
    with get_conn() as conn:
        with conn.cursor() as cur:
            query = f"SELECT id, name, description, owner_id FROM items WHERE name LIKE '%{name}%'"
            cur.execute(query)
            return cur.fetchall()


@app.get("/items/me", response_model=list[Item])
def my_items(current_user: dict = Depends(get_current_user)):
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT i.id, i.name, i.description, i.owner_id FROM items i "
                "JOIN users u ON u.id = i.owner_id WHERE u.username = %s",
                (current_user["sub"],),
            )
            return cur.fetchall()


@app.get("/admin/users", response_model=list[User])
def admin_list_users():
    """
    --- INTENTIONAL VULN: BROKEN ACCESS CONTROL (OWASP A01) ---
    No auth dependency at all on an admin-only endpoint. Anyone who guesses
    or discovers this path can dump every user. The frontend never links
    here for non-admins, but that's a UI-layer nicety, not a control -- and
    that gap is exactly what this endpoint exists to demonstrate.
    Expected to be caught by: Semgrep (missing-auth-check rule) and ZAP's
    authenticated scan (accessible without an admin token).
    """
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, username, is_admin FROM users ORDER BY id")
            return cur.fetchall()
