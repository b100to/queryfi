from fastapi import Depends, FastAPI

from sqlalchemy.orm import Session

from core.db import get_db
from src.models.user import User

app = FastAPI()


@app.get('/')
async def root():
    return {'message': 'hello world!'}

@app.get("/users/")
async def read_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return users


@app.post("/users/")
async def read_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return users

@app.put("/users/{pk}")
async def read_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return users

@app.delete("/users/{pk}")
async def read_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return users