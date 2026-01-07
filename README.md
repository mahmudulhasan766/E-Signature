# e_signature

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# E-Signature Mobile Application

A Flutter-based mobile application for electronic document signing with field placement, JSON import/export, and PDF generation capabilities.

## Features

- ✅ Firebase Authentication (Email/Password)
- ✅ Document Upload (PDF, DOCX)
- ✅ Interactive Field Placement
    - Signature fields
    - Text fields
    - Checkboxes
    - Date fields
- ✅ Drag & Drop field positioning
- ✅ JSON Import/Export for field configurations
- ✅ Document Publishing workflow
- ✅ Signing mode with field validation
- ✅ Final PDF generation with filled fields
- ✅ Clean Architecture with Cubit state management

## Architecture

This project follows Clean Architecture principles with three main layers:

### 1. Presentation Layer
- UI Components (Pages, Widgets)
- Cubit for state management
- State classes

### 2. Domain Layer
- Business logic entities
- Repository interfaces
- Use cases

### 3. Data Layer
- Repository implementations
- Data sources (Remote/Local)
- Models

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: flutter_bloc (Cubit)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **PDF**: Syncfusion PDF library
- **Dependency Injection**: GetIt
- **Functional Programming**: Dartz

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account
- Android Studio / VS Code

### Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. **For Android:**
    - Download `google-services.json`
    - Place it in `android/app/`

3. **For iOS:**
    - Download `GoogleService-Info.plist`
    - Place it in `ios/Runner/`

4. Enable Firebase services:
    - Authentication: Enable Email/Password
    - Firestore: Create database
    - Storage: Create storage bucket

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd esignature_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

See architecture documentation above for detailed project structure.

## Usage Flow

1. **Login/Signup** → Authenticate with Firebase
2. **Upload Document** → Select PDF or DOCX file
3. **Edit Mode** → Place signature, text, checkbox, and date fields
4. **Export/Import** → Save or load field configurations as JSON
5. **Publish** → Lock field positions and enter signing mode
6. **Sign** → Fill all required fields
7. **Generate PDF** → Create final signed document

## Flutter Packages Used

- `flutter_bloc`: State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Firebase services
- `syncfusion_flutter_pdf`, `syncfusion_flutter_pdfviewer`: PDF handling
- `file_picker`: Document selection
- `signature`: Signature pad widget
- `get_it`: Dependency injection
- `dartz`: Functional programming
- `equatable`: Value equality
- `uuid`: Unique ID generation

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## License

This project is created as part of a technical assessment.

## Contact

For questions or issues, please contact the development team.
