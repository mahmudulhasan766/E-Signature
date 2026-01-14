import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class UploadDocumentUseCase implements UseCase<DocumentEntity, UploadDocumentParams> {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UploadDocumentParams params) async {
    return await repository.uploadDocument(params.filePath, params.userId);
  }
}

    class UploadDocumentParams {
  final String filePath;
  final String userId;

  UploadDocumentParams({required this.filePath, required this.userId});
}