# News Application — Flutter News App

A fully-featured Flutter news application built with Firebase Auth, NewsAPI, GetX state management, and SQLite local storage.

---

## Project Overview

**News Application** is a mobile news application that allows users to:
- Sign in via **Google Account** or continue as **Guest** (Firebase Auth)
- Browse **top headline news** fetched from NewsAPI.org
- Read **full article details** and open original sources in the browser
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
cd news_application
flutter pub get
```

### 2. Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Add an **Android app** with the package name `com.example.news_apps`.
3. Download `google-services.json` and place it inside `android/app/`.
4. Navigate to **Authentication** → Sign-in methods → Enable **Google** and **Anonymous**.
5. Add your **SHA-1 debug fingerprint** to Firebase (required for Google Sign-In):
   ```bash
   # Windows (JDK 17 path)
   & "C:\Program Files\Java\jdk-17\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   
   # macOS / Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
   ```

### 3. Configure NewsAPI Key
By default, an API Key reference may be included in the source code, but you are heavily recommended to use your own.
1. Register at [https://newsapi.org/](https://newsapi.org/) and get your API key.
2. Open `lib/core/constants/app_constants.dart`.
3. Replace the value of `newsApiKey`:
   ```dart
   static const String newsApiKey = 'YOUR_API_KEY_HERE';
   ```
**Note**: NewsAPI free-tier keys may take several minutes to slightly over an hour to become active after registration.

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

---

## Folder Structure

```text
news_application/
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
| 3 | **News Detail Page** — Full article view, bookmark, copy URL, open in browser | ✅ |
| 4 | **Ask NewsBot Button** — AppBar action icon within the detail page | ✅ |
| 5 | **Chat Page** — NewsBot chatbot, text messages, typing indicator, image sending | ✅ |
| 6 | **SQLite Storage** — User data, cached articles, chat messages, bookmarks | ✅ |
| 7 | **Offline Mode** — News & chat history accessible without an internet connection | ✅ |
| 8 | **Bookmark Feature** — Save/unsave articles, swipe-to-delete, badge count | ✅ |
| 9 | **Profile Page** — User info, brief stats, sign out functionality | ✅ |
| 10 | **Automated Testing** — Unit + widget + integration tests fully implemented | ✅ |

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

### Test Coverage Breakdown

| Type | File | Tests Covered |
|------|------|---------------|
| **Unit** | `test/unit/auth_controller_test.dart` | Google login, guest login, sign out, user session cache |
| **Unit** | `test/unit/news_controller_test.dart` | Fetch headlines, search, category selection, offline mode |
| **Unit** | `test/unit/chat_controller_test.dart` | Send message, bot reply, clear chat history |
| **Widget** | `test/widget/login_page_test.dart` | Login page rendering, button interactions |
| **Widget** | `test/widget/news_page_test.dart` | News portal rendering, search field, offline banner |
| **Integration** | `integration_test/app_integration_test.dart` | Full coverage *(see below)* |

### Integration Test Groups

| Group | Target Tests |
|-------|-------|
| **Authentication** | Login page renders · Guest login navigates to News · Google sign-in failure stays on Login |
| **News Page** | Article list displayed · Category filter · Search query · Pull-to-refresh reacts properly · Bottom navigation to Chat |
| **News Detail Page** | Navigation to detail works · Bookmark icon interactions · Ask NewsBot icon · Copy URL · Back navigation |
| **Chat Page** | NewsBot header shown · Send and store message locally to repository · Bot replies and is stored |
| **End-to-End Journey** | Guest login → Browse news → Open article → Verify NewsBot action in AppBar → Interact in chat via bot |

---

## Additional Notes

### API Key Activation Delay
NewsAPI free-tier keys may take **several minutes to a few hours** to become fully active right after registration. During this initialization delay, API endpoint calls might return a `401 Unauthorized` response. However, the app will gracefully fall back to **offline/cached mode** ensuring you browse seamlessly against locally saved records.

### Offline Mode Behavior
- Articles are forcefully cached into SQLite upon the first successful fetch.
- When the device is offline, the app switches and displays cached news accompanied by an **"Offline mode"** banner on the main page.
- Chat history continues to persist in SQLite and remains available offline.
- Bookmarks are stored completely offline securely and thus are always instantly accessible.

### Common Setup Issues

| Issue | Solution |
|-------|----------|
| Google Sign-In fails/crashes | Ensure your SHA-1 fingerprint is accurately registered in the Firebase Console Settings. |
| `google-services.json` missing | Download it from Firebase Console → Project Settings → General, and put it directly into `android/app/`. |
| NewsAPI returns 401 | The API key might not be completely active yet—wait and retry; verify the string in `app_constants.dart`. |
| `canLaunchUrl` does not open Chrome | Ensure the `AndroidManifest.xml` has the exact `<queries>` block with the `https` scheme authorized. |
| Emulator camera not working | Try to configure the emulator camera inside the Virtual Device's settings or use a physical device via USB Debugging. |
| Firebase initialization error | Verify that the `package_name` value inside `google-services.json` matches exactly `com.example.news_apps`. |
