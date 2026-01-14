import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

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