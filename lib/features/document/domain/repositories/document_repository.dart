import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, DocumentEntity>> uploadDocument(String filePath, String userId);
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String userId);
  Future<Either<Failure, DocumentEntity>> getDocument(String documentId);
  Future<Either<Failure, DocumentEntity>> addField(String documentId, FieldEntity field);
  Future<Either<Failure, DocumentEntity>> updateField(String documentId, FieldEntity field);
  Future<Either<Failure, DocumentEntity>> deleteField(String documentId, String fieldId);
  Future<Either<Failure, String>> exportFields(List<FieldEntity> fields);
  Future<Either<Failure, List<FieldEntity>>> importFields(String jsonString);
  Future<Either<Failure, DocumentEntity>> publishDocument(String documentId);
  Future<Either<Failure, String>> generatePdf(DocumentEntity document);
}