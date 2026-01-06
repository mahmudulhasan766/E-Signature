
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SigningState extends Equatable {
  const SigningState();

  @override
  List<Object?> get props => [];
}

class SigningInitial extends SigningState {}

class SigningLoading extends SigningState {}

class SigningInProgress extends SigningState {
  final DocumentEntity document;
  final Map<String, String> fieldValues;

  const SigningInProgress({
    required this.document,
    required this.fieldValues,
  });

  SigningInProgress copyWith({
    DocumentEntity? document,
    Map<String, String>? fieldValues,
  }) {
    return SigningInProgress(
      document: document ?? this.document,
      fieldValues: fieldValues ?? this.fieldValues,
    );
  }

  @override
  List<Object?> get props => [document, fieldValues];
}

class SigningCompleted extends SigningState {
  final String pdfPath;

  const SigningCompleted(this.pdfPath);

  @override
  List<Object?> get props => [pdfPath];
}

class SigningError extends SigningState {
  final String message;

  const SigningError(this.message);

  @override
  List<Object?> get props => [message];
}