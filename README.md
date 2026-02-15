# PrepPal - Food Waste Management System

A Flutter mobile application for managing food inventory and reducing waste in food businesses.

## Features

- **Onboarding Flow**: 5-page introduction to app features
- **User Authentication**: Login and signup with persistent session
- **Home Dashboard**: Overview of inventory and waste metrics
- **Inventory Management**: Track food items and expiry dates
- **Waste Logging**: Record and analyze food waste
- **Analytics**: Reports and insights on waste reduction

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

```bash
# Clone the repository
git clone https://github.com/Amyy16/preppal-mobile.git

# Navigate to project directory
cd prepal_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── onboarding/          # Onboarding screens
│   ├── auth/                # Login/Signup screens
│   ├── home/                # Home dashboard
│   ├── welcome/             # Splash screen
│   ├── inventory/           # Inventory management
│   ├── waste_log/           # Waste logging
│   └── analytics/           # Analytics screens
├── models/                   # Data models
├── providers/               # State management
└── services/                # API services
```

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **SharedPreferences**: Local data persistence

## Contributing

This is a capstone project for Group 12. For contributions, please create a pull request.

## License

This project is for educational purposes.
