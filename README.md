# Flutter MVVM Starter Template

A clean, beginner-friendly Flutter starter template using **MVVM** architecture with **Cubit** for state management and **Dio** for networking.

---

## 📁 Folder Structure

```
flutter_mvvm_starter/
├── assets/                           # Outside lib — images, fonts, icons
│   ├── images/
│   ├── icons/
│   └── fonts/
│
└── lib/
    ├── main.dart                     # Entry point
    │
    ├── features/                     # One folder per feature
    │   └── example/
    │       ├── model/
    │       │   └── example_model.dart          # Feature-specific model
    │       ├── viewmodel/
    │       │   ├── example_cubit.dart
    │       │   └── example_state.dart
    │       └── view/
    │           └── example_view.dart
    │
    └── core/                         # Shared across ALL features
        ├── models/                   # Shared models (used by 2+ features)
        │   ├── user_model.dart
        │   └── pagination_model.dart
        ├── services/                 # Networking layer
        │   ├── dio_client.dart       # Dio initialization & interceptors
        │   ├── api_service.dart      # Generic GET/POST/PUT/DELETE
        │   └── endpoints.dart        # All API endpoint constants
        ├── widgets/                  # Reusable UI components
        │   ├── app_button.dart
        │   ├── app_text_field.dart
        │   ├── app_loading_widget.dart
        │   └── app_error_widget.dart
        ├── styles/                   # Theming & design tokens
        │   ├── app_colors.dart
        │   ├── app_text_styles.dart
        │   └── app_theme.dart
        ├── utils/                    # Utilities & constants
        │   ├── constants.dart
        │   ├── app_strings.dart
        │   └── network_exceptions.dart
        └── routes/                   # Navigation
            ├── app_routes.dart       # Named route strings
            └── app_pages.dart        # Route → Widget mapping
```

---

## 🏗️ Architecture: MVVM

```
  ┌──────────┐      emits states      ┌───────────┐      calls      ┌─────────────┐
  │   View   │ ◄──────────────────── │  Cubit    │ ───────────────► │ ApiService  │
  │ (Widget) │                        │(ViewModel)│                  │  + DioClient│
  └──────────┘                        └───────────┘                  └─────────────┘
       │                                    │                               │
  BlocBuilder                          ExampleState                   Dio HTTP call
  reacts to state                    Loading/Success/Error            → API endpoint
```

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **Model** | `features/x/model/` أو `core/models/` | Pure data classes with `fromJson` / `toJson` |
| **View** | `features/x/view/` | Widgets only — no logic, uses `BlocBuilder` |
| **ViewModel** | `features/x/viewmodel/` | Cubits — calls services, emits states |
| **Service** | `core/services/` | Dio setup, HTTP methods, endpoints |

### 📌 Model Placement Rule
| الحالة | المكان |
|--------|--------|
| Model بيستخدمه فيتشر واحد بس | `features/x/model/` |
| Model بيستخدمه أكتر من فيتشر | `core/models/` |

---

## ⚙️ Key Files Explained

### `services/dio_client.dart`
The single Dio instance for the app. Configures:
- `baseUrl` from `Constants.baseUrl`
- Default headers (`Content-Type`, `Accept`)
- Connect / receive / send timeouts
- **Auth interceptor** (ready for token injection from secure storage)
- **PrettyDioLogger** for readable request/response logs in debug mode
- All Dio errors are caught and converted to `NetworkExceptions`

### `services/api_service.dart`
Typed wrapper around `DioClient`. Provides `get`, `post`, `put`, `delete`, and `uploadFile` methods. Feature services can use this directly or extend it.

### `services/endpoints.dart`
All API paths in one place. Use `Endpoints.posts` instead of `'/posts'` anywhere in the code.

### `utils/network_exceptions.dart`
Maps every `DioException` (timeout, 401, 404, 500, etc.) into a clean `NetworkExceptions` with a user-friendly `message` string. ViewModels catch this and emit `ExampleError(message: e.message)`.

### `styles/app_theme.dart`
Material 3 light and dark themes. All colors, button styles, input styles, and text styles flow from here — no hardcoded values in widgets.

### `routes/app_pages.dart`
The single place that connects a route name string (`AppRoutes.example`) to its View widget. Add every new screen here.

---

## 🔄 MVVM Data Flow (Example Feature)

```
1. ExampleView created
        │
        ▼
2. BlocProvider creates ExampleCubit and calls fetchPosts()
        │
        ▼
3. ExampleCubit emits ExampleLoading → View shows spinner
        │
        ▼
4. ApiService.get(Endpoints.posts) → DioClient.get('/posts')
        │
        ▼
5a. Success → parse JSON → emit ExampleSuccess(posts: [...])
5b. Failure → catch NetworkExceptions → emit ExampleError(message: '...')
        │
        ▼
6. BlocBuilder rebuilds View with new state
   • ExampleLoading   → AppLoadingWidget()
   • ExampleSuccess   → ListView of PostCards
   • ExampleError     → AppErrorWidget(onRetry: fetchPosts)
```

---

## 🚀 Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Update base URL
# Open lib/utils/constants.dart → change Constants.baseUrl

# 3. Run
flutter run
```

---

## ➕ Adding a New Feature

1. إنشاء folder جديد في `lib/features/my_feature/`
2. **Model** → `features/my_feature/model/my_feature_model.dart`
    - لو هيتشارك مع فيتشرز تانية → `core/models/my_feature_model.dart`
3. **State** → `features/my_feature/viewmodel/my_feature_state.dart`
4. **Cubit** → `features/my_feature/viewmodel/my_feature_cubit.dart`
5. **View** → `features/my_feature/view/my_feature_view.dart`
6. **Route** → Add to `core/routes/app_routes.dart` and `app_pages.dart`
7. **Endpoint** → Add to `core/services/endpoints.dart`

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (Cubit) |
| `equatable` | Value equality for states & models |
| `dio` | HTTP client |
| `pretty_dio_logger` | Readable network logs in debug mode |