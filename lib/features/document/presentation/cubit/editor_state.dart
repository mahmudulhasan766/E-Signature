import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:equatable/equatable.dart';

abstract class EditorState extends Equatable {
  const EditorState();

  @override
  List<Object?> get props => [];
}

class EditorInitial extends EditorState {}

class EditorLoading extends EditorState {}

class EditorLoaded extends EditorState {
  final DocumentEntity document;
  final FieldType? selectedFieldType;

  const EditorLoaded({
    required this.document,
    this.selectedFieldType,
  });

  EditorLoaded copyWith({
    DocumentEntity? document,
    FieldType? selectedFieldType,
    bool clearSelection = false,
  }) {
    return EditorLoaded(
      document: document ?? this.document,
      selectedFieldType: clearSelection ? null : (selectedFieldType ?? this.selectedFieldType),
    );
  }

  @override
  List<Object?> get props => [document, selectedFieldType];
}

class EditorFieldsExported extends EditorState {
  final String jsonData;

  const EditorFieldsExported(this.jsonData);

  @override
  List<Object?> get props => [jsonData];
}

class EditorFieldsImported extends EditorState {
  final List<FieldEntity> fields;

  const EditorFieldsImported(this.fields);

  @override
  List<Object?> get props => [fields];
}

class EditorPublished extends EditorState {
  final DocumentEntity document;

  const EditorPublished(this.document);

  @override
  List<Object?> get props => [document];
}

class EditorError extends EditorState {
  final String message;

  const EditorError(this.message);

  @override
  List<Object?> get props => [message];
}