import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/core/usecase/usecase.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';

class ExportFieldsUseCase implements UseCase<String, ExportFieldsParams> {
  final DocumentRepository repository;

  ExportFieldsUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportFieldsParams params) async {
    return await repository.exportFields(params.fields);
  }
}

class ExportFieldsParams {
  final List<FieldEntity> fields;

  ExportFieldsParams({required this.fields});
}
