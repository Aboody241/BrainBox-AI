# BrainBox AI — Development Workflow

## 1. Purpose

This document defines the development workflow for BrainBox AI.

The goal is to keep implementation aligned with the architecture defined in `README.md` and prevent the project from gradually becoming inconsistent or tightly coupled.

The workflow follows:

```text
Requirement
    ↓
Design
    ↓
Architecture Decision
    ↓
Domain
    ↓
Data
    ↓
Presentation
    ↓
Testing
    ↓
Review
    ↓
Refactor
    ↓
Documentation
```

---

## 2. Core Development Rule

Before writing code, answer:

1. **What problem am I solving?**
2. **Which layer owns this responsibility?**
3. **What abstraction should this component depend on?**
4. **How will I test it?**

*Do not start by creating widgets or API calls.*

---

## 3. Feature Development Workflow

Every feature follows this sequential process:

```text
 1. Define Requirement
         ↓
 2. Define User Flow
         ↓
 3. Define Domain Behavior
         ↓
 4. Define Entities
         ↓
 5. Define Repository Contract
         ↓
 6. Define Use Case
         ↓
 7. Implement Data Layer
         ↓
 8. Implement ViewModel
         ↓
 9. Implement UI
         ↓
10. Add Tests
         ↓
11. Refactor
         ↓
12. Document
```

---

## 4. Step 1 — Define the Requirement

Before implementation, write the requirement in simple terms.

**Example:**
> The user should be able to send a message and receive a streamed AI response.

**Define:**
- **Input**:
  - User message
  - Conversation ID
  - Selected model
- **Output**:
  - AI response stream
  - Final message
- **Possible Failures**:
  - Network failure
  - Authentication failure
  - Rate limit
  - Timeout
  - Invalid response
  - Unknown error

---

## 5. Step 2 — Define the User Flow

```text
User opens conversation
        ↓
User types message
        ↓
User presses Send
        ↓
Message appears immediately
        ↓
Message is persisted locally
        ↓
Request is sent to AI provider
        ↓
AI response starts streaming
        ↓
UI updates incrementally
        ↓
Stream completes
        ↓
Final response is persisted
```

---

## 6. Step 3 — Identify the Feature

Determine which feature owns the behavior:

- **Authentication** → `lib/features/auth/`
- **Chat** → `lib/features/chat/`
- **Recent Chats** → `lib/features/conversations/`
- **Settings** → `lib/features/settings/`

*Do not put feature-specific logic inside `core/`. `core/` is only for genuinely shared infrastructure.*

---

## 7. Step 4 — Define Domain Behavior

Ask: *What does the application actually need to do?*

- For sending a message: `SendMessage`
- For loading conversations: `GetConversations`
- For deleting a conversation: `DeleteConversation`

*The domain should describe behavior without knowing how it is implemented.*

---

## 8. Step 5 — Define Entities

```dart
class Message {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
}
```

The entity represents core business meaning. It must **not** depend on:
- Flutter UI
- Dio / HTTP clients
- Gemini SDK
- Drift / SQLite
- Firebase
- JSON serialization annotations (keep DTOs in Data layer)

---

## 9. Step 6 — Define Repository Contracts

The domain defines the abstraction interface:

```dart
abstract interface class ChatRepository {
  Stream<String> sendMessage({
    required String conversationId,
    required String message,
  });

  Future<List<Message>> getMessages(
    String conversationId,
  );
}
```

*The domain does not care whether the implementation uses Gemini, OpenAI, REST API, or a local mock.*

---

## 10. Step 7 — Create Use Cases

Use Cases encapsulate a single, focused application action:

- `SendMessage`
- `GetMessages`
- `CreateConversation`
- `DeleteConversation`
- `RenameConversation`
- `RegenerateMessage`

**Example:**
```dart
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Stream<String> call({
    required String conversationId,
    required String message,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      message: message,
    );
  }
}
```

---

## 11. Step 8 — Implement Data Layer

Only after the domain contract exists should infrastructure be implemented.

```text
features/chat/data/
├── datasources/
├── models/
├── mappers/
└── repositories/
```

---

## 12. Remote Data Source

The Remote Data Source communicates with external APIs (e.g. `GeminiRemoteDataSource`).

**Responsibilities:**
- HTTP / API communication
- Request creation & authentication headers
- Raw response parsing & DTO mapping
- Streaming connection
- Provider-specific error catching

**Forbidden:**
- Updating UI
- Managing application state
- Navigation
- Widget logic

---

## 13. Local Data Source

Manages persistent on-device storage (e.g. `ChatLocalDataSource` with Drift/SQLite).

**Responsibilities:**
- Save messages & conversations
- Load messages & conversations
- Delete records
- Reactive query streams

*Must not contain any presentation or navigation logic.*

---

## 14. Repository Implementation

The Repository coordinates data sources and maps models to domain entities:

```text
        ┌──────────────────┐
        │ Remote DataSource│
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Repository Impl  │
        └────────┬─────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Local DataSource │
        └──────────────────┘
```

**The Repository decides:**
- Where data comes from (local cache vs. remote API)
- When to cache / persist locally
- How to combine local + remote streams
- How infrastructure failures translate into Domain failures

---

## 15. Step 9 — Presentation Layer

After Domain and Data layers are ready, build the presentation layer.

```text
features/chat/presentation/
├── screens/
├── viewmodels/
├── states/
└── widgets/
```

---

## 16. View

**Responsible for:**
- Rendering UI components
- Handling user taps & inputs
- Listening to ViewModel state
- Displaying loading, error, and success states

**Forbidden:**
- Calling APIs or querying databases
- Instantiating repositories or data sources directly
- Containing business rules

---

## 17. ViewModel

The ViewModel manages presentation state and coordinates user actions:

```text
ChatScreen ──► ChatViewModel ──► SendMessage UseCase ──► ChatRepository
```

**Handles:**
- Loading & streaming status
- Success & failure mapping
- Retrying failed operations
- User event handling

---

## 18. State Management Workflow

Use immutable state classes:

```text
ChatState (Initial | Loading | Streaming | Success | Failure)
```

**Standard Transitions:**
```text
Initial ──► Loading ──► Streaming ──► Success
               │
               ▼
            Failure ──(Retry)──► Loading
```

---

## 19. Chat Streaming Workflow

```text
User presses Send
        ↓
ViewModel.sendMessage()
        ↓
SendMessage UseCase
        ↓
ChatRepository
        ↓
RemoteDataSource
        ↓
Gemini API
        ↓
Stream<String>
        ↓
ViewModel receives chunks
        ↓
Update ChatState (streamingMessage)
        ↓
UI rebuilds incrementally
        ↓
Stream completes
        ↓
Persist final message to Local DataSource
```

---

## 20. Optimistic Message Rendering

The user's message should appear in the UI immediately without blocking on network latency:

```text
User sends message
        ↓
Add user message to local UI state
        ↓
Persist user message in local DB
        ↓
Start remote API request
        ↓
Stream AI response
```

---

## 21. Error Workflow

Every asynchronous operation must define clear failure handling:

```text
Operation
    │
    ├──► Success ─────────────► Update State with Data
    │
    └──► Failure
            ↓
       Map Exception to Domain Failure
            ↓
       Set Failure State
            ↓
       Show UI Feedback (SnackBar / Banner)
            ↓
       Allow User Retry
```

---

## 22. Error Mapping

Infrastructure exceptions must be caught and mapped to domain failures:

```text
[DioException / SocketException]    ──► NetworkFailure
[TimeoutException]                  ──► TimeoutFailure
[GeminiException (500 / 503)]       ──► ServerFailure
[DatabaseException / SqliteError]   ──► DatabaseFailure
[RateLimitException (429)]          ──► RateLimitFailure
[Unhandled / PlatformException]     ──► UnknownFailure
```

*The UI must never depend on or parse `DioException` or `SqliteException`.*

---

## 23. Authentication Workflow

```text
             App Launch
                 │
                 ▼
          Check Session
                 │
        ┌────────┴────────┐
        ▼                 ▼
 ┌───────────────┐ ┌─────────────────┐
 │ Authenticated │ │ Not Authenticated│
 └───────┬───────┘ └────────┬────────┘
         │                  │
         ▼                  ▼
    /home Screen       /login Screen
```

---

## 24. Conversation Workflows

### Create Conversation
```text
User starts new chat ──► CreateConversationUseCase ──► Repository ──► Local DB ──► Navigate to /chat/:id
```

### Load Recent Chats
```text
HomeScreen ──► GetConversationsUseCase ──► Repository ──► Local DB ──► Recent Chats UI
```

### Delete Conversation
```text
User selects Delete ──► Confirmation Dialog ──► DeleteConversationUseCase ──► Repository ──► Local DB ──► Update UI
```

---

## 25. Dependency Injection Workflow

Dependencies are wired at the application composition root (`lib/app/di/`):

```text
main.dart
    ↓
App Initialization
    ↓
Dependency Container (GetIt)
    ├── DataSources
    ├── Repositories
    ├── Use Cases
    └── ViewModels
```

**Resolution Flow:**
```text
GeminiRemoteDataSource ──► ChatRepositoryImpl ──► SendMessage UseCase ──► ChatViewModel
```

*Never instantiate infrastructure or services directly inside ViewModels or Widgets.*

---

## 26. Testing Workflow

Every feature follows testing across layers:

```text
Implementation ──► Unit Tests ──► Widget Tests ──► Integration Tests
```

---

## 27. Unit Testing Workflow

**Example for `SendMessage` Use Case:**
```text
SendMessage UseCase ──► MockChatRepository
```
**Verify:**
- Repository method called with correct arguments
- Returns expected stream / result
- Propagates domain failures correctly

---

## 28. ViewModel Testing

**Test state emissions:**
```text
chatViewModel.sendMessage()
    ↓
expectLater(states, [
  ChatState(status: Loading),
  ChatState(status: Streaming, streamingMessage: "..."),
  ChatState(status: Success),
])
```

---

## 29. Widget Testing

Test user-visible behavior and interactions:
- Enter text into `MessageInput`
- Tap `Send` button
- Verify user bubble renders immediately
- Verify streaming indicator appears
- Verify completion text displays

---

## 30. Integration Testing

Focus on complete end-to-end user journeys:

```text
Login ──► Create Chat ──► Send Message ──► Stream AI Response ──► Close App ──► Reopen App ──► Verify History Restored
```

---

## 31. Git Workflow

Use feature branches and small, meaningful commits:

```text
main
 │
 ├── feature/auth
 ├── feature/chat
 ├── feature/conversations
 └── feature/settings
```

**Flow:**
```text
Create branch ──► Implement ──► Run Analyzer ──► Run Tests ──► Review Diff ──► Commit ──► Merge
```

---

## 32. Commit Convention

Use standard conventional commit prefixes:
- `feat:` (new feature)
- `fix:` (bug fix)
- `refactor:` (code change that neither fixes a bug nor adds a feature)
- `test:` (adding or updating tests)
- `docs:` (documentation changes)
- `chore:` (build process, dependencies, auxiliary tools)
- `perf:` (performance improvement)

**Examples:**
- `feat: implement chat domain and use cases`
- `feat: add Gemini streaming integration`
- `fix: handle streaming timeout gracefully`
- `test: add chat view model unit tests`
- `refactor: simplify chat state model`
- `docs: add local storage ADR`

---

## 33. Code Review Checklist

Before merging a pull request or completing a task:

- [ ] Does this follow the architecture guidelines?
- [ ] Is the responsibility placed in the correct layer?
- [ ] Is the dependency direction correct (inward toward Domain)?
- [ ] Are abstractions justified and minimal?
- [ ] Is the ViewModel focused and not a "God class"?
- [ ] Is business logic kept out of UI widgets?
- [ ] Is infrastructure kept out of Domain entities/use cases?
- [ ] Are all error, loading, and empty states handled?
- [ ] Are unit/widget tests included?
- [ ] Does `flutter analyze` pass with zero warnings?
- [ ] Is documentation / ADR updated if architecture changed?

---

## 34. Refactoring Workflow

Refactor when:
- A class becomes too large or handles multiple responsibilities
- Coupling between classes increases
- Writing unit tests becomes difficult or requires excessive mocking

*Do not refactor solely to create more files — every refactoring must improve clarity or testability.*

---

## 35. Architecture Review

Before introducing a new abstraction, ask:

1. **Why does it exist?**
2. **What problem does it solve?**
3. **Could the project remain simpler without it?**
4. **Does it improve testability or replaceability?**
5. **Does it reduce coupling?**
6. **Will another developer understand it quickly?**

*If the answer to these questions is no, do not add the abstraction.*

---

## 36. Definition of Done

A feature is done when:

- [ ] Requirement and user flow are clearly defined
- [ ] Correct feature module owns the behavior
- [ ] Domain entities and use cases are defined
- [ ] Repository interface is defined in Domain
- [ ] Data sources and repository implementation exist in Data
- [ ] ViewModel manages state and maps failures
- [ ] UI displays loading, success, and error feedback
- [ ] Retry and offline cases are handled appropriately
- [ ] Automated tests pass
- [ ] `flutter analyze` passes with zero issues
- [ ] Git commit message follows conventional commits

---

## 37. Daily Development Loop

```text
Read current task
      ↓
Understand existing architecture
      ↓
Plan smallest slice of work
      ↓
Implement Domain → Data → Presentation
      ↓
Run analyzer (`flutter analyze`)
      ↓
Run tests (`flutter test`)
      ↓
Review diff & Refactor
      ↓
Commit with descriptive message
      ↓
Update documentation
```

---

## 38. Pre-Implementation Checklist

Never immediately jump into writing complex UI or network code. First define:

1. **Requirement & Scope**
2. **User Flow**
3. **Domain Action / Use Case**
4. **Entity Model**
5. **Repository Contract**
6. **Data Source Integration**
7. **State Model**
8. **UI Screen / Widgets**
9. **Unit & Widget Tests**

---

## 39. Architecture Decision Records (ADR) Workflow

When facing significant technical decisions:

```text
Problem / Requirement
         ↓
Explore Alternatives
         ↓
Evaluate Trade-offs
         ↓
Select Solution
         ↓
Document ADR (docs/architecture/adr/)
         ↓
Implement
```

**Example:**
- **Question**: Which local database engine should we use?
- **Alternatives**: Hive, SharedPreferences, SQLite, Drift, Isar.
- **Decision**: Drift (Type-safe reactive relational SQLite).
- **Reason**: Relational support for conversations/messages, SQL schema migrations, and high testability.

---

## 40. Performance Workflow

```text
User reports issue / Bottleneck suspected
        ↓
Profile with Flutter DevTools
        ↓
Identify specific bottleneck (rebuilds, I/O, leaks)
        ↓
Optimize focused area
        ↓
Re-measure to verify improvement
```

**Key Areas to Monitor:**
- Unnecessary widget tree rebuilds (use `const` widgets and targeted selectors)
- Large message list rendering (use `ListView.builder`)
- Database query overhead on main isolate
- Streaming chunk UI repaint frequency

---

## 41. Security Workflow

Before release:

```text
Check hardcoded secrets ──► Check API keys ──► Check logs ──► Check secure storage ──► Verify network endpoints
```

**Never commit:**
- `.env` files
- Plaintext API keys
- Private keys / certificates
- User credentials or session tokens

---

## 42. Release Workflow

```text
Feature Complete
      ↓
Run Analyzer (`flutter analyze`)
      ↓
Run Test Suite (`flutter test`)
      ↓
Run Integration Tests
      ↓
Performance & Security Check
      ↓
Manual QA on Target Devices
      ↓
Build Release Bundle
      ↓
Tag Version in Git (e.g. `v1.0.0`)
      ↓
Release
```

---

## 43. Project-Level Lifecycle

```text
                    ┌───────────────┐
                    │   Requirement │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   User Flow   │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  Architecture │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │    Domain     │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │     Data      │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Presentation  │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │    Testing    │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  Code Review  │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Refactor    │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Documentation │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │    Release    │
                    └───────────────┘
```

---

## 44. Golden Rules

1. **UI never talks directly to infrastructure.**
2. **Domain never depends on infrastructure or Flutter UI.**
3. **ViewModels never instantiate repositories or data sources directly.**
4. **Repositories encapsulate caching and data source coordination.**
5. **Use Cases represent single, meaningful application actions.**
6. **Errors are modeled explicitly with typed Result/Failure abstractions.**
7. **State is predictable, centralized, and immutable.**
8. **Every core business behavior must be testable via unit tests.**
9. **Every abstraction needs a clear, justifiable reason.**
10. **Architecture should make change easier, not make code unnecessarily bloated.**

---

## 45. Final Principle

The objective of this workflow is not to produce the maximum number of layers, classes, interfaces, or files.

The objective is to build a codebase where responsibilities are clear and changes remain predictable:

> *"If this requirement changes tomorrow, how much of the system do I need to change?"*

```text
Simple  ──►  Clear  ──►  Testable  ──►  Decoupled  ──►  Maintainable  ──►  Scalable
```