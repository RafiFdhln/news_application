# News Application — Flutter News App

A fully-featured Flutter news application built with Firebase Auth, NewsAPI, GetX state management, and SQLite local storage.

---

## Project Overview

**News Application** is a mobile news application that allows users to:
- Sign in via **Google Account** or continue as **Guest** (Firebase Auth)
- Browse **top headline news** fetched from NewsAPI.org
- Read **full article details** and open original sources in browser
- **Bookmark** articles for offline reading
- Chat with **NewsBot** — an AI-style chatbot that responds to news-related queries
- Access **news & chat history offline** via SQLite caching
- View and manage their **Profile**

---

## Installation Instructions

### Requirements
- **Flutter SDK**: `^3.5.0` (Dart `^3.5.0`)
- **Android SDK**: API 21+ (minSdk)
- **Java / JDK**: 17

### 1. Clone and install dependencies
```bash
git clone https://github.com/RafiFdhln/news_application.git
cd news_apps
flutter pub get
```

### 2. Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project
2. Add an **Android app** with package name `com.example.news_apps`
3. Download `google-services.json` and place it in `android/app/`
4. Enable **Authentication** → Sign-in methods → Enable **Google** and **Anonymous**
5. Add your **SHA-1 debug fingerprint** to Firebase (required for Google Sign-In):
   ```bash
   # Windows (JDK 17 path)
   & "C:\Program Files\Java\jdk-17\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   
   # macOS / Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
   ```

### 3. Configure NewsAPI Key
1. Register at [https://newsapi.org/](https://newsapi.org/) and get your API key
2. Open `lib/core/constants/app_constants.dart`
3. Replace the value of `newsApiKey`:
   ```dart
   static const String newsApiKey = 'YOUR_API_KEY_HERE';
   ```
**Note**: NewsAPI keys may take several minutes to hours to become active after registration.

---

## Run Instructions

```bash
# Run on a connected device or emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

## Folder Structure

```
news_apps/
├── android/                        # Android-specific config
│   └── app/
│       ├── google-services.json    # Firebase config
│       └── src/main/AndroidManifest.xml
├── lib/
│   ├── core/
│   │   ├── constants/             # App routes, constants, API keys
│   │   └── theme/                 # Colors, themes
│   ├── data/
│   │   ├── local/
│   │   │   ├── dao/               # SQLite DAOs (user, article, message, bookmark)
│   │   │   └── database/          # DatabaseHelper (SQLite setup & migrations)
│   │   ├── models/                # Data models (ArticleModel, UserModel, etc.)
│   │   ├── remote/api/            # NewsAPI service
│   │   └── repositories/          # Repository implementations + interfaces
│   ├── presentation/
│   │   ├── bindings/              # GetX dependency injection (AppBinding, AppPages)
│   │   ├── controllers/           # GetX controllers (Auth, News, Chat, Bookmark)
│   │   └── pages/
│   │       ├── auth/              # Login page
│   │       ├── bookmark/          # Bookmarks page
│   │       ├── chat/              # Chat / NewsBot page
│   │       ├── news/              # News list + detail pages
│   │       │   └── widgets/       # NewsCard, shimmer widgets
│   │       ├── profile/           # Profile page
│   │       └── splash/            # Splash screen
│   └── main.dart
├── test/
│   ├── helpers/                   # Shared fake repositories / test data
│   ├── unit/                      # Unit tests (AuthController, NewsController, ChatController)
│   └── widget/                    # Widget tests (LoginPage, NewsPage)
├── integration_test/
│   └── app_integration_test.dart  # Full user flow integration tests
└── pubspec.yaml
```

---

## Implemented Features

| # | Feature | Status |
|---|---------|--------|
| 1 | **Social Media Login** — Google Sign-In + Guest Login via Firebase Auth | ✅ |
| 2 | **News Page** — Top headlines from NewsAPI, category filter, search, pull-to-refresh | ✅ |
| 3 | **News Detail Page** — Full article view, bookmark, open URL in browser, Ask NewsBot FAB | ✅ |
| 4 | **Chat Page** — NewsBot chatbot, text messages, image sending (gallery/camera), typing indicator | ✅ |
| 5 | **SQLite Storage** — User data, cached articles, chat messages, bookmarks | ✅ |
| 5 | **Offline Mode** — News & chat history accessible without internet | ✅ |
| 6 | **Bookmark Feature** — Save/unsave articles, swipe-to-delete, badge count | ✅ |
| 7 | **Profile Page** — User info, stats, sign out | ✅ |
| 8 | **Automated Testing** — Unit + widget + integration tests | ✅ |

---

## Testing Instructions

### Run all unit & widget tests
```bash
flutter test
```

### Run integration tests (requires a connected device/emulator)
```bash
flutter test integration_test/app_integration_test.dart
```

### Test coverage breakdown

| Type | Files | Tests Covered |
|------|-------|---------------|
| **Unit** | `test/unit/auth_controller_test.dart` | Auth: Google login, guest login, sign out, cached user |
| **Unit** | `test/unit/news_controller_test.dart` | News: fetch headlines, search, category selection, offline |
| **Unit** | `test/unit/chat_controller_test.dart` | Chat: send message, bot reply, clear chat |
| **Widget** | `test/widget/login_page_test.dart` | Login page rendering, button interactions |
| **Widget** | `test/widget/news_page_test.dart` | News page rendering, search interaction, offline banner |
| **Integration** | `integration_test/app_integration_test.dart` | Full flow: login → browse news → tap article → open chat → send message |

---

## Additional Notes

### API Key Activation Delay
NewsAPI free-tier keys may take **several minutes to a few hours** to become active after registration. During this time, API calls will return `401 Unauthorized`. The app will automatically fall back to **offline/cached mode**.

### Offline Mode Behavior
- Articles are cached in SQLite upon first successful fetch
- When offline, the app displays cached news with an **"Offline mode"** banner
- Chat history persists in SQLite and is available offline
- Bookmarks are stored locally — always accessible

### Common Setup Issues

| Issue | Solution |
|-------|----------|
| Google Sign-In fails | Ensure SHA-1 fingerprint is registered in Firebase Console |
| `google-services.json` missing | Download from Firebase Console → Project Settings → Android app |
| NewsAPI returns 401 | API key not yet active — wait and retry; check `app_constants.dart` |
| `canLaunchUrl` returns false | Ensure `AndroidManifest.xml` has `<queries>` for `https` scheme |
| Emulator camera not working | Use a physical device or configure emulator camera settings |
| Firebase initialization error | Verify `google-services.json` package name matches `com.example.news_apps` |
