# FitLife — Gamified Fitness Tracker

FitLife is a gamified mobile fitness application built with Flutter.  
Users level up, earn XP, track progress, build routines, and follow structured workout flows.

---

# 🚀 Milestone M2 — Completed

This milestone adds full XP Engine integration, Workout Session Logger, Routine Runner MVP, Exercise Library, and Firebase Authentication.

---

## ✅ M2 Features (Completed)

### 🔥 Workout XP Engine
- Dynamic XP calculation:
  - Duration-based XP  
  - Difficulty modifiers (Easy / Medium / Hard)  
  - Set & Rep bonus system  
- Unit tests for XP logic  
- Consistent, deterministic results  

---

### 📊 Real Stats Page (XP from Hive)
- XP is now read from real saved sessions  
- Daily XP grouped and shown as line chart  
- Total XP  
- Total sessions  
- Last session details  

---

### 🏋️ Workout Session Logger (MVP)
- Duration OR sets & reps logging  
- XP calculated immediately  
- Sessions saved to Hive  
- Async-safe implementation  
- Redirects back to the workout list  

---

### 🔁 Routine Runner (MVP)
- Automatically flows through a routine:
  - Exercise → Sets → Timer → Rest → Next  
- Countdown timers  
- Auto-advance logic  
- Final XP summary  
- Routine sessions saved to Hive  
- Integrated with XP Engine  

---

### 📚 Exercise Library
- Basic exercise library UI  
- Filterable workouts  
- Navigable from Workouts page  

---

### 🎭 Workout Categories + Filtering
- Category chips added  
- Provider-based filtering  
- All workouts / Full Body / Upper / Lower / Abs…  

---

### 👤 Firebase Authentication
- Email + Password login  
- Register new account  
- Persisted session until logout  
- Logout button added to Profile  
- Auth guard redirects  
- Uses Firebase Auth SDK  

---

### 💾 Local Profile (Hive)
- User profile stored locally  
- Name, avatar, goal  
- Onboarding screen  
- Edit profile  
- Loads automatically on app start  

---

# 🧱 Project Architecture

```
lib/
 ├── app/
 │    ├── app.dart
 │    └── router.dart
 │
 ├── core/
 │    ├── constants.dart
 │    └── utils/
 │         └── result.dart
 │
 ├── features/
 │    ├── auth/
 │    ├── home/
 │    ├── workouts/
 │    ├── routines/
 │    ├── stats/
 │    ├── profile/
 │    └── exercise_library/
 │
 └── main.dart
```

---

# 📅 Roadmap

| Milestone | Status | Description |
|----------|--------|-------------|
| **M1 – Core App Setup** | ✅ Completed | Routing, Theming, Mock Data, Hive Setup, Initial Stats, CI |
| **M2 – Workouts & XP Engine** | ✅ Completed | XP Engine, Session Logger, Stats Integration, Exercise Library, Firebase Auth |
| **M3 – Routines & Measurements** | 🔄 Next | Routine Creator, Routine List, Measurement Tracking, Stats v2 |
| **M4 – Final Polish & Submission** | 🔜 Pending | UI Polish, Stability, Testing, Release Build, Documentation |

---

# 📦 Tech Stack

- Flutter 3.x  
- Riverpod 2.x  
- GoRouter  
- Hive  
- Firebase Auth  
- fl_chart  
- GitHub Actions CI  

---

# 🧪 Tests

- Navigation tests  
- Theme toggle tests  
- XP Engine unit tests  
- App boot test  

---

# 🔖 Version

**Tag:** m2  
**Version:** 0.2.0  
