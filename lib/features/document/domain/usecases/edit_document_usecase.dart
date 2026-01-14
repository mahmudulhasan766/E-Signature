import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class GetDocumentUseCase implements UseCase<DocumentEntity, GetDocumentParams> {
  final DocumentRepository repository;

  GetDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(GetDocumentParams params) async {
    return await repository.getDocument(params.documentId);
  }
}

class GetDocumentParams {
  final String documentId;

  GetDocumentParams({required this.documentId});
}

class UpdateFieldUseCase implements UseCase<DocumentEntity, UpdateFieldParams> {
  final DocumentRepository repository;

  UpdateFieldUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UpdateFieldParams params) async {
    return await repository.updateField(params.documentId, params.field);
  }
}

class UpdateFieldParams {
  final String documentId;
  final FieldEntity field;

  UpdateFieldParams({required this.documentId, required this.field});
}

class DeleteFieldUseCase implements UseCase<DocumentEntity, DeleteFieldParams> {
  final DocumentRepository repository;

  DeleteFieldUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(DeleteFieldParams params) async {
    return await repository.deleteField(params.documentId, params.fieldId);
  }
}

class DeleteFieldParams {
  final String documentId;
  final String fieldId;

  DeleteFieldParams({required this.documentId, required this.fieldId});
}