import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class GeneratePdfUseCase implements UseCase<String, GeneratePdfParams> {
  final DocumentRepository repository;

  GeneratePdfUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GeneratePdfParams params) async {
    return await repository.generatePdf(params.document);
  }
}

class GeneratePdfParams {
  final DocumentEntity document;

  GeneratePdfParams({required this.document});
}