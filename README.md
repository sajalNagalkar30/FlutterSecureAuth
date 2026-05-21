# FlutterSecureAuth

A full-stack authentication project built with **Flutter** (frontend) and **Node.js + Express** (backend), implementing production-grade security including JWT with refresh tokens, SSL certificate pinning, encrypted storage, and clean architecture.

Runs on **Web**, **Android**, and **iOS** — with a live demo deployed to GitHub Pages.

---

## Live Demo

**Web:** [https://sajalnagalkar30.github.io/FlutterSecureAuth/](https://sajalnagalkar30.github.io/FlutterSecureAuth/)

---

## Screenshots

> Login Screen · Register Screen · Home/Dashboard Screen

---

## Tech Stack

| | Technology |
|---|---|
| **App (Web / Android / iOS)** | Flutter (Dart) |
| **State Management** | flutter_bloc (BLoC pattern) |
| **Architecture** | Clean Architecture (Domain / Data / Presentation) |
| **HTTP Client** | Dio |
| **Dependency Injection** | get_it |
| **Token Storage** | flutter_secure_storage (mobile) / in-memory (web) |
| **Connectivity** | connectivity_plus |
| **Splash Screen** | flutter_native_splash |
| **App Icon** | flutter_launcher_icons (Android, iOS, Web) |
| **Backend** | Node.js + Express.js |
| **Database** | MongoDB (Mongoose ODM) |
| **Authentication** | JWT Access Token + Refresh Token |
| **Security** | SSL Pinning, Helmet, CORS, HTTPS |
| **CI/CD** | GitHub Actions |
| **Web Hosting** | GitHub Pages |

---

## Project Structure

```
FlutterSecureAuth/
│
├── 📁 app/
│   └── 📁 flutter_login_registration/         # Flutter app (Web / Android / iOS)
│       │
│       ├── 📁 lib/
│       │   ├── main.dart                       # Entry point — initializes DI and runs app
│       │   ├── app.dart                        # MaterialApp + AuthGate (BLoC-driven routing)
│       │   │
│       │   ├── 📁 core/                        # Shared utilities across all features
│       │   │   │
│       │   │   ├── 📁 constants/
│       │   │   │   ├── api_constants.dart      # Base URL, SSL fingerprint, timeouts
│       │   │   │   └── app_theme.dart          # Dark theme, colors, gradients
│       │   │   │
│       │   │   ├── 📁 di/
│       │   │   │   └── injection.dart          # GetIt service locator — wires all layers
│       │   │   │
│       │   │   ├── 📁 error/
│       │   │   │   ├── failures.dart           # Typed failure classes (9 types)
│       │   │   │   └── dio_error_handler.dart  # Maps every DioException → AppFailure
│       │   │   │
│       │   │   ├── 📁 network/
│       │   │   │   ├── dio_client.dart         # Singleton Dio with SSL pinning + logging
│       │   │   │   ├── auth_interceptor.dart   # Auto Bearer injection + silent 401 refresh
│       │   │   │   └── network_info.dart       # Internet connectivity check
│       │   │   │
│       │   │   └── 📁 storage/
│       │   │       └── secure_storage.dart     # Encrypted token storage (Keychain/Keystore)
│       │   │
│       │   └── 📁 features/
│       │       └── 📁 auth/                    # Authentication feature
│       │           │
│       │           ├── 📁 domain/              # Business logic — no Flutter/Dio dependencies
│       │           │   ├── 📁 entities/
│       │           │   │   └── user_entity.dart          # Core user model
│       │           │   ├── 📁 repositories/
│       │           │   │   └── auth_repository.dart      # Abstract repository contract
│       │           │   └── 📁 usecases/
│       │           │       ├── login_usecase.dart         # Validates + calls login
│       │           │       ├── register_usecase.dart      # Validates + calls register
│       │           │       └── logout_usecase.dart        # Calls logout
│       │           │
│       │           ├── 📁 data/                # Data layer — API calls, models, repo impl
│       │           │   ├── 📁 models/
│       │           │   │   └── auth_response_model.dart   # JSON → Entity mapping
│       │           │   ├── 📁 datasources/
│       │           │   │   └── auth_remote_datasource.dart # Dio HTTP calls to backend
│       │           │   └── 📁 repositories/
│       │           │       └── auth_repository_impl.dart  # Implements AuthRepository
│       │           │
│       │           └── 📁 presentation/        # UI layer — BLoC + Screens
│       │               ├── 📁 bloc/
│       │               │   ├── auth_bloc.dart             # Handles all auth events
│       │               │   ├── auth_event.dart            # Login, Register, Logout, Check
│       │               │   └── auth_state.dart            # Initial, Loading, Auth, Error
│       │               └── 📁 screens/
│       │                   ├── login_screen.dart          # Login UI
│       │                   ├── register_screen.dart       # Register UI
│       │                   └── home_screen.dart           # Dashboard after login
│       │
│       ├── pubspec.yaml                        # Flutter dependencies
│       ├── 📁 android/                         # Android platform config
│       ├── 📁 ios/                             # iOS platform config
│       └── 📁 web/                             # Web platform config (manifest, index.html)
│
├── 📁 backend/                                 # Node.js REST API
│   ├── server.js                               # Express entry — HTTP/HTTPS, middleware, routes
│   ├── 📁 config/
│   │   └── db.js                              # MongoDB connection via Mongoose
│   ├── 📁 middleware/
│   │   └── auth.js                            # JWT protect middleware (verifies Bearer token)
│   ├── 📁 model/
│   │   └── user.js                            # User schema — bcrypt password hashing
│   ├── 📁 routes/
│   │   └── auth.js                            # All auth API endpoints
│   ├── 📁 scripts/
│   │   └── generate-certs.js                  # Generates self-signed SSL cert + SHA-256 fingerprint
│   └── 📁 certs/                              # SSL certificate files (gitignored)
│       ├── server.key                          # Private key
│       └── server.crt                          # Certificate
│
├── 📁 .github/
│   └── 📁 workflows/
│       ├── ci.yml                              # GitHub Actions CI/CD pipeline
│       └── deploy-web.yml                      # GitHub Pages deployment for Flutter web
│
├── .env.example                                # Environment variable template
├── .gitignore                                  # Excludes .env, certs, node_modules, build
├── demo-app.code-workspace                     # VS Code multi-root workspace
├── package.json                                # Node.js dependencies + scripts
└── README.md
```

---

## Backend API Endpoints

Base URL: `https://<your-server>:9000/api/auth`

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| `POST` | `/register` | ❌ | Register new user — returns access + refresh token |
| `POST` | `/login` | ❌ | Login — returns access + refresh token |
| `POST` | `/refresh-token` | ❌ | Exchange refresh token for new token pair (rotated) |
| `POST` | `/logout` | ✅ Bearer | Invalidates refresh token in database |
| `GET` | `/me` | ✅ Bearer | Returns current authenticated user profile |

---

## Authentication Flow

```
User Login / Register
        │
        ▼
Backend validates credentials
        │
        ▼
Returns accessToken (15 min) + refreshToken (7 days)
        │
        ▼
Flutter stores both in flutter_secure_storage (encrypted)
        │
        ▼
Every API request → Auth Interceptor adds Bearer accessToken
        │
        ├── Token valid → request proceeds ✅
        │
        └── 401 received → Auth Interceptor silently calls /refresh-token
                    │
                    ├── Refresh OK → new tokens saved, original request retried ✅
                    │
                    └── Refresh failed → user logged out 🔒
```

---

## Security Features

| Feature | Implementation |
|---|---|
| **JWT Access Token** | Short-lived (15 min), sent as `Authorization: Bearer` header |
| **Refresh Token** | Long-lived (7 days), rotated on every use, stored in MongoDB |
| **SSL Certificate Pinning** | SHA-256 fingerprint verified on every Dio HTTPS request |
| **Encrypted Storage** | `flutter_secure_storage` — Keychain (iOS) / Keystore (Android) |
| **Security Headers** | `helmet` middleware — CSP, HSTS, X-Frame-Options |
| **HTTPS** | Self-signed cert for dev, configurable for production |
| **Input Validation** | Handled in use cases only — not in UI layer |
| **Error Handling** | Every `DioException` type mapped to typed `AppFailure` |
| **Network Check** | `connectivity_plus` checked before every API call |

---

## Getting Started

### Prerequisites

- Node.js 18+
- Flutter 3.x (stable)
- MongoDB Atlas account or local MongoDB

### 1. Clone the repo

```bash
git clone https://github.com/sajalNagalkar30/FlutterSecureAuth.git
cd FlutterSecureAuth
```

### 2. Setup backend

```bash
# Install Node dependencies
npm install

# Create environment file
cp .env.example .env
```

Edit `.env` and fill in your values:

```env
PORT=9000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_strong_random_secret
JWT_REFRESH_SECRET=your_different_strong_secret
USE_HTTPS=true
CORS_ORIGIN=*
```

```bash
# Generate SSL certificate (required for SSL pinning)
npm run gen-certs
```

Copy the printed **SHA-256 fingerprint** into `lib/core/constants/api_constants.dart`:

```dart
static const String sslPinnedFingerprint = 'paste_fingerprint_here';
```

```bash
# Start backend
npm run dev
```

### 3. Setup Flutter app

```bash
cd app/flutter_login_registration

# Install dependencies
flutter pub get

# Run on a specific platform
flutter run -d chrome          # Web
flutter run -d emulator-5554   # Android emulator
flutter run -d iPhone          # iOS simulator
```

> **Device URL config** is handled via `--dart-define=BASE_URL=...` in `.vscode/launch.json`

| Platform | BASE_URL |
|---|---|
| Android Emulator | `https://10.0.2.2:9000/api/auth` |
| iOS Simulator | `https://localhost:9000/api/auth` |
| Web (browser) | `https://localhost:9000/api/auth` |
| Physical Device | `https://<your-mac-lan-ip>:9000/api/auth` |

---

## Running with VS Code

Open `demo-app.code-workspace` then go to **Run & Debug** (`Cmd+Shift+D`) and pick a compound:

| Compound | Description |
|---|---|
| ▶ Backend + Web (Chrome) | Starts both for the browser |
| ▶ Backend + iOS Physical Device | Starts both together for iPhone |
| ▶ Backend + iOS Simulator | Starts both for iOS Simulator |
| ▶ Backend + Android Emulator | Starts both for Android Emulator |
| ▶ Backend + macOS | Starts both as macOS desktop app |

---

## CI/CD Pipeline

### Continuous Integration (`ci.yml`)

GitHub Actions triggers on every push to `main` or `develop`:

```
Push to main / develop
    │
    ├── Backend CI
    │     ├── Restore .env from GitHub Secrets
    │     ├── Restore SSL certs from GitHub Secrets
    │     ├── npm install + npm audit
    │     └── Server smoke test
    │
    ├── Flutter Analyze & Test
    │     ├── flutter pub get
    │     ├── flutter analyze
    │     └── flutter test
    │
    ├── Build Android APK (obfuscated)
    │     └── Uploads APK + debug symbols as artifacts
    │
    └── Build iOS IPA (obfuscated, no code sign)
          └── Uploads IPA + debug symbols as artifacts
```

### Web Deployment (`deploy-web.yml`)

Automatically deploys the Flutter web build to **GitHub Pages** on every push to `main` that touches the app directory:

```
Push to main (app/** changed)
    │
    ├── flutter build web --release
    │     └── --base-href /FlutterSecureAuth/
    │
    └── Deploy to GitHub Pages
          └── https://sajalnagalkar30.github.io/FlutterSecureAuth/
```

### Required GitHub Secrets

Go to `Settings → Secrets and variables → Actions` and add:

| Secret | Description |
|---|---|
| `MONGO_URI` | MongoDB connection string |
| `JWT_SECRET` | JWT signing secret |
| `JWT_REFRESH_SECRET` | Refresh token signing secret |
| `SSL_CERT` | Contents of `backend/certs/server.crt` |
| `SSL_KEY` | Contents of `backend/certs/server.key` |
| `SERVER_URL` | Backend base URL injected into Flutter builds |

---

## Flutter Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.6 | BLoC state management |
| `equatable` | ^2.0.5 | Value equality for BLoC states |
| `dio` | ^5.7.0 | HTTP client with interceptors |
| `flutter_secure_storage` | ^9.2.2 | Encrypted token storage |
| `connectivity_plus` | ^5.0.2 | Internet connectivity detection |
| `get_it` | ^8.0.2 | Dependency injection |
| `flutter_native_splash` | ^2.4.7 | Native splash screen (Android & iOS) |
| `flutter_launcher_icons` | ^0.14.4 | App icons for Android, iOS, and Web |

## Backend Dependencies

| Package | Version | Purpose |
|---|---|---|
| `express` | ^5.2.1 | Web framework |
| `mongoose` | ^9.6.2 | MongoDB ODM |
| `jsonwebtoken` | ^9.0.3 | JWT sign and verify |
| `bcryptjs` | ^3.0.3 | Password hashing |
| `helmet` | ^8.1.0 | HTTP security headers |
| `cors` | ^2.8.6 | Cross-origin resource sharing |
| `dotenv` | ^17.4.2 | Environment variable loader |

---

## License

MIT © [sajalNagalkar30](https://github.com/sajalNagalkar30)
