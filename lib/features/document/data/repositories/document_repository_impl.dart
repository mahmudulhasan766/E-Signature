
// lib/features/document/data/repositories/document_repository_impl.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/exceptions.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/features/document/data/datasources/document_local_datasource.dart';
import 'package:e_signature/features/document/data/datasources/document_remote_datasource.dart';
import 'package:e_signature/features/document/data/models/document_model.dart';
import 'package:e_signature/features/document/data/models/field_model.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;
  final DocumentLocalDataSource localDataSource;

  DocumentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument(
      String filePath,
      String userId,
      ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Left(FileFailure('File not found'));
      }

      final document = await remoteDataSource.uploadDocument(file, userId);
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to upload document'));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments(String userId) async {
    try {
      final documents = await remoteDataSource.getDocuments(userId);
      return Right(documents);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get documents'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> getDocument(String documentId) async {
    try {
      final document = await remoteDataSource.getDocument(documentId);
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get document'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> addField(
      String documentId,
      FieldEntity field,
      ) async {
    try {
      final document = await remoteDataSource.getDocument(documentId);
      final updatedFields = List<FieldEntity>.from(document.fields)..add(field);
      final updatedDocument = document.copyWith(fields: updatedFields);

      await remoteDataSource.updateDocument(DocumentModel.fromEntity(updatedDocument));
      return Right(updatedDocument);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to add field'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> updateField(
      String documentId,
      FieldEntity field,
      ) async {
    try {
      final document = await remoteDataSource.getDocument(documentId);
      final updatedFields = document.fields.map((f) {
        return f?.id == field.id ? field : f;
      }).toList();

      final updatedDocument = document.copyWith(fields: updatedFields);
      await remoteDataSource.updateDocument(DocumentModel.fromEntity(updatedDocument));
      return Right(updatedDocument);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update field'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> deleteField(
      String documentId,
      String fieldId,
      ) async {
    try {
      final document = await remoteDataSource.getDocument(documentId);
      final updatedFields = document.fields.where((f) => f.id != fieldId).toList();
      final updatedDocument = document.copyWith(fields: updatedFields);

      await remoteDataSource.updateDocument(DocumentModel.fromEntity(updatedDocument));
      return Right(updatedDocument);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete field'));
    }
  }

  @override
  Future<Either<Failure, String>> exportFields(List<FieldEntity> fields) async {
    try {
      final jsonString = FieldModel.fieldsToJsonString(fields);
      return Right(jsonString);
    } catch (e) {
      return Left(ValidationFailure('Failed to export fields'));
    }
  }

  @override
  Future<Either<Failure, List<FieldEntity>>> importFields(String jsonString) async {
    try {
      final fields = FieldModel.fieldsFromJsonString(jsonString);
      return Right(fields);
    } on FormatException {
      return const Left(ValidationFailure('Invalid JSON format'));
    } catch (e) {
      return Left(ValidationFailure('Failed to import fields'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> publishDocument(String documentId) async {
    try {
      final document = await remoteDataSource.getDocument(documentId);
      final publishedDocument = document.copyWith(
        isPublished: true,
        publishedAt: DateTime.now(),
      );

      await remoteDataSource.updateDocument(DocumentModel.fromEntity(publishedDocument));
      return Right(publishedDocument);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to publish document'));
    }
  }

  @override
  Future<Either<Failure, String>> generatePdf(DocumentEntity document) async {
    try {
      // PDF generation logic will be implemented in the utility class
      // This is a placeholder that returns the path where PDF will be saved
      final fileName = '${document.name.split('.').first}_signed.pdf';
      // The actual PDF generation will be handled by a utility service
      return Right(fileName);
    } catch (e) {
      return Left(ServerFailure('Failed to generate PDF'));
    }
  }
}