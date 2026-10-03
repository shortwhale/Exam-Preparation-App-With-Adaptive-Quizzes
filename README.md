
# adaptive_quiz

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
Adaptive Quiz

An exam-prep mobile app that adjusts question difficulty in real time based on how the user is performing, using Item Response Theory (IRT) to estimate ability after every answer — instead of showing every student the same fixed set of questions in the same order.

Built as a PBL project for Database Systems Engineering and Distributed Backend Development.

Features
Login & Signup — secure authentication with bcrypt-hashed passwords
Persistent sessions — stay logged in between app restarts (via shared_preferences)
Adaptive question delivery — the next question shown is always the one whose difficulty best matches the user's current estimated ability
Real IRT (2-parameter logistic model) — ability is estimated using EAP (Expected A Posteriori), the same statistical approach used in real adaptive tests
Per-user ability tracking — your ability score is saved to the database and carried into your next quiz attempt
Tech Stack
Layer	Technology
Frontend	Flutter (Dart)
Backend	Python, FastAPI
Database	MySQL (via SQLAlchemy + PyMySQL)
Auth	bcrypt password hashing
Session storage	shared_preferences (Flutter)
Project Structure
adaptive_quiz/
├── lib/
│   ├── main.dart              # Flutter app: login, home, quiz, results, IRT logic
│   └── database_setup.sql     # MySQL schema + seed data
├── backend/
│   └── main.py                # FastAPI server: auth + question endpoints
├── android/, ios/, web/, ...  # Flutter platform folders
└── pubspec.yaml                # Flutter dependencies
Setup
1. Prerequisites
Flutter SDK (with Android Studio + an emulator, or Xcode for iOS/macOS)
Python 3 with pip
MySQL Server, running locally
2. Database

Create the database and seed it with sample data:

bash
mysql -u root -p < lib/database_setup.sql

This creates the exam_prep database with users, topics, questions, quiz_attempts, and answers tables.

3. Backend
bash
cd backend
python3 -m pip install fastapi uvicorn sqlalchemy pymysql bcrypt

Open backend/main.py and update the DATABASE_URL line with your own MySQL root password:

python
DATABASE_URL = f"mysql+pymysql://root:{quote_plus('YOUR_PASSWORD_HERE')}@localhost:3306/exam_prep"

quote_plus(...) is used so that special characters (like @) in your password don't break the connection string.

Start the server:

bash
python3 -m uvicorn main:app --reload --port 8000

Visit http://127.0.0.1:8000 — you should see {"message": "Exam Prep API is running!"}.

4. Frontend
bash
flutter pub get

Important — set the correct API address in lib/main.dart:

dart
const String apiBase = 'http://127.0.0.1:8000';
If running on Chrome or macOS desktop, leave this as 127.0.0.1.
If running on the Android emulator, change it to 10.0.2.2 — the emulator treats 127.0.0.1 as itself, not the host machine:
dart
  const String apiBase = 'http://10.0.2.2:8000';

Then run:

bash
flutter run
How the Adaptive Logic Works

Each question in the database has two extra properties:

difficulty (b) — how hard the question is
discrimination (a) — how sharply the question separates strong performers from weak ones

The probability of a user answering correctly at a given ability level (theta) is modeled with the standard 2-parameter logistic IRT formula:

P(correct | theta) = 1 / (1 + e^(-1.7 × a × (theta - b)))

After each answer, the app re-estimates theta using EAP: it tests a range of possible ability values, weighs each by how well it explains everything answered so far (plus a normal-distribution prior), and takes the probability-weighted average. Before the next question, the app picks whichever remaining question's difficulty is closest to the updated theta — harder if you're doing well, easier if you're not.

Database Schema (Summary)
users — user_id, name, email, password (bcrypt hash), ability, created_at
topics — subject/topic groupings for questions
questions — question text, 4 options, correct option, difficulty, discrimination, linked to a topic
quiz_attempts, answers — tables reserved for tracking quiz history per user
Known Limitations / Future Work
Only a small seed question bank is included — the adaptive effect becomes more noticeable with a larger, wider-ranging question pool
No per-topic breakdown yet (a "weak topics" view is a natural next step)
Single quiz session per run — no resuming a partially completed quiz
Team
Team ID: 2 | Section: S1
Vineetha — 2520030149
Mahitha — 2520030469
Guide: Dr. Purushotham Muniganti
Content
adaptive_quiz.zip

ZIP

PBL_Project_Poster_Template.pptx

PPTX

In lib/main.dart, find http.get(Uri.parse('http://127.0.0.1:8000/questions')) and change 127.0.0.1 to 10.0.2.2, since the emulator can't reach your Mac via 127.0.0.1.

database_setup.sql file

mahithareddy@Mahithas-MacBook-Air adaptive_quiz % flutter pub Commands for managing Flutter packages. Global options: -h, --help Print this usage information. -v, --verbose Noisy logging, including all shell commands executed. If used with

PASTED
>>>>>>> 6ce927e9a9cc18804e03f7a021d83ebd1262b093
