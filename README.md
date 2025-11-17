# FitLife — Gamified Fitness Tracker (M1 Release)

FitLife is a gamified fitness tracker that helps users stay consistent with their workouts by turning training into an XP / level / streak based experience.

This release represents **Milestone M1 – Core App Setup**.

---

## 🚀 M1 Features (Completed)

- **Routing & Navigation**
  - `/`, `/workouts`, `/stats` defined with GoRouter
  - Shell layout with Bottom Navigation
- **Theme Switching**
  - Light / Dark mode toggle using Riverpod StateProvider
- **Workout Model**
  - JSON-serializable `Workout` class
- **Mock Repository**
  - In-memory mock workouts list
  - Workouts rendered on `/workouts`
- **Local Persistent Storage**
  - Hive setup and initialization
  - `WorkoutSession` model stored in a Hive box
  - Repository + Riverpod providers
  - Data persists between app restarts
- **Stats & Visualization**
  - Simple XP line chart using `fl_chart` on `/stats`
  - Workout sessions list rendered below chart
- **Code Quality & CI**
  - `flutter analyze` → 0 warnings
  - 1–2 widget tests (theme toggle, initial navigation)
  - GitHub Actions CI: `flutter analyze` + `flutter test --coverage`

---

## 🧱 Project Architecture

lib/
 ├── app/
 │    ├── app.dart                # Root widget (MaterialApp.router)
 │    └── router.dart             # GoRouter config + ShellRoute
 │
 ├── core/
 │    ├── constants.dart
 │    └── theme_provider.dart
 │
 ├── features/
 │    ├── home/
 │    │    └── presentation/
 │    │         └── home_page.dart
 │
 │    ├── stats/
 │    │    └── presentation/
 │    │         └── stats_page.dart
 │
 │    ├── workouts/
 │    │    ├── data/
 │    │    │    └── mock_workouts_repository.dart
 │    │    ├── domain/
 │    │    │    ├── models/
 │    │    │    │    ├── workout.dart
 │    │    │    │    ├── workout.g.dart
 │    │    │    │    ├── workout_session.dart
 │    │    │    │    └── workout_session.g.dart
 │    │    │    ├── providers/
 │    │    │    │    ├── workouts_provider.dart
 │    │    │    │    └── workout_session_providers.dart
 │    │    │    └── repositories/
 │    │    │         ├── workouts_repository.dart
 │    │    │         └── workout_session_repository.dart
 │    │    └── presentation/
 │    │         └── workouts_page.dart
 │
 ├── features/shell/
 │    └── presentation/
 │         └── shell_page.dart
 │
 └── main.dart                    # Hive init + ProviderScope

---

## 🗺️ Roadmap

### **M1 – Core App Setup (COMPLETED ✅)**

| Area           | Feature                              | Status |
|----------------|--------------------------------------|--------|
| Routing        | GoRouter setup (+ Shell)             | ✅     |
| Navigation     | Bottom NavigationBar                 | ✅     |
| Theming        | Light / Dark toggle                  | ✅     |
| Models         | Workout model (JSON)                 | ✅     |
| Data           | Mock workouts repository             | ✅     |
| Local Storage  | Hive + WorkoutSession persistence    | ✅     |
| Visualization  | XP line chart on `/stats`            | ✅     |
| Quality        | `flutter analyze` = 0 warnings       | ✅     |
| Testing        | Widget tests                         | ✅     |
| CI             | GitHub Actions (analyze + test)      | ✅     |
| Docs           | README updated                       | ✅     |

---

### **M2 – Workouts Experience (NEXT)**

- Workout detail screen  
- Improved workout logging UX  
- Connect Workout → WorkoutSession flow  
- Basic measurements (weight, body metrics)

### **M3 – Gamification Layer**

- XP logic  
- Level system  
- Streak tracking  
- Achievements  
- Enhanced stats dashboard

### **M4 – Routines & Reminders**

- Create / edit workout routines  
- Reminders & notifications  
- Weekly goals  

---

## 🔖 Release Notes — M1

**Tag:** `m1`  
**Version:** `0.1.0`  

This milestone focuses on setting up the core architecture of the app:
navigation, theming, core models, mock data, local storage with Hive,
basic stats visualization and a working CI pipeline.

---

## 📦 Tech Stack

- Flutter 3.x  
- Riverpod 2.x  
- GoRouter  
- Hive  
- fl_chart  
- GitHub Actions CI  

---

## 🧪 Tests

- Theme toggle widget test (AppBar)
- Initial navigation test (Home route)
- CI pipeline includes:
  - `flutter analyze`
  - `flutter test --coverage`
