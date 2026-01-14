import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/domain/usecases/add_field_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/edit_document_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/export_fields_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/import_fields_usecase.dart';
import 'package:e_signature/features/document/domain/usecases/publish_document_usecase.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class EditorCubit extends Cubit<EditorState> {
  final GetDocumentUseCase getDocumentUseCase;
  final AddFieldUseCase addFieldUseCase;
  final UpdateFieldUseCase updateFieldUseCase;
  final DeleteFieldUseCase deleteFieldUseCase;
  final ExportFieldsUseCase exportFieldsUseCase;
  final ImportFieldsUseCase importFieldsUseCase;
  final PublishDocumentUseCase publishDocumentUseCase;

  final _uuid = const Uuid();

  EditorCubit({
    required this.getDocumentUseCase,
    required this.addFieldUseCase,
    required this.updateFieldUseCase,
    required this.deleteFieldUseCase,
    required this.exportFieldsUseCase,
    required this.importFieldsUseCase,
    required this.publishDocumentUseCase,
  }) : super(EditorInitial());

  Future<void> loadDocument(String documentId) async {
    emit(EditorLoading());
    final result = await getDocumentUseCase(GetDocumentParams(documentId: documentId));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (document) => emit(EditorLoaded(document: document)),
    );
  }

  void selectFieldType(FieldType fieldType) {
    final currentState = state;
    if (currentState is EditorLoaded) {
      emit(currentState.copyWith(selectedFieldType: fieldType));
    }
  }

  void clearFieldSelection() {
    final currentState = state;
    if (currentState is EditorLoaded) {
      emit(currentState.copyWith(clearSelection: true));
    }
  }

  Future<void> addField(double x, double y, int pageNumber) async {
    final currentState = state;
    if (currentState is! EditorLoaded || currentState.selectedFieldType == null) {
      return;
    }

    emit(EditorLoading());

    final field = FieldEntity(
      id: _uuid.v4(),
      type: currentState.selectedFieldType!,
      x: x,
      y: y,
      width: _getDefaultWidth(currentState.selectedFieldType!),
      height: _getDefaultHeight(currentState.selectedFieldType!),
      pageNumber: pageNumber,
    );

    final result = await addFieldUseCase(AddFieldParams(
      documentId: currentState.document.id,
      field: field,
    ));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (document) => emit(EditorLoaded(
        document: document,
        selectedFieldType: currentState.selectedFieldType,
      )),
    );
  }

  Future<void> updateField(FieldEntity field) async {
    final currentState = state;
    if (currentState is! EditorLoaded) return;

    emit(EditorLoading());
    final result = await updateFieldUseCase(UpdateFieldParams(
      documentId: currentState.document.id,
      field: field,
    ));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (document) => emit(EditorLoaded(document: document)),
    );
  }

  Future<void> deleteField(String fieldId) async {
    final currentState = state;
    if (currentState is! EditorLoaded) return;

    emit(EditorLoading());
    final result = await deleteFieldUseCase(DeleteFieldParams(
      documentId: currentState.document.id,
      fieldId: fieldId,
    ));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (document) => emit(EditorLoaded(document: document)),
    );
  }

  Future<void> exportFields() async {
    final currentState = state;
    if (currentState is! EditorLoaded) return;

    final result = await exportFieldsUseCase(ExportFieldsParams(
      fields: currentState.document.fields,
    ));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (jsonData) => emit(EditorFieldsExported(jsonData)),
    );
  }

  Future<void> importFields(String jsonString) async {
    final result = await importFieldsUseCase(ImportFieldsParams(
      jsonString: jsonString,
    ));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (fields) => emit(EditorFieldsImported(fields)),
    );
  }

  Future<void> applyImportedFields(List<FieldEntity> fields) async {
    final currentState = state;
    if (currentState is! EditorLoaded) return;

    emit(EditorLoading());

    DocumentEntity updatedDocument = currentState.document;

    for (final field in fields) {
      final result = await addFieldUseCase(AddFieldParams(
        documentId: updatedDocument.id,
        field: field,
      ));

      result.fold(
            (failure) {
          emit(EditorError(failure.message));
          return;
        },
            (document) => updatedDocument = document,
      );
    }

    emit(EditorLoaded(document: updatedDocument));
  }

  Future<void> publishDocument() async {
    final currentState = state;
    if (currentState is! EditorLoaded) return;

    emit(EditorLoading());
    final result = await publishDocumentUseCase(PublishDocumentParams(
      documentId: currentState.document.id,
    ));

    result.fold(
          (failure) => emit(EditorError(failure.message)),
          (document) => emit(EditorPublished(document)),
    );
  }

  double _getDefaultWidth(FieldType type) {
    switch (type) {
      case FieldType.signature:
        return 180.0;
      case FieldType.textbox:
        return 200.0;
      case FieldType.checkbox:
        return 30.0;
      case FieldType.date:
        return 150.0;
    }
  }

  double _getDefaultHeight(FieldType type) {
    switch (type) {
      case FieldType.signature:
        return 60.0;
      case FieldType.textbox:
        return 40.0;
      case FieldType.checkbox:
        return 30.0;
      case FieldType.date:
        return 40.0;
    }
  }
}

