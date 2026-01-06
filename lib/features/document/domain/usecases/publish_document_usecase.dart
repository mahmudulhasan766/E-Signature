import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class PublishDocumentUseCase implements UseCase<DocumentEntity, PublishDocumentParams> {
  final DocumentRepository repository;

  PublishDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(PublishDocumentParams params) async {
    return await repository.publishDocument(params.documentId);
  }
}

class PublishDocumentParams {
  final String documentId;

  PublishDocumentParams({required this.documentId});
}