# FlutterSecureAuth

A full-stack mobile authentication demo built with **Flutter + Node.js**, implementing production-grade security practices.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) — BLoC + Clean Architecture |
| Backend API | Node.js + Express |
| Database | MongoDB (Mongoose) |
| Auth | JWT Access Token (15min) + Refresh Token (7 days) |
| Security | SSL Certificate Pinning, Helmet, CORS, Encrypted Storage |

---

## Project Structure

```
FlutterSecureAuth/
├── app/
│   └── flutter_login_registration/   # Flutter app
│       └── lib/
│           ├── core/
│           │   ├── constants/        # API URL, theme
│           │   ├── di/               # GetIt dependency injection
│           │   ├── error/            # Failures + DioErrorHandler
│           │   ├── network/          # Dio client, Auth interceptor, Network info
│           │   └── storage/          # flutter_secure_storage
│           └── features/auth/
│               ├── data/             # Models, datasources, repository impl
│               ├── domain/           # Entities, repository contract, use cases
│               └── presentation/     # BLoC, screens (Login, Register, Home)
├── backend/
│   ├── config/db.js                  # MongoDB connection
│   ├── middleware/auth.js            # JWT protect middleware
│   ├── model/user.js                 # User schema
│   ├── routes/auth.js                # Auth API routes
│   ├── scripts/generate-certs.js     # SSL cert generator
│   └── server.js                     # Express entry point
├── .env.example                      # Environment variable template
├── .github/workflows/ci.yml          # GitHub Actions CI/CD
└── demo-app.code-workspace           # VS Code multi-root workspace
```

---

## Security Features

- **JWT Access Token** — short-lived (15 min), sent as Bearer header
- **Refresh Token** — long-lived (7 days), rotated on every use, stored in DB
- **SSL Certificate Pinning** — SHA-256 fingerprint verified on every Dio request
- **Encrypted Token Storage** — `flutter_secure_storage` (Keychain on iOS, Keystore on Android)
- **Helmet** — HTTP security headers on backend
- **Auth Interceptor** — automatic silent token refresh on 401
- **Input Validation** — handled in use cases only, not in UI

---

## Getting Started

### Prerequisites

- Node.js 18+
- Flutter 3.x
- MongoDB Atlas account (or local MongoDB)

### 1. Clone the repo

```bash
git clone https://github.com/your-username/FlutterSecureAuth.git
cd FlutterSecureAuth
```

### 2. Setup backend

```bash
# Install dependencies
npm install

# Create .env from template
cp .env.example .env
# Fill in MONGO_URI, JWT_SECRET, JWT_REFRESH_SECRET

# Generate SSL certificate (for SSL pinning)
npm run gen-certs
# Copy the printed SHA-256 fingerprint into api_constants.dart

# Start the backend
npm run dev
```

### 3. Setup Flutter app

```bash
cd app/flutter_login_registration
flutter pub get
flutter run
```

---

## API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | No | Register new user |
| POST | `/api/auth/login` | No | Login, returns token pair |
| POST | `/api/auth/refresh-token` | No | Refresh access token |
| POST | `/api/auth/logout` | Bearer | Invalidate refresh token |
| GET | `/api/auth/me` | Bearer | Get current user |

---

## Environment Variables

Copy `.env.example` to `.env` and fill in:

```env
PORT=9000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_strong_secret
JWT_REFRESH_SECRET=your_different_strong_secret
USE_HTTPS=true
CORS_ORIGIN=*
```

---

## CI/CD

GitHub Actions pipeline (`.github/workflows/ci.yml`) runs on every push to `main`:

1. **Backend CI** — restores `.env` + SSL certs from GitHub Secrets, smoke tests server
2. **Flutter CI** — `flutter analyze`, `flutter test`, `flutter build apk`
3. **Deploy** — SSH deploy template (uncomment when ready)

See [CI/CD setup guide](#) for adding GitHub Secrets.

---

## Running with VS Code

Open `demo-app.code-workspace` in VS Code, then use **Run & Debug** (`Cmd+Shift+D`) to pick a compound launch config that starts both backend and Flutter together.

---

## License

MIT
