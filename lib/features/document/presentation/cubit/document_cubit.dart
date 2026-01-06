import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';
import 'package:e_signature/features/document/domain/usecases/upload_document_usecase.dart';
import 'package:e_signature/features/document/presentation/cubit/document_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentCubit extends Cubit<DocumentState> {
  final UploadDocumentUseCase uploadDocumentUseCase;
  final GetDocumentsUseCase getDocumentsUseCase;

  DocumentCubit({
    required this.uploadDocumentUseCase,
    required this.getDocumentsUseCase,
  }) : super(DocumentInitial());

  Future<void> uploadDocument(String filePath, String userId) async {
    emit(DocumentLoading());
    final result = await uploadDocumentUseCase(UploadDocumentParams(
      filePath: filePath,
      userId: userId,
    ));

    result.fold(
          (failure) => emit(DocumentError(failure.message)),
          (document) => emit(DocumentUploaded(document)),
    );
  }

  Future<void> getDocuments(String userId) async {
    emit(DocumentLoading());
    final result = await getDocumentsUseCase(GetDocumentsParams(userId: userId));

    result.fold(
          (failure) => emit(DocumentError(failure.message)),
          (documents) => emit(DocumentsLoaded(documents)),
    );
  }
}

class GetDocumentsUseCase implements UseCase<List<DocumentEntity>, GetDocumentsParams> {
  final DocumentRepository repository;

  GetDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DocumentEntity>>> call(GetDocumentsParams params) async {
    return await repository.getDocuments(params.userId);
  }
}

class GetDocumentsParams {
  final String userId;

  GetDocumentsParams({required this.userId});
}