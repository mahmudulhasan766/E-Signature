import 'package:e_signature/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:e_signature/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:e_signature/features/authentication/domain/repositories/auth_repository.dart';
import 'package:e_signature/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:e_signature/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:e_signature/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:e_signature/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:e_signature/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:e_signature/features/authentication/presentation/cubit/signing_cubit.dart';
import 'package:e_signature/features/document/data/datasources/document_local_datasource.dart';
import 'package:e_signature/features/document/data/datasources/document_remote_datasource.dart';
import 'package:e_signature/features/document/data/repositories/document_repository_impl.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';
import 'package:e_signature/features/document/domain/usecases/add_field_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/export_fields_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/generate_pdf_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/import_fields_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/publish_document_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/upload_document_usecase.dart';
import 'package:e_signature/features/document/presentation/cubit/document_cubit.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Cubit
  sl.registerFactory(
        () => AuthCubit(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<DocumentRemoteDataSource>(
        () => DocumentRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<DocumentLocalDataSource>(
        () => DocumentLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<DocumentRepository>(
        () => DocumentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDocumentUseCase(sl()));
  sl.registerLazySingleton(() => AddFieldUseCase(sl()));
  sl.registerLazySingleton(() => UpdateFieldUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFieldUseCase(sl()));
  sl.registerLazySingleton(() => ExportFieldsUseCase(sl()));
  sl.registerLazySingleton(() => ImportFieldsUseCase(sl()));
  sl.registerLazySingleton(() => PublishDocumentUseCase(sl()));
  sl.registerLazySingleton(() => GeneratePdfUseCase(sl()));

  // Cubits
  sl.registerFactory(
        () => DocumentCubit(
      uploadDocumentUseCase: sl(),
      getDocumentsUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => EditorCubit(
      getDocumentUseCase: sl(),
      addFieldUseCase: sl(),
      updateFieldUseCase: sl(),
      deleteFieldUseCase: sl(),
      exportFieldsUseCase: sl(),
      importFieldsUseCase: sl(),
      publishDocumentUseCase: sl(),
    ),
  );

  sl.registerFactory(
        () => SigningCubit(
      getDocumentUseCase: sl(),
      generatePdfUseCase: sl(),
    ),
  );
}


/*
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
*/