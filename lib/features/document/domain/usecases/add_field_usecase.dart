import 'package:dartz/dartz.dart';
import 'package:e_signature/core/errors/failures.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/domain/repositories/document_repository.dart';
import '../../../../core/usecase/usecase.dart';

class AddFieldUseCase implements UseCase<DocumentEntity, AddFieldParams> {
  final DocumentRepository repository;

  AddFieldUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(AddFieldParams params) async {
    return await repository.addField(params.documentId, params.field);
  }
}

class AddFieldParams {
  final String documentId;
  final FieldEntity field;

  AddFieldParams({required this.documentId, required this.field});
}
