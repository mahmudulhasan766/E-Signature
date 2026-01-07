import 'package:e_signature/features/authentication/presentation/cubit/signing_state.dart';
import 'package:e_signature/features/document/domain/usecases/generate_pdf_usecase.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SigningCubit extends Cubit<SigningState> {
  final GetDocumentUseCase getDocumentUseCase;
  final GeneratePdfUseCase generatePdfUseCase;

  SigningCubit({
    required this.getDocumentUseCase,
    required this.generatePdfUseCase,
  }) : super(SigningInitial());

  Future<void> loadDocument(String documentId) async {
    emit(SigningLoading());
    final result = await getDocumentUseCase(GetDocumentParams(documentId: documentId));

    result.fold(
          (failure) => emit(SigningError(failure.message)),
          (document) => emit(SigningInProgress(
        document: document,
        fieldValues: {},
      )),
    );
  }

  void updateFieldValue(String fieldId, String value) {
    final currentState = state;
    if (currentState is! SigningInProgress) return;

    final updatedValues = Map<String, String>.from(currentState.fieldValues);
    updatedValues[fieldId] = value;

    emit(currentState.copyWith(fieldValues: updatedValues));
  }

  Future<void> completeSigning() async {
/*    final currentState = state;
    if (currentState is! SigningInProgress) return;

    // Validate all required fields are filled
    final unfilledFields = currentState.document.fields
        .where((field) => !currentState.fieldValues.containsKey(field?.id))
        .toList();

    if (unfilledFields.isNotEmpty) {
      emit(const SigningError('Please fill all required fields'));
      return;
    }

    emit(SigningLoading());

    // Update document with field values
    final updatedFields = currentState.document.fields.map((field) {
      return field?.copyWith(value: currentState.fieldValues[field.id]);
    }).toList();

    final updatedDocument = currentState.document.copyWith(fields: updatedFields);

    final result = await generatePdfUseCase(GeneratePdfParams(
      document: updatedDocument,
    ));

    result.fold(
          (failure) => emit(SigningError(failure.message)),
          (pdfPath) => emit(SigningCompleted(pdfPath)),
    );*/
  }
}