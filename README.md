# FitLife — Gamified Fitness Tracker

FitLife is a gamified mobile fitness application built with Flutter.
Users level up, earn XP, track progress, build routines, and receive AI-powered feedback.

---

# 🚀 Milestone M3 — Completed

This milestone introduces advanced statistics, body measurements, AI integration, and a fully populated exercise library.

---

## ✨ New Features (M3 Completed)

### 🤖 AI-Powered Feedback (Google Gemini)
- Integrated **Google Gemini API** for post-workout analysis.
- Provides smart feedback based on session performance.
- AI-driven suggestions for improvement.

### 📈 Advanced Statistics & Charts (v2)
- **Interactive Graphs:** Visualized daily XP and workout frequency using `fl_chart`.
- **Real Data Integration:** Stats are now derived directly from Hive database.
- **Streak System:** Tracks consecutive workout days.

### 📏 Body Measurements Tracking
- Track weight, body fat percentage, and body circumferences.
- Local persistence for measurement history.
- Visual progress tracking.

### 🏋️‍♂️ Pre-Populated Library
- App comes with a default set of exercises (Populated Local Library).
- No empty states; users can start working out immediately.

---

## ✅ Core Features (M1 & M2)

### 🔥 Workout XP Engine
- Dynamic XP calculation based on duration and difficulty.
- **Gamification:** Level up system and rigorous unit tests for XP logic.

### 🔁 Routine Runner & Logger
- **Smart Logger:** Logs duration, sets, and reps with async-safe saving.
- **Routine Flow:** Auto-timer, rest periods, and set navigation.
- Redirects seamlessly upon session completion.

### 🔐 Auth & Profile
- **Firebase Authentication:** Email/Password login and registration.
- **Local Profile (Hive):** Stores user name, avatar, and goals locally for offline access.
- **Onboarding:** Smooth user introduction flow.

---

# 📅 Roadmap

| Milestone | Status | Description |
|----------|--------|-------------|
| **M1 – Core App Setup** | ✅ Completed | Routing, Theming, Hive Setup, Initial CI |
| **M2 – Workouts & XP Engine** | ✅ Completed | XP System, Session Logger, Firebase Auth |
| **M3 – Stats & AI Integration** | ✅ Completed | Gemini API, Body Measurements, Advanced Charts, Routine Creator |
| **M4 – Final Polish & Release** | 🔄 In Progress | UI Polish, Store Optimization, Stability Tests |

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
 │    ├── measurements/
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

- **Framework:** Flutter 3.x
- **State Management:** Riverpod 2.x
- **Navigation:** GoRouter
- **Local Database:** Hive
- **Backend / Auth:** Firebase Auth & Realtime Database
- **AI Integration:** Google Gemini API (`google_generative_ai`)
- **Visualization:** fl_chart
- **CI/CD:** GitHub Actions

---

# 🧪 Tests

- Navigation tests
- Theme toggle tests
- XP Engine unit tests
- App boot test

---

# 🔖 Version

**Tag:** m3
**Version:** 0.3.0