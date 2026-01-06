import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class ImportFieldsUseCase implements UseCase<List<FieldEntity>, ImportFieldsParams> {
  final DocumentRepository repository;

  ImportFieldsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FieldEntity>>> call(ImportFieldsParams params) async {
    return await repository.importFields(params.jsonString);
  }
}

class ImportFieldsParams {
  final String jsonString;

  ImportFieldsParams({required this.jsonString});
}