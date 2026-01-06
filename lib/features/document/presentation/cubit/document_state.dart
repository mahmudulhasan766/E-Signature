import 'package:equatable/equatable.dart';
import '../../domain/entities/document_entity.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentsLoaded extends DocumentState {
  final List<DocumentEntity> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class DocumentUploaded extends DocumentState {
  final DocumentEntity document;

  const DocumentUploaded(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}