# 🏃‍♀️ FitLife — Gamified Fitness Tracker (Flutter)

[![CI](https://github.com/sudenazdemir/fitLife/actions/workflows/ci.yml/badge.svg)](https://github.com/sudenazdemir/fitLife/actions/workflows/ci.yml)

> A modern **Flutter** fitness app with clean architecture, **GoRouter navigation**, **Riverpod state management**, and a **light/dark theme toggle** — designed as the foundation for a gamified workout tracking experience.

---

## ✨ Features

- 🧭 **App architecture** built with `GoRouter` and `Riverpod`
- 🌙 **Light/Dark theme toggle** directly from the AppBar
- 🧩 **Clean folder structure** — `app/`, `core/`, `features/`
- 🧪 **CI-ready setup** with `flutter analyze` and basic tests
- 📊 **Future-ready** for persistence, charts, XP and level system

---

## 🧱 Tech Stack

- **Flutter** (Dart 3.x)
- **go_router** ^17
- **flutter_riverpod** ^3
- **flutter_lints** ^6
- **Material 3** design system

---

## 📁 Project Structure

```
lib/
  app/
    app.dart
    router.dart
  core/
    constants.dart
    theme_provider.dart
    di.dart
    result.dart
  features/
    shell/presentation/shell_page.dart
    home/presentation/home_page.dart
    workouts/presentation/workouts_page.dart
  main.dart
```

---

## 🚀 Getting Started

```bash
flutter pub get
flutter analyze
flutter run
```

---

## 📱 In-App Overview

- Tap the ☀️ / 🌙 icon in the AppBar to toggle between **Light** and **Dark** themes.  
- Navigate between pages using the bottom navigation bar:
  - 🏠 **Home**
  - 💪 **Workouts**

---

## 🧪 Testing

A basic smoke test is included to ensure the app boots successfully.

```bash
flutter test
```

---

## 🧭 Routing

- Initial route: `/`
- Shell layout wraps tab routes  
- Navigate programmatically using:

```dart
context.go('/');
context.go('/workouts');
```

---

## 🎨 Theme System

- Light and Dark themes built using **Material 3 color seeds**
- Managed by a `themeModeProvider` using **Riverpod**
- Users can toggle the theme from the AppBar

> Future update: Save selected theme using `shared_preferences`

---

## 🧩 Architecture Principles

- Each feature follows this structure:  
  `features/<feature_name>/{data, domain, presentation}`
- Centralized dependency injection (`di.dart`)
- Lightweight error/result wrapper in `result.dart`

---

## 🗺️ Roadmap

| Phase | Goal | Status |
|-------|------|--------|
| **1. Architecture & CI Setup** | App structure, theme, routing, CI workflow | ✅ Done |
| **2. Local Storage Integration** | Add Isar or Hive for saving workouts | ⏳ Planned |
| **3. Routine Manager** | Create/Edit/Delete custom routines | ⏳ Planned |
| **4. Gamification Layer** | Add XP, levels, and streak tracking | ⏳ Planned |
| **5. Dashboard & Analytics** | Visualize user progress with charts | ⏳ Planned |

---

## 🤝 Contributing

Contributions are welcome!  
Before submitting a PR, make sure all checks pass:

```bash
flutter analyze
flutter test
```

---

## 📄 License

To be decided — MIT or Apache-2.0 recommended for open source usage.
