import 'package:e_signature/core/widgets/error_widget.dart';
import 'package:e_signature/core/widgets/loading_widget.dart';
import 'package:e_signature/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:e_signature/features/authentication/presentation/cubit/auth_state.dart';
import 'package:e_signature/features/authentication/presentation/pages/login_page.dart';
import 'package:e_signature/features/document/presentation/cubit/document_cubit.dart';
import 'package:e_signature/features/document/presentation/cubit/document_state.dart';
import 'package:e_signature/features/document/presentation/pages/docoment_editor_page.dart';
import 'package:e_signature/features/document/presentation/pages/signing_page.dart';
import 'package:e_signature/features/document/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../document/domain/entities/document_entity.dart';

class DocumentListView extends StatelessWidget {
  const DocumentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const LoadingWidget(message: 'Loading documents...');
        }

        if (state is DocumentError) {
          return ErrorDisplayWidget(
            message: state.message,
            onRetry: () {
              final userId = (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
              context.read<DocumentCubit>().getDocuments(userId);
            },
          );
        }

        if (state is DocumentsLoaded) {
          if (state.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No documents yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your first document to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
              context.read<DocumentCubit>().getDocuments(userId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.documents.length,
              itemBuilder: (context, index) {
                return DocumentCard(
                  document: state.documents[index],
                  onTap: () => _navigateToEditor(context, state.documents[index]),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToEditor(BuildContext context, DocumentEntity document) {
    if (document.isPublished) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SigningPage(documentId: document.id),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocumentEditorPage(documentId: document.id),
        ),
      );
    }
  }
}
