from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus
import bcrypt

app = FastAPI()

# Allow Flutter Web / Chrome to communicate with FastAPI
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MySQL database connection
DATABASE_URL = f"mysql+pymysql://root:{quote_plus('Aguitarstring@01')}@localhost:3306/exam_prep"

engine = create_engine(DATABASE_URL)


# Home endpoint
@app.get("/")
def home():
    return {"message": "Exam Prep API is running!"}


# Test database connection
@app.get("/test-db")
def test_database():
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))
        return {"database": "Connected successfully!"}


# Get questions from MySQL
@app.get("/questions")
def get_questions():
    with engine.connect() as connection:
        result = connection.execute(text("""
            SELECT
                q.question_id,
                q.question_text,
                q.option_a,
                q.option_b,
                q.option_c,
                q.option_d,
                q.correct_option,
                q.difficulty,
                q.discrimination,
                t.topic_name,
                t.subject
            FROM questions q
            JOIN topics t
            ON q.topic_id = t.topic_id
        """))

        questions = []

        for row in result:
            questions.append({
                "question_id": row.question_id,
                "question_text": row.question_text,
                "option_a": row.option_a,
                "option_b": row.option_b,
                "option_c": row.option_c,
                "option_d": row.option_d,
                "correct_option": row.correct_option,
                "difficulty": row.difficulty,
                "discrimination": row.discrimination,
                "topic_name": row.topic_name,
                "subject": row.subject
            })

        return questions


# ---------- Request models ----------

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class AbilityUpdateRequest(BaseModel):
    user_id: int
    ability: float


# ---------- Auth endpoints ----------

@app.post("/register")
def register(req: RegisterRequest):
    hashed = bcrypt.hashpw(req.password.encode("utf-8"), bcrypt.gensalt())

    with engine.connect() as connection:
        existing = connection.execute(
            text("SELECT user_id FROM users WHERE email = :email"),
            {"email": req.email}
        ).fetchone()

        if existing:
            raise HTTPException(status_code=400, detail="Email already registered")

        result = connection.execute(
            text("""
                INSERT INTO users (name, email, password, ability)
                VALUES (:name, :email, :password, 0.0)
            """),
            {"name": req.name, "email": req.email, "password": hashed.decode("utf-8")}
        )
        connection.commit()

        return {
            "user_id": result.lastrowid,
            "name": req.name,
            "email": req.email,
            "ability": 0.0
        }


@app.post("/login")
def login(req: LoginRequest):
    with engine.connect() as connection:
        row = connection.execute(
            text("SELECT user_id, name, email, password, ability FROM users WHERE email = :email"),
            {"email": req.email}
        ).fetchone()

        if not row:
            raise HTTPException(status_code=401, detail="Invalid email or password")

        if not bcrypt.checkpw(req.password.encode("utf-8"), row.password.encode("utf-8")):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        return {
            "user_id": row.user_id,
            "name": row.name,
            "email": row.email,
            "ability": row.ability
        }


# ---------- Save updated ability after a quiz ----------

@app.post("/update-ability")
def update_ability(req: AbilityUpdateRequest):
    with engine.connect() as connection:
        connection.execute(
            text("UPDATE users SET ability = :ability WHERE user_id = :user_id"),
            {"ability": req.ability, "user_id": req.user_id}
        )
        connection.commit()
        return {"status": "ok"}