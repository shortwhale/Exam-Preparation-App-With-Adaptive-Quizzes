# Exam Preparation App with Adaptive Quizzes

An adaptive exam preparation application that provides personalized quizzes based on the learner's performance. The system combines a Flutter/Dart mobile application with a structured database and an Item Response Theory (IRT)-based adaptive quiz engine.

##  Project Overview

The **Exam Preparation App with Adaptive Quizzes** is designed to improve the traditional fixed-quiz approach by dynamically selecting questions according to the learner's demonstrated performance.

The application stores users, subjects, topics, questions, answer options, quiz attempts, responses, and adaptive learner state in a structured database.

After each response, the system updates the learner's state and uses it to determine a suitable question for the next step of the quiz.

##  Objectives

- Provide an interactive exam preparation platform.
- Store and manage quiz-related data using a relational database.
- Implement adaptive question selection.
- Use Item Response Theory (IRT) for estimating learner ability.
- Track learner responses and quiz progress.
- Maintain historical quiz and performance data.
- Demonstrate DBMS concepts such as:
  - Primary keys
  - Foreign keys
  - Relationships
  - Normalization
  - CRUD operations
  - SQL queries
  - Indexing

##  Main Features

### Learner Features
- User management
- Subject and topic selection
- Quiz participation
- Question and option display
- Answer submission
- Immediate response processing
- Progress tracking
- Adaptive question selection
- Quiz attempt history

### Adaptive Quiz Features
- Learner ability estimation
- Question difficulty handling
- Question discrimination parameters
- Response-based learner-state updates
- Dynamic next-question selection
- Adaptive assessment workflow

### Database Features
- User records
- Subject and topic management
- Question bank
- Answer options
- Quiz attempts
- Learner responses
- Adaptive state storage
- Historical data retrieval

##  Adaptive Assessment

The application uses **Item Response Theory (IRT)** as the basis for adaptive question selection.

The system represents learner ability using **θ (theta)** and question characteristics using parameters such as:

- **Difficulty (b)**
- **Discrimination (a)**

The learner's response is used to update the learner state. The updated state is then considered when selecting the next question.

The basic workflow is:

```text
Learner
   ↓
Application
   ↓
Database
   ↓
Question Retrieval
   ↓
Adaptive Quiz Engine
   ↓
Next Question
   ↓
Learner Response

┌─────────────────────────┐
│      Flutter UI        │
│       / Dart            │
└────────────┬────────────┘
             ↓
┌─────────────────────────┐
│ Application / Services  │
└────────────┬────────────┘
             ↓
┌─────────────────────────┐
│     Adaptive Engine     │
│         IRT Logic       │
└────────────┬────────────┘
             ↓
┌─────────────────────────┐
│      Database / SQL     │
│ Users, Questions,       │
│ Attempts, Responses     │
└─────────────────────────┘
