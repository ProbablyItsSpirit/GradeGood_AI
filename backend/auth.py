import firebase_admin
from firebase_admin import credentials, auth, firestore
from fastapi import APIRouter, HTTPException, Depends, Body
from pydantic import BaseModel
from typing import Optional
import os


# Check if Firebase is already initialized
if not firebase_admin._apps:
    try:
        # Use os.path.join for cross-platform compatibility
        cred_path = os.path.join(os.path.dirname(__file__), "firebase-admin-sdk.json")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print(f"✅ Firebase initialized successfully with credentials from auth.py")
    except Exception as e:
        print(f"❌ Error initializing Firebase in auth.py: {str(e)}")

# ✅ Firestore DB
db = firestore.client()

# ✅ FastAPI Router
router = APIRouter()

### 📌 User Data Model ###
# Key parts of the backend auth system:

# 1. Pydantic model ensures data validation
class User(BaseModel):
    uid: str
    name: str
    email: str
    role: str  # "teacher" or "student"

### 📌 Google Login / Signup Endpoint ###
# 2. Login endpoint handles both login and signup
@router.post("/login")
async def login_user(user: User = Body(...)):
    """Handles login/signup and stores user info in Firestore."""

    try:
        print(f"Received login/signup request for user: {user.email}, role: {user.role}")
        
        # ✅ Check if user exists in Firestore
        user_ref = db.collection("users").document(user.uid)
        user_doc = user_ref.get()

        if user_doc.exists:
            print(f"User {user.email} exists, updating last login time")
            # Update the last login time
            user_ref.update({
                "last_login": firestore.SERVER_TIMESTAMP
            })
            return {"message": "Login successful!", "user_data": user_doc.to_dict()}

        # ✅ New user → Save to Firestore
        print(f"Creating new user: {user.email}, role: {user.role}")
        user_data = {
            "uid": user.uid,
            "name": user.name,
            "email": user.email,
            "role": user.role,  # "teacher" or "student"
            "created_at": firestore.SERVER_TIMESTAMP,
            "last_login": firestore.SERVER_TIMESTAMP
        }
        user_ref.set(user_data)

        return {"message": "User registered!", "user_data": user_data}

    except Exception as e:
        print(f"Error in login_user: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
