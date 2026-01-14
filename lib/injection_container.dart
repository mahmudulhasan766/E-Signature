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
import 'package:e_signature/features/document/domain/usecases/get_documentsuse_case.dart';
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

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerFactory(
        () => AuthCubit(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerLazySingleton<DocumentRemoteDataSource>(
        () => DocumentRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<DocumentLocalDataSource>(
        () => DocumentLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<DocumentRepository>(
        () => DocumentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

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
