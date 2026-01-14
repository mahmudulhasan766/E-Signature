
import 'package:e_signature/features/document/domain/usecases/get_documentsuse_case.dart';
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

