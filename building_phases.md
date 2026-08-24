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

## Phase 1 — Project Foundation

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

### Architecture:
```text
main.dart
   ↓
  App
   ├── Router
   ├── Theme
   └── DI
```

### Definition of Done:
- [x] `flutter analyze` → **PASS**
- [x] `flutter test` → **PASS**
- [x] App launches → **PASS**
- [x] Clean Architecture boundaries established

---

## Phase 2 — Design System & UI Foundation

**الهدف:** قبل ما نعمل features، نبني لغة UI موحدة ومتناسقة.

### المهام:
- **Design Tokens:** Colors, Typography, Spacing, Radius, Shadows
- **Core Components:**
  - Buttons & Text fields
  - Cards & Containers
  - Loading indicators & Shimmers
  - Error banners & SnackBars
  - Empty state placeholders
  - Message bubble components
  - Responsive layout rules

### الناتج:
```text
core/
└── presentation/
    ├── theme/
    ├── widgets/
    └── components/
```

---

## Phase 3 — Authentication

**الهدف:** بناء نظام الـ authentication بالكامل.

### Architecture Breakdown:

#### 1. Domain Layer
- **Entities:** `User`
- **Contracts:** `AuthRepository`
- **Use Cases:** `Login`, `Logout`, `GetCurrentUser`

#### 2. Data Layer
- `AuthRemoteDataSource`
- `AuthRepositoryImpl`

#### 3. Presentation Layer
- **Screens:** `SplashScreen`, `LoginScreen`
- **State Management:** `AuthViewModel`, `AuthState`

### Flow:
```text
       App
        ↓
     Splash
        ↓
   Check Session
        ↓
 ┌───────────────┐
 │ Authenticated │ ──► Home
 └───────┬───────┘
         │
         ▼ (Not Authenticated)
       Login
```

### Tests:
- [ ] Auth repository unit tests
- [ ] Login use case unit tests
- [ ] AuthViewModel state tests
- [ ] Login widget tests

---

## Phase 4 — Local Database

**الهدف:** بناء persistence layer قبل الشات.

### Database Tables:
- `users`
- `conversations`
- `messages`

### المهام:
- Drift setup & database configuration
- Table definitions & relationships
- DAOs & typed queries
- Model-to-Entity mappers
- Database error handling
- Schema migration strategy
- Database unit & migration tests

### Structure:
```text
core/database/
├── app_database.dart
├── tables/
├── daos/
└── migrations/
```

---

## Phase 5 — Conversations

**الهدف:** بناء نظام الـ Recent Chats وإدارة المحادثات.

### Features:
- Create new conversation
- Load conversation history
- Rename conversation
- Delete conversation
- Search conversations
- Sort by updated date
- Local-first persistence

### Architecture Flow:
```text
HomeScreen ──► ConversationViewModel ──► GetConversations UseCase ──► ConversationRepository ──► LocalDataSource ──► Drift
```

### UI Components:
```text
HomeScreen
 ├── Recent Chats List
 ├── Search Bar
 └── New Chat Action Button
```

---

## Phase 6 — Chat Domain

**الهدف:** بناء عقل الشات قبل ربط Gemini (فصل كامل للـ Domain).

> [!IMPORTANT]
> **ممنوع ربط Gemini في هذه المرحلة.** نحن نبني الـ domain والـ contracts المستقلة أولاً.

### 1. Entities:
- `Message`
- `Conversation`

### 2. Repository Contract:
- `ChatRepository`

### 3. Use Cases:
- `SendMessage`
- `GetMessages`
- `DeleteMessage`
- `RegenerateMessage`
- `ClearConversation`

### 4. State Model:
```text
ChatState (Initial | Loading | Streaming | Success | Failure)
```

---

## Phase 7 — AI Provider

**الهدف:** ربط Gemini بالـ architecture عبر Repository Pattern.

### Flow:
```text
ChatRepository (Domain Contract)
       ▲
       │
GeminiChatRepository (Implementation)
       ↓
GeminiRemoteDataSource
       ↓
Gemini API
```

### المهام:
- API client & secure config
- Request / Response models & DTOs
- DTO ↔ Entity mappers
- API error mapping to Domain failures
- Repository implementation

> [!TIP]
> **أهم اختبار:** يجب أن نتمكن من استبدال `GeminiChatRepository` بـ `OpenAIChatRepository` بدون تعديل سطر واحد في الـ UI أو الـ ViewModels.

---

## Phase 8 — Streaming Chat

**الهدف:** تنفيذ أهم feature في التطبيق (Streaming response).

### Flow:
```text
User ──► ViewModel ──► SendMessage UseCase ──► Repository ──► Gemini ──► Stream<String> ──► ViewModel ──► State ──► UI
```

### المهام:
- Streaming response consumption
- Incremental text emission
- Typing indicator
- Cancel generation action
- Stream completion handling
- Mid-stream failure recovery
- Retry mechanism
- Persist finalized AI response to local database

---

## Phase 9 — Chat UI

**الهدف:** بناء واجهة الشات بعد اكتمال الـ Domain والـ Data والـ Streaming.

### UI Components & Features:
- `ChatScreen` & responsive layout
- `MessageBubble` (User bubble vs AI bubble)
- Markdown rendering & code block syntax highlighting
- Copy, Regenerate, and Delete actions
- `MessageInputField` & Send button
- Streaming typing indicator
- Auto-scroll to bottom on new chunks

### Flow:
```text
ChatScreen ──► ChatViewModel ──► ChatState ──► UI Widgets
```

---

## Phase 10 — Offline & Reliability

**الهدف:** تحويل التطبيق من مجرد Demo إلى تطبيق Production-Ready موثوق.

### المهام:
- Network connectivity detection
- Offline state handling & banners
- Request retry policies with exponential backoff
- Timeout & rate-limiting handling
- Failed message status & retry buttons
- Request cancellation on screen exit
- Local-first instant message loading

---

## Phase 11 — Advanced Chat Features

**الهدف:** ميزات متقدمة بعد الـ MVP.

### Features:
- Regenerate response
- Edit sent message
- Continue generation
- Delete single message
- Copy formatted response
- Share conversation
- Search across message contents
- AI Model selection (Gemini Pro, Flash, etc.)
- Custom system prompt configuration
- In-place conversation rename

---

## Phase 12 — Settings

### Settings Structure:
```text
Settings
├── Theme (Dark / Light / System)
├── AI Model Preferences
├── Account Management
├── Storage / Data (Clear History)
└── About & Licenses
```

---

## Phase 13 — Comprehensive Testing

**الهدف:** تغطية اختبار شاملة لجميع طبقات التطبيق.

### 1. Unit Tests:
- Entities & Value Objects
- Use Cases (mocking repositories)
- Repositories & DataSources (mocking HTTP/DB clients)
- ViewModels & State emission sequences
- Mappers & Error converters

### 2. Widget Tests:
- `LoginScreen`
- `HomeScreen` & `ConversationList`
- `ChatScreen` & `MessageBubble`
- `SettingsScreen`

### 3. Integration Tests:
```text
Login ──► Create Chat ──► Send Message ──► Stream Response ──► Close App ──► Reopen App ──► Restore Chat
```

---

## Phase 14 — Performance Optimization

**الهدف:** قياس وتحسين الأداء بواسطة Flutter DevTools بدل التخمين.

### مجالات الفحص:
- Widget rebuild analysis (استخدام `const` و `Selector`)
- Memory leaks & stream subscription management
- Startup time optimization
- Large conversation list virtualization (`ListView.builder`)
- Database indexing & query execution times
- Streaming repaint frequency
- Image & asset caching

---

## Phase 15 — Security

### مراجعة الأمان:
- حماية API Keys (استخدام `--dart-define` أو Backend proxy)
- تأمين Environment variables
- تشفير Local storage / Session tokens
- إزالة السجلات الحساسة (Logs) في Release mode
- مراجعة إعدادات الـ Release Build

> [!CAUTION]
> لا تضع Gemini API Key مكشوفاً داخل الكود المصدري أو مستودع Git أبداً.

---

## Phase 16 — Documentation

**الهدف:** توثيق المشروع ليصبح Portfolio Project متكامل ومعياري.

### Structure:
```text
docs/
├── architecture/
│   ├── overview.md
│   └── adr/
│       ├── ADR-001-feature-first.md
│       ├── ADR-002-mvvm.md
│       └── ADR-003-repository-pattern.md
├── development/
│   └── workflow.md
├── diagrams/
│   ├── architecture.md
│   ├── data-flow.md
│   └── authentication.md
└── decisions/
```

---

## Phase 17 — Portfolio Polish

**الهدف:** اللمسات النهائية للمشروع والمظهر العام.

### المهام:
- App Icon & Splash Screen
- Final UI polish & micro-animations
- Empty & Error states styling
- High-resolution screenshots
- Demo video / GIF walkthrough
- GitHub repo cleanup & badges
- Professional README & architecture highlights
- LinkedIn showcase post

---

## الشكل النهائي للمشروع

```text
                    BrainBox AI
                         │
          ┌──────────────┴──────────────┐
          │                             │
     Presentation                      Core
          │                             │
        MVVM                      Infrastructure
          │                             │
       UseCases                     Database
          │                        Networking
        Domain                       Errors
          │
    Repository Contract
          │
    ┌─────┴──────┐
    │            │
  Remote        Local
    │            │
  Gemini       Drift
```

---

## ترتيب التنفيذ الفعلي

```text
Phase 0   Architecture & Planning
   ↓
Phase 1   Project Foundation
   ↓
Phase 2   Design System & UI Foundation
   ↓
Phase 3   Authentication
   ↓
Phase 4   Local Database (Drift)
   ↓
Phase 5   Conversations (Recent Chats)
   ↓
Phase 6   Chat Domain (Contracts & Use Cases)
   ↓
Phase 7   AI Provider (Gemini Integration)
   ↓
Phase 8   Streaming Chat
   ↓
Phase 9   Chat UI
   ↓
Phase 10  Offline & Reliability
   ↓
Phase 11  Advanced Chat Features
   ↓
Phase 12  Settings
   ↓
Phase 13  Comprehensive Testing
   ↓
Phase 14  Performance Profiling
   ↓
Phase 15  Security Audit
   ↓
Phase 16  Architecture Documentation
   ↓
Phase 17  Portfolio Polish
```