import 'package:e_signature/core/utils/file_helper.dart';
import 'package:e_signature/core/widgets/custom_button.dart';
import 'package:e_signature/core/widgets/loading_widget.dart';
import 'package:e_signature/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:e_signature/features/authentication/presentation/cubit/auth_state.dart';
import 'package:e_signature/features/document/presentation/cubit/document_cubit.dart';
import 'package:e_signature/features/document/presentation/cubit/document_state.dart';
import 'package:e_signature/features/document/presentation/pages/docoment_editor_page.dart';
import 'package:e_signature/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadDocumentPage extends StatelessWidget {
  const UploadDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: BlocProvider(
        create: (_) => sl<DocumentCubit>(),
        child: const UploadDocumentView(),
      ),
    );
  }
}

class UploadDocumentView extends StatelessWidget {
  const UploadDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is DocumentUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DocumentEditorPage(documentId: state.document.id),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const LoadingWidget(message: 'Uploading document...');
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Upload your document',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported formats: PDF, DOCX',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Choose File',
                  onPressed: () => _pickDocument(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final file = await FileHelper.pickDocument();
      if (file != null) {
        final userId = (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
        context.read<DocumentCubit>().uploadDocument(file.path, userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}