# BrainBox AI

A production-oriented Flutter AI chat application designed to demonstrate scalable mobile architecture, clean separation of concerns, asynchronous programming, streaming, persistence, testing, and practical SOLID principles.

**Status:** Architecture defined — implementation not started.

---

## Project Overview

BrainBox AI is a mobile AI chat application built with Flutter and Dart.

The product experience is inspired by modern AI assistants:

- Create and manage conversations
- Send messages to an AI model
- Receive streamed responses
- View recent conversations
- Rename and delete conversations
- Persist conversations locally
- Handle loading, streaming, success, failure, retry, and offline scenarios
- Support authentication and application settings

The primary objective is not to clone an existing AI product. The objective is to demonstrate sound software architecture and engineering practices.

---

## Engineering Goals

This project demonstrates:

- SOLID principles
- MVVM
- Feature-first architecture
- Layered / Clean Architecture principles
- Repository Pattern
- Use Cases
- Dependency Injection
- Unidirectional Data Flow
- Async/Await and Streams
- Local persistence
- Remote API integration
- Error modeling
- Automated testing
- Maintainability
- Scalability

---

## Architecture

The project combines several complementary concepts:

```text
Feature-First
      +
Layered Architecture
      +
MVVM
      +
Repository Pattern
      +
Use Cases
      +
Dependency Injection
      +
Unidirectional Data Flow
      +
SOLID
```

Each concept solves a different problem:

- **SOLID**: Design principles for individual classes and abstractions.
- **MVVM**: Presentation architecture separating UI from presentation logic.
- **Repository Pattern**: Abstracts data access from the rest of the application.
- **Use Cases**: Encapsulate application/domain operations.
- **Dependency Injection**: Provides dependencies from outside rather than constructing them inside consumers.
- **Feature-First**: Organizes code around business features instead of large global folders.

### High-Level Architecture

```text
                         ┌───────────────────────┐
                         │          UI           │
                         │  Screens / Widgets    │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │      ViewModel        │
                         │   UI State / Logic    │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │        Domain         │
                         │ Entities / Use Cases  │
                         │ Repository Contracts  │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │     Repository        │
                         │    Implementation    │
                         └───────────┬───────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    ▼                                 ▼
          ┌──────────────────┐              ┌──────────────────┐
          │   Remote Data    │              │    Local Data    │
          │   Gemini / API   │              │ SQLite / Drift   │
          └──────────────────┘              └──────────────────┘
```

### Dependency Direction

```text
Presentation → Domain
Data         → Domain
Domain       → Nothing external
```

The **Domain layer** must not depend on:
- Flutter UI
- Dio
- Gemini SDK
- Firebase
- Drift / SQLite
- HTTP clients
- Platform-specific APIs

#### Allowed Dependencies Flow
```text
View
 ↓
ViewModel
 ↓
Use Case
 ↓
Repository Interface
 ↓
Repository Implementation
 ↓
Data Source
```

#### Forbidden Dependencies Flow
```text
Widget → Gemini API
Widget → Database
Widget → Dio
ViewModel → Gemini SDK
Domain → Flutter
Domain → Database
Domain → Network Client
Repository → Widget
```

---

## Project Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── di/
│
├── core/
│   ├── error/
│   ├── network/
│   ├── database/
│   ├── result/
│   ├── constants/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── conversations/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── chat/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

### Chat Feature Example

```text
features/chat/
├── data/
│   ├── datasources/
│   │   ├── chat_remote_datasource.dart
│   │   └── chat_local_datasource.dart
│   ├── models/
│   │   ├── message_model.dart
│   │   └── conversation_model.dart
│   └── repositories/
│       └── chat_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── message.dart
│   │   └── conversation.dart
│   ├── repositories/
│   │   └── chat_repository.dart
│   └── usecases/
│       ├── send_message.dart
│       ├── get_messages.dart
│       ├── regenerate_message.dart
│       ├── delete_message.dart
│       └── clear_conversation.dart
│
└── presentation/
    ├── screens/
    │   └── chat_screen.dart
    ├── viewmodels/
    │   └── chat_view_model.dart
    ├── states/
    │   └── chat_state.dart
    └── widgets/
        ├── message_bubble.dart
        ├── message_input.dart
        └── typing_indicator.dart
```

---

## Architecture Layers & Patterns

### 1. MVVM (Model-View-ViewModel)

```text
View  ──►  ViewModel  ──►  State
```

#### View
Responsible for:
- Rendering UI
- Capturing user actions
- Observing state
- Displaying loading/error/success states

*The View must not call APIs, query databases, or contain business rules.*

#### ViewModel
Responsible for:
- Presentation logic
- Handling user actions
- Calling Use Cases
- Managing UI state
- Mapping domain results into UI state

*The ViewModel must not know the concrete AI or database implementation.*

---

### 2. Domain Layer

```text
domain/
├── entities/
├── repositories/
└── usecases/
```

- **Entities**: `Message`, `Conversation`, `User`
- **Repository Contracts**: `ChatRepository`, `ConversationRepository`, `AuthRepository`
- **Use Cases**: `SendMessage`, `GetMessages`, `GetConversations`, `CreateConversation`, `RenameConversation`, `DeleteConversation`, `RegenerateMessage`, `Logout`

*The Domain layer remains completely independent from Flutter and external SDKs.*

---

### 3. Repository Pattern & AI Provider Abstraction

The Domain defines the contract (`ChatRepository`), and the Data layer provides implementations:

```text
               ┌────────────────┐
               │ ChatViewModel  │
               └───────┬────────┘
                       │
                       ▼
               ┌────────────────┐
               │ ChatRepository │ (Domain Interface)
               └───────┬────────┘
                       ▲
         ┌─────────────┴─────────────┐
         │                           │
┌──────────────────┐       ┌──────────────────┐
│ GeminiChatRepo   │       │ OpenAIChatRepo   │
└──────────────────┘       └──────────────────┘
```

#### Initial & Future Providers:
- **Initial**: Gemini API
- **Potential Future**: OpenAI, Anthropic, Local LLMs, Mock Provider

*The UI and ViewModels do not require changes when swapping or adding AI providers.*

---

## Data Flow & Streaming

### Chat Data Flow

```text
[User]
  │
  ▼
[ChatScreen]
  │
  ▼
[ChatViewModel]
  │
  ▼
[SendMessageUseCase]
  │
  ▼
[ChatRepository]
  │
  ▼
[GeminiChatRepository]
  │
  ▼
[RemoteDataSource]
  │
  ▼
[Gemini API]
```

**Response Handling:**
```text
[Gemini API] ──► [RemoteDataSource] ──► [Repository] ──► [UseCase] ──► [ViewModel] ──► [ChatState] ──► [ChatScreen]
```

### Streaming Architecture

The AI response is streamed to provide instantaneous feedback rather than waiting for complete responses.

```text
[Gemini API]
    │
    ▼
Stream<String>
    │
    ▼
[RemoteDataSource]
    │
    ▼
[Repository]
    │
    ▼
[UseCase]
    │
    ▼
[ViewModel]
    │
    ▼
[State]
    │
    ▼
[UI Screen]
```

Streaming supports:
- Incremental token updates
- Stream cancellation
- Error handling mid-stream
- Completion signals
- UI animations
- Persistence of the finalized response

---

## State & Persistence

### State Model

```text
ChatState
├── status (initial | loading | streaming | success | failure)
├── messages
├── conversationId
├── streamingMessage
└── error
```

*An immutable state model is used instead of disjointed boolean flags.*

### Local Persistence (Drift / SQLite)

```text
conversations
-------------------------
id           (TEXT / PRIMARY KEY)
user_id      (TEXT)
title        (TEXT)
model        (TEXT)
created_at   (INTEGER)
updated_at   (INTEGER)

messages
-------------------------
id              (TEXT / PRIMARY KEY)
conversation_id (TEXT / FOREIGN KEY)
role            (TEXT)
content         (TEXT)
created_at      (INTEGER)
status          (TEXT)
```

**Entity Relationship:**
```text
User
 └── Conversations
          └── Messages
```

### Local + Remote Strategy

- **Recent Conversations**:
  ```text
  UI ──► ViewModel ──► GetConversationsUseCase ──► Repository ──► Local Database
  ```
- **Sending a Message**:
  ```text
  User Message ──► Persist locally ──► Send remotely ──► Receive stream ──► Update UI ──► Persist final response
  ```

---

## Infrastructure Concerns

### Authentication

```text
AuthScreen ──► AuthViewModel ──► AuthRepository ──► AuthDataSource ──► Auth Provider (e.g. Firebase)
```

### Routing

Centralized declarative routing (e.g. GoRouter):
- `/splash`
- `/login`
- `/home`
- `/chat/:id`
- `/settings`

### Dependency Injection

Dependencies are injected via constructor to allow seamless testing and decoupling:

❌ **Bad**:
```dart
class ChatViewModel {
  final repository = GeminiChatRepository();
}
```

✅ **Preferred**:
```dart
class ChatViewModel {
  final ChatRepository repository;

  ChatViewModel(this.repository);
}
```

- **Production**: `GeminiChatRepository`
- **Testing**: `MockChatRepository`

### Error Handling

Strongly typed failure modeling wrapped in a `Result<T>` monad (`Success<T>` / `Failure<T>`):

- `NetworkFailure`
- `AuthenticationFailure`
- `ServerFailure`
- `TimeoutFailure`
- `DatabaseFailure`
- `ParsingFailure`
- `RateLimitFailure`
- `UnknownFailure`

*Infrastructure-specific exceptions (DioException, SqliteException) are caught and mapped before reaching the UI.*

---

## SOLID Principles in Practice

- **S — Single Responsibility Principle**: Each component has one primary reason to change.
- **O — Open/Closed Principle**: New AI providers can be added without modifying the Presentation layer.
- **L — Liskov Substitution Principle**: Any valid `ChatRepository` implementation satisfies the domain contract.
- **I — Interface Segregation Principle**: Fine-grained, focused interfaces instead of bloated God-interfaces.
- **D — Dependency Inversion Principle**: High-level application logic depends on domain abstractions, not concrete third-party SDKs.

---

## Testing Strategy

Testing is treated as a first-class architectural requirement:

- **Unit Tests**: Use Cases, ViewModels, Repositories, Mappers, Error handling, Streaming behavior, Business rules.
- **Widget Tests**: `ChatScreen`, `MessageBubble`, `ConversationList`, `LoginScreen`, Loading/Error states, User interactions.
- **Integration Tests**: Full flow — Login → Create Conversation → Send Message → Stream Response → Persist → Restart App → Verify state restored.

---

## Packages & ADRs

### Package Strategy
- `go_router`: Declarative routing
- `dio`: HTTP networking
- `drift` & `sqlite3_flutter_libs`: Structured reactive SQLite persistence
- `get_it`: Service locator / Dependency Injection
- `freezed` & `json_serializable`: Immutable data models and union types

### Architecture Decision Records (ADRs)
Stored under `docs/architecture/adr/`:
- `ADR-001-feature-first.md`
- `ADR-002-mvvm.md`
- `ADR-003-repository-pattern.md`
- `ADR-004-domain-layer.md`
- `ADR-005-local-storage.md`
- `ADR-006-ai-provider-abstraction.md`
- `ADR-007-streaming.md`
- `ADR-008-dependency-injection.md`
- `ADR-009-state-management.md`

---

## Implementation Roadmap

- [ ] **Phase 0 — Architecture**
  - [ ] Define product direction & architecture
  - [ ] Define dependency boundaries & feature structure
  - [ ] Define data flow & persistence strategy
  - [ ] Create ADR documents
- [ ] **Phase 1 — Project Foundation**
  - [ ] Configure linting & dependencies
  - [ ] Set up folder structure, DI, routing, and theme
  - [ ] Implement `Result` abstraction and failure types
- [ ] **Phase 2 — Authentication**
  - [ ] Domain contracts, repositories, and data sources
  - [ ] Login UI, session handling, and tests
- [ ] **Phase 3 — Conversations**
  - [ ] Conversation entity and SQLite Drift tables
  - [ ] Recent chats UI, CRUD operations, and search
- [ ] **Phase 4 — Chat Domain**
  - [ ] Message entity and ChatRepository contract
  - [ ] Use cases (`SendMessage`, `GetMessages`, `RegenerateMessage`, etc.)
  - [ ] Chat state model and ViewModel unit tests
- [ ] **Phase 5 — AI Integration**
  - [ ] Remote data source with Gemini API integration
  - [ ] DTOs, Mappers, and API error handling
- [ ] **Phase 6 — Streaming**
  - [ ] Streaming API, incremental UI updates, cancellation, error recovery
- [ ] **Phase 7 — Persistence**
  - [ ] Drift database message & conversation persistence
  - [ ] Local-first conversation caching and restoration
- [ ] **Phase 8 — Reliability**
  - [ ] Retry, timeout, rate-limit, and offline handling
- [ ] **Phase 9 — Testing**
  - [ ] Unit, widget, and end-to-end integration tests
- [ ] **Phase 10 — Performance**
  - [ ] Rebuild analysis, list view optimization, database indexing
- [ ] **Phase 11 — Documentation**
  - [ ] Final diagrams, setup guides, screenshots
- [ ] **Phase 12 — Portfolio**
  - [ ] Release preparation, portfolio project card, interview walkthrough

---

## Definition of Done

A feature is complete when:
- [ ] Domain behavior exists where required
- [ ] Repository boundary is respected
- [ ] Dependencies are injected
- [ ] UI is separated from data access
- [ ] Loading, Success, and Failure states are handled
- [ ] Relevant edge cases are considered
- [ ] Unit tests exist where appropriate
- [ ] Widget tests exist where appropriate
- [ ] Code follows project conventions
- [ ] No unnecessary coupling was introduced
- [ ] Documentation is updated when architecture changes

---

## Security Rules

- **Secrets must never be committed to Git.**
- Do not place API keys directly inside Dart source code, Git repo, or documentation.
- Use secure environment variables, `--dart-define`, or a backend/proxy architecture in production environments.

---

## Final Architecture Overview

```text
                         ┌──────────────────────┐
                         │        Flutter       │
                         │         UI           │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │      ViewModel       │
                         │    Reactive State    │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │       Use Cases      │
                         │   Application Logic  │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │  Repository Contract │
                         └──────────┬───────────┘
                                    │
                          ┌─────────┴─────────┐
                          ▼                   ▼
                ┌──────────────────┐ ┌──────────────────┐
                │ Repository Impl  │ │ Repository Impl  │
                │      Remote      │ │       Local      │
                └────────┬─────────┘ └────────┬─────────┘
                         │                    │
                         ▼                    ▼
                ┌──────────────────┐ ┌──────────────────┐
                │   Gemini API     │ │  Drift / SQLite  │
                └──────────────────┘ └──────────────────┘
```

---

## Current Project Status

- **Architecture Specification**: COMPLETE
- **Implementation**: NOT STARTED
- **Next Step**: Phase 1 — Project Foundation