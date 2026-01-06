import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../authentication/presentation/cubit/signing_cubit.dart';
import '../../../authentication/presentation/cubit/signing_state.dart';
import '../../domain/entities/document_entity.dart';
import '../widgets/signing_field_input.dart';
import '../widgets/signing_fields_overlay.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../injection_container.dart';


class SigningPage extends StatelessWidget {
  final String documentId;

  const SigningPage({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SigningCubit>()..loadDocument(documentId),
      child: const SigningView(),
    );
  }
}

class SigningView extends StatefulWidget {
  const SigningView({super.key});

  @override
  State<SigningView> createState() => _SigningViewState();
}

class _SigningViewState extends State<SigningView> {
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentFieldIndex = 0;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Document'),
        actions: [
          BlocBuilder<SigningCubit, SigningState>(
            builder: (context, state) {
              if (state is SigningInProgress) {
                final totalFields = state.document.fields.length;
                final filledFields = state.fieldValues.length;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '$filledFields/$totalFields',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<SigningCubit, SigningState>(
        listener: (context, state) {
          if (state is SigningError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SigningCompleted) {
            _showCompletionDialog(context, state.pdfPath);
          }
        },
        builder: (context, state) {
          if (state is SigningLoading) {
            return const LoadingWidget(message: 'Loading document...');
          }

          if (state is SigningError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                // Retry logic
              },
            );
          }

          if (state is SigningInProgress) {
            return Column(
              children: [
                // Progress Indicator
                LinearProgressIndicator(
                  value: state.fieldValues.length / state.document.fields.length,
                  backgroundColor: Colors.grey[200],
                ),

                // Document Preview with Field Highlights
                Expanded(
                  child: Stack(
                    children: [
                      // PDF Viewer
                      _buildPdfViewer(state.document),

                      // Field Highlights
                      Positioned.fill(
                        child: IgnorePointer(
                          child: SigningFieldsOverlay(
                            fields: state.document.fields,
                            fieldValues: state.fieldValues,
                            currentFieldIndex: _currentFieldIndex,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Field Input Area
                SigningFieldInput(
                  document: state.document,
                  fieldValues: state.fieldValues,
                  currentFieldIndex: _currentFieldIndex,
                  onFieldCompleted: (fieldId, value) {
                    context.read<SigningCubit>().updateFieldValue(fieldId, value);
                    _moveToNextField(state.document.fields.length);
                  },
                  onNavigateField: (index) {
                    setState(() {
                      _currentFieldIndex = index;
                    });
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<SigningCubit, SigningState>(
        builder: (context, state) {
          if (state is SigningInProgress) {
            final allFilled = state.fieldValues.length == state.document.fields.length;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Complete Signing',
                onPressed: (){},
                /*onPressed: allFilled
                    ? () {
                  _showConfirmationDialog(context);
                }
                    : null,*/
                backgroundColor: allFilled ? Colors.green : Colors.grey,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPdfViewer(DocumentEntity document) {
    return Container(
      color: Colors.grey[300],
      child: document.filePath.startsWith('http')
          ? SfPdfViewer.network(
        document.filePath,
        controller: _pdfController,
      )
          : SfPdfViewer.file(
        File(document.filePath),
        controller: _pdfController,
      ),
    );
  }

  void _moveToNextField(int totalFields) {
    if (_currentFieldIndex < totalFields - 1) {
      setState(() {
        _currentFieldIndex++;
      });
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Signing'),
        content: const Text(
          'All fields have been filled. Do you want to generate the final signed PDF?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SigningCubit>().completeSigning();
            },
            child: const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, String pdfPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            const Text('Success!'),
          ],
        ),
        content: const Text(
          'Your document has been signed and saved successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            /*  Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPage(pdfPath: pdfPath),
                ),
              );*/
            },
            child: const Text('View PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// ==================== SIGNING FIELDS OVERLAY WIDGET ====================



// ==================== SIGNING FIELD INPUT WIDGET ====================



// ==================== SIGNATURE FIELD INPUT ====================



// ==================== TEXT FIELD INPUT ====================



// ==================== CHECKBOX FIELD INPUT ====================



// ==================== DATE FIELD INPUT ====================

