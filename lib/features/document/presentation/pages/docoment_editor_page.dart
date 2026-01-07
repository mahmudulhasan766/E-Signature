import 'package:e_signature/core/widgets/error_widget.dart';
import 'package:e_signature/core/widgets/loading_widget.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_cubit.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_state.dart';
import 'package:e_signature/features/document/presentation/pages/signing_page.dart';
import 'package:e_signature/features/document/presentation/widgets/bottom_action_bar.dart';
import 'package:e_signature/features/document/presentation/widgets/document_viewer.dart';
import 'package:e_signature/features/document/presentation/widgets/field_palette.dart';
import 'package:e_signature/features/document/presentation/widgets/fields_overlay.dart';
import 'package:e_signature/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentEditorPage extends StatelessWidget {
  final String documentId;

  const DocumentEditorPage({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditorCubit>()..loadDocument(documentId),
      child: const DocumentEditorView(),
    );
  }
}

class DocumentEditorView extends StatefulWidget {
  const DocumentEditorView({super.key});

  @override
  State<DocumentEditorView> createState() => _DocumentEditorViewState();
}

class _DocumentEditorViewState extends State<DocumentEditorView> {
  final PdfViewerController _pdfController = PdfViewerController();
  final TransformationController _transformationController =
      TransformationController();
  bool _showFieldPalette = true;

  @override
  void dispose() {
    _pdfController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Toggle Fields',
            onPressed: () {
              setState(() {
                _showFieldPalette = !_showFieldPalette;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Fields'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Import Fields'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All Fields'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<EditorCubit, EditorState>(
        listener: (context, state) {
          if (state is EditorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is EditorFieldsExported) {
            _showExportDialog(context, state.jsonData);
          } else if (state is EditorFieldsImported) {
            _showImportConfirmation(context, state.fields);
          } else if (state is EditorPublished) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document published successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SigningPage(documentId: state.document.id),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EditorLoading) {
            return const LoadingWidget(message: 'Loading document...');
          }

          if (state is EditorError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                final documentId =
                    (context.read<EditorCubit>().state as EditorError);
              },
            );
          }

          if (state is EditorLoaded) {
            return Column(
              children: [
                if (_showFieldPalette)
                  FieldPalette(
                    selectedType: state.selectedFieldType,
                    onFieldTypeSelected: (type) {
                      context.read<EditorCubit>().selectFieldType(type);
                    },
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      DocumentViewer(
                        document: state.document,
                        pdfController: _pdfController,
                        transformationController: _transformationController,
                        onTap: (position) {
                          if (state.selectedFieldType != null) {
                            context.read<EditorCubit>().addField(
                              position.dx,
                              position.dy,
                              _pdfController.pageNumber,
                            );
                          }
                        },
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: state.selectedFieldType != null,
                          child: FieldsOverlay(
                            fields: state.document.fields,
                            onFieldMoved: (field, position) {
                              context.read<EditorCubit>().updateField(
                                field.copyWith(x: position.dx, y: position.dy),
                              );
                            },
                            onFieldDeleted: (field) {
                              context.read<EditorCubit>().deleteField(field.id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BottomActionBar(
                  document: state.document,
                  onPublish: () => _showPublishDialog(context),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        context.read<EditorCubit>().exportFields();
        break;
      case 'import':
        _showImportDialog(context);
        break;
      case 'clear':
        _showClearDialog(context);
        break;
    }
  }

  void _showExportDialog(BuildContext context, String jsonData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Fields'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Copy the JSON configuration:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  jsonData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Fields'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Paste JSON configuration here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final jsonString = controller.text.trim();
              if (jsonString.isNotEmpty) {
                context.read<EditorCubit>().importFields(jsonString);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showImportConfirmation(BuildContext context, List<FieldEntity> fields) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Successful'),
        content: Text(
          'Found ${fields.length} fields. Add them to the document?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EditorCubit>().applyImportedFields(fields);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fields imported successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Fields'),
        content: const Text('Are you sure you want to remove all fields?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final state = context.read<EditorCubit>().state;
              if (state is EditorLoaded) {
                for (var field in state.document.fields) {
                  context.read<EditorCubit>().deleteField(field.id);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Document'),
        content: const Text(
          'Once published, you won\'t be able to edit the field positions. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EditorCubit>().publishDocument();
              Navigator.pop(ctx);
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }
}
