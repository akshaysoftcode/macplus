from pydantic import BaseModel
from typing import Optional


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class Item(BaseModel):
    id: Optional[int] = None
    name: str
    description: str
    owner_id: Optional[int] = None


class User(BaseModel):
    id: Optional[int] = None
    username: str
    is_admin: bool = False
