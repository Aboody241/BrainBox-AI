# BrainBox AI — Build Phases

---

## Phase 0 — Architecture & Planning

**الهدف:** تثبيت القرارات قبل كتابة الكود.

- Product requirements
- User flows
- Feature map
- Architecture & folder structure
- Dependency direction
- State management strategy
- Database strategy
- AI provider strategy
- Error handling strategy
- Testing strategy
- Core Architecture Decision Records (ADRs)

### Output:
```text
README.md
Workflow.md
docs/
└── architecture/
```

---

## Phase 1 — Project Foundation (100% COMPLETE)

**الهدف:** بناء الـ skeleton الأساسي للمشروع.

### المهام:
- [x] إنشاء Flutter project
- [x] Configure linting & analysis options
- [x] Folder structure setup
- [x] App theme configuration
- [x] Centralized routing setup
- [x] Dependency Injection (GetIt)
- [x] Core error system & typed Failure models
- [x] `Result<T>` abstraction (`Success` / `Failure`)
- [x] Environment configuration
- [x] App entry point

### Definition of Done:
- [x] `flutter analyze` → **PASS**
- [x] `flutter test` → **PASS**
- [x] App launches → **PASS**
- [x] Clean Architecture boundaries established

---

## Phase 2 — Design System & UI Foundation (100% COMPLETE)

**الهدف:** بناء لغة UI موحدة ومتناسقة.

### المهام:
- **Design Tokens:** Colors, Typography, Spacing, Radius, Shadows
- **Core Components:**
  - [x] Buttons & Text fields (`AppButton`, `AppTextField`, `AppOtpInput`)
  - [x] Cards & Containers (`AppCard`, `AppBackButton`)
  - [x] Loading indicators & Shimmers (`AppLoadingIndicator`, `AppShimmer`)
  - [x] Error banners & SnackBars (`AppBanner`, `AppSnackBar`)
  - [x] Empty state placeholders (`AppEmptyState` with SVG assets support)
  - [x] Message bubble components (`AppChatBubble`)
  - [x] Responsive layout rules (`AppResponsiveLayout`, `AppBreakpoints`, `AppCenteredContent`)

---

## Phase 3 — Authentication & Auth UI (100% COMPLETE)

**الهدف:** بناء نظام الـ authentication والواجهات بالكامل.

### Architecture Breakdown:

#### 1. Domain Layer
- [x] **Entities:** `User` (`id`, `username`, `email`, `password`, `image`, `createdAt`, `isLoggedIn`)
- [x] **Contracts:** `AuthRepository`
- [x] **Use Cases:** `LoginUseCase`, `RegisterUseCase`, `GetCurrentUserUseCase`, `LogoutUseCase`

#### 2. Data Layer
- [x] `UserModel` with JSON serialization
- [x] `InMemoryAuthLocalDataSource`
- [x] `MockAuthRemoteDataSource`
- [x] `AuthRepositoryImpl`

#### 3. Presentation Layer
- [x] **Screens:** 
  - `SplashScreen` (2-step logo animation `Logo.svg` ➔ `textSlogan.svg`)
  - `LoginScreen` (Welcome & Social Auth Landing)
  - `LoginFormScreen` (Dedicated Sign In Page matching design mockup)
  - `RegisterScreen` (Dedicated Sign Up Page matching design mockup)
  - `ForgetPasswordScreen` (Contact method selection matching design mockup)
  - `EnterPhoneScreen` (Phone number entry matching design mockup)
  - `VerifyOtpScreen` (OTP Verification)
- [x] **State Management:** `AuthViewModel`, `AuthState`
- [x] **Reusable UI Component:** `AppBackButton` extracted & applied across all auth sub-screens

---

## Phase 4 — Local Database (NEXT UP)

**الهدف:** بناء persistence layer قبل الشات.

### Database Tables:
- `users`: `id`, `username`, `email`, `password`, `image`, `created_at`, `is_logged_in`
- `conversations`: `id`, `user_id`, `title`, `created_at`, `updated_at`, `is_pinned`
- `messages`: `id`, `conversation_id`, `sender_type`, `content`, `timestamp`, `status`
- `user_settings`: `user_id`, `theme_mode`, `language`, `notifications_enabled`

### المهام:
- Drift setup & database configuration
- Table definitions & relationships
- DAOs & typed queries
- Model-to-Entity mappers
- Database error handling
- Schema migration strategy
- Database unit & migration tests