# Food Waste Management App - Architecture Guide

## 1. Architecture Overview

### Pattern: Clean Architecture + Provider State Management

```
┌─────────────────────────────────────────────────┐
│          Presentation Layer (UI)                │
│    Screens, Widgets, Pages, UI Components       │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│    Business Logic Layer                         │
│  Controllers, State Management (Provider)       │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│      Data Layer                                 │
│  Repositories, Models, APIs, Local DB           │
└─────────────────────────────────────────────────┘
```

### Why This Architecture?
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Easy to unit test business logic independently
- **Reusability**: Shared logic through repositories
- **Scalability**: Easy to add new features without affecting existing code

---

## 2. Folder Structure

```
lib/
├── main.dart                           # Entry point
│
├── core/                               # Shared utilities & constants
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── colors.dart                # Color palette
│   │   └── strings.dart               # All text strings
│   ├── utils/
│   │   ├── validators.dart            # Form validators
│   │   ├── date_formatter.dart        # Date/time helpers
│   │   └── logger.dart                # Logging utility
│   └── theme/
│       └── app_theme.dart             # Theme configuration
│
├── models/                             # Data models (DTOs, entities)
│   ├── user_model.dart
│   ├── food_item_model.dart
│   ├── waste_log_model.dart
│   ├── expense_model.dart
│   └── report_model.dart
│
├── services/                           # External services & APIs
│   ├── api_service.dart               # HTTP client
│   ├── auth_service.dart              # Authentication
│   ├── storage_service.dart           # Local storage
│   └── notification_service.dart      # Push notifications
│
├── repositories/                       # Data repositories (Business rules)
│   ├── auth_repository.dart
│   ├── food_repository.dart
│   ├── waste_repository.dart
│   └── analytics_repository.dart
│
├── providers/                          # State management (Provider)
│   ├── auth_provider.dart             # Auth state
│   ├── food_provider.dart             # Food inventory state
│   ├── waste_provider.dart            # Waste logs state
│   └── analytics_provider.dart        # Reports state
│
├── screens/                            # App pages/screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── inventory/
│   │   ├── inventory_screen.dart
│   │   ├── add_food_screen.dart
│   │   └── food_detail_screen.dart
│   ├── waste_log/
│   │   ├── waste_log_screen.dart
│   │   ├── log_waste_screen.dart
│   │   └── waste_history_screen.dart
│   ├── analytics/
│   │   ├── analytics_screen.dart
│   │   └── report_detail_screen.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   ├── profile_screen.dart
│   │   └── preferences_screen.dart
│   └── common/
│       └── splash_screen.dart
│
├── widgets/                            # Reusable UI components
│   ├── custom_app_bar.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── food_card.dart
│   ├── waste_chart.dart
│   └── loading_widget.dart
│
├── routes/                             # Navigation
│   └── app_routes.dart
│
└── config/                             # Configuration
    └── firebase_config.dart            # If using Firebase
```

---

## 3. Key Features & Modules

### A. Authentication Module
- User registration/login
- Password reset
- Session management
- Business profile setup

### B. Inventory Management
- Add/Edit/Delete food items
- Track quantity & expiration dates
- Categorize items (vegetables, dairy, meat, etc.)
- Low stock alerts

### C. Waste Logging
- Log wasted food with reason
- Attach photos (optional)
- Record quantity & cost
- Timestamp tracking

### D. Analytics & Reporting
- Daily/Weekly/Monthly waste statistics
- Cost analysis
- Waste trends visualization
- Export reports (PDF)

### E. Settings & Admin
- User profile management
- Business settings
- Notification preferences
- Data backup

---

## 4. Data Flow Example: Logging Food Waste

```
1. User taps "Log Waste" button
        ↓
2. WasteLogScreen displays form
        ↓
3. User fills form & submits
        ↓
4. WasteProvider.addWaste() called
        ↓
5. WasteRepository.createWasteLog() 
        ↓
6. API Service sends data to backend
        ↓
7. Backend validates & stores (or Local DB if offline)
        ↓
8. Response received, Provider updates state
        ↓
9. UI refreshes automatically (Provider rebuilds)
        ↓
10. Success message shown to user
```

---

## 5. Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| State Management | Provider (riverpod optional) | Reactive data binding |
| Local Database | Hive / SQLite | Offline capability |
| API Communication | Dio / http | Backend integration |
| Authentication | Firebase Auth / Custom Backend | User management |
| Charts | fl_chart | Data visualization |
| Storage | flutter_secure_storage | Secure credential storage |
| Navigation | Go Router | Modern routing |

---

## 6. State Management Flow (Provider)

```
┌──────────────────┐
│  User Action     │
│  (Tap Button)    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Provider Method │
│  e.g., addWaste()│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Repository Call │
│  fetch/save data │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  List Build()    │
│  Notify rebuild  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  UI Updates      │
│  with new state  │
└──────────────────┘
```

---

## 7. API Endpoints (Backend Integration)

```
Authentication:
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh-token

Food Inventory:
GET    /api/foods              # List all foods
POST   /api/foods              # Add new food
PUT    /api/foods/{id}         # Update food
DELETE /api/foods/{id}         # Delete food

Waste Logs:
GET    /api/waste-logs         # List all waste logs
POST   /api/waste-logs         # Create waste log
GET    /api/waste-logs/{id}    # Get specific log

Analytics:
GET    /api/analytics/summary  # Dashboard summary
GET    /api/analytics/daily    # Daily statistics
GET    /api/analytics/reports  # Generate reports
```

---

## 8. Offline-First Strategy

- Local data caching with Hive/SQLite
- Sync data when connection available
- Queue failed requests for retry
- Conflict resolution between local & cloud data

---

## 9. Error Handling Strategy

```dart
Exception Types:
├── NetworkException       (No internet)
├── ServerException       (API errors)
├── AuthenticationException (Auth failed)
├── ValidationException   (Input validation)
└── CacheException        (Local storage errors)

All exceptions caught in Provider → User sees meaningful error message
```

---

## 10. Development Workflow

```
1. Define models (Data structure)
2. Create repositories (Business logic)
3. Create providers (State management)
4. Build screens (UI)
5. Test each layer independently
6. Integrate & test full flow
7. Deploy to testflight/play store
```

---

## 11. Dependencies to Install

```yaml
# pubspec.yaml additions
dependencies:
  provider: ^6.0.0
  dio: ^5.0.0
  hive: ^2.0.0
  hive_flutter: ^1.1.0
  fl_chart: ^0.63.0
  go_router: ^13.0.0
  flutter_secure_storage: ^9.0.0
  intl: ^0.19.0
  firebase_core: ^2.24.0  # If using Firebase
  
dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

---

## 12. Next Steps

1. Set up folder structure (follow Section 2)
2. Install dependencies
3. Create core utilities & constants
4. Define data models
5. Build repositories
6. Implement providers
7. Create UI screens
8. Test & iterate

---

This architecture ensures your team can work independently on different features without conflicts!
