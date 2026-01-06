// ==================== DOCUMENT EDITOR PAGE ====================

// lib/features/document/presentation/pages/document_editor_page.dart
import 'package:e_signature/core/widgets/error_widget.dart';
import 'package:e_signature/core/widgets/loading_widget.dart';
import 'package:e_signature/features/document/domain/entities/document_entity.dart';
import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_cubit.dart';
import 'package:e_signature/features/document/presentation/cubit/editor_state.dart';
import 'package:e_signature/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentEditorPage extends StatelessWidget {
  final String documentId;

  const DocumentEditorPage({
    super.key,
    required this.documentId,
  });

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
  final TransformationController _transformationController = TransformationController();
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
           /* Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SigningPage(documentId: state.document.id),
              ),
            );*/
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
                final documentId = (context.read<EditorCubit>().state as EditorError);
                // Retry logic here
              },
            );
          }

          if (state is EditorLoaded) {
            return Column(
              children: [
                // Field Palette
                if (_showFieldPalette)
                  FieldPalette(
                    selectedType: state.selectedFieldType,
                    onFieldTypeSelected: (type) {
                      context.read<EditorCubit>().selectFieldType(type);
                    },
                  ),

                // Document Viewer with Fields
                Expanded(
                  child: Stack(
                    children: [
                      // PDF Viewer
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

                      // Draggable Fields Overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: state.selectedFieldType != null,
                          child: FieldsOverlay(
                            fields: state.document.fields,
                            onFieldMoved: (field, position) {
                              context.read<EditorCubit>().updateField(
                                field.copyWith(
                                  x: position.dx,
                                  y: position.dy,
                                ),
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

                // Bottom Action Bar
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
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
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
              // Copy to clipboard
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
        content: Text('Found ${fields.length} fields. Add them to the document?'),
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

// ==================== FIELD PALETTE WIDGET ====================

// lib/features/document/presentation/widgets/field_palette.dart
class FieldPalette extends StatelessWidget {
  final FieldType? selectedType;
  final Function(FieldType) onFieldTypeSelected;

  const FieldPalette({
    super.key,
    required this.selectedType,
    required this.onFieldTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.touch_app, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select a field type and tap on the document to place it',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FieldTypeButton(
                  type: FieldType.signature,
                  icon: Icons.draw,
                  label: 'Signature',
                  isSelected: selectedType == FieldType.signature,
                  onTap: () => onFieldTypeSelected(FieldType.signature),
                ),
                const SizedBox(width: 8),
                FieldTypeButton(
                  type: FieldType.textbox,
                  icon: Icons.text_fields,
                  label: 'Text',
                  isSelected: selectedType == FieldType.textbox,
                  onTap: () => onFieldTypeSelected(FieldType.textbox),
                ),
                const SizedBox(width: 8),
                FieldTypeButton(
                  type: FieldType.checkbox,
                  icon: Icons.check_box,
                  label: 'Checkbox',
                  isSelected: selectedType == FieldType.checkbox,
                  onTap: () => onFieldTypeSelected(FieldType.checkbox),
                ),
                const SizedBox(width: 8),
                FieldTypeButton(
                  type: FieldType.date,
                  icon: Icons.calendar_today,
                  label: 'Date',
                  isSelected: selectedType == FieldType.date,
                  onTap: () => onFieldTypeSelected(FieldType.date),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldTypeButton extends StatelessWidget {
  final FieldType type;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FieldTypeButton({
    super.key,
    required this.type,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DOCUMENT VIEWER WIDGET ====================

// lib/features/document/presentation/widgets/document_viewer.dart
class DocumentViewer extends StatelessWidget {
  final DocumentEntity document;
  final PdfViewerController pdfController;
  final TransformationController transformationController;
  final Function(Offset) onTap;

  const DocumentViewer({
    super.key,
    required this.document,
    required this.pdfController,
    required this.transformationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        onTap(localPosition);
      },
      child: Container(
        color: Colors.grey[300],
        child: document.filePath.startsWith('http')
            ? SfPdfViewer.network(
          document.filePath,
          controller: pdfController,
          canShowScrollHead: false,
          enableDoubleTapZooming: true,
        )
            : SfPdfViewer.file(
          File(document.filePath),
          controller: pdfController,
          canShowScrollHead: false,
          enableDoubleTapZooming: true,
        ),
      ),
    );
  }
}

// ==================== FIELDS OVERLAY WIDGET ====================

// lib/features/document/presentation/widgets/fields_overlay.dart
class FieldsOverlay extends StatelessWidget {
  final List<FieldEntity> fields;
  final Function(FieldEntity, Offset) onFieldMoved;
  final Function(FieldEntity) onFieldDeleted;

  const FieldsOverlay({
    super.key,
    required this.fields,
    required this.onFieldMoved,
    required this.onFieldDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: fields.map((field) {
        return DraggableFieldWidget(
          field: field,
          onMoved: (position) => onFieldMoved(field, position),
          onDeleted: () => onFieldDeleted(field),
        );
      }).toList(),
    );
  }
}

// ==================== DRAGGABLE FIELD WIDGET ====================

// lib/features/document/presentation/widgets/draggable_field.dart
class DraggableFieldWidget extends StatefulWidget {
  final FieldEntity field;
  final Function(Offset) onMoved;
  final VoidCallback onDeleted;

  const DraggableFieldWidget({
    super.key,
    required this.field,
    required this.onMoved,
    required this.onDeleted,
  });

  @override
  State<DraggableFieldWidget> createState() => _DraggableFieldWidgetState();
}

class _DraggableFieldWidgetState extends State<DraggableFieldWidget> {
  Offset _position = Offset.zero;
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.field.x, widget.field.y);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              _position.dx + details.delta.dx,
              _position.dy + details.delta.dy,
            );
          });
        },
        onPanEnd: (details) {
          widget.onMoved(_position);
        },
        onLongPress: () {
          setState(() {
            _showMenu = !_showMenu;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.field.width,
              height: widget.field.height,
              decoration: BoxDecoration(
                color: _getFieldColor().withOpacity(0.3),
                border: Border.all(
                  color: _getFieldColor(),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getFieldIcon(),
                      color: _getFieldColor(),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFieldLabel(),
                      style: TextStyle(
                        color: _getFieldColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showMenu)
              Positioned(
                right: -40,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: 20,
                        onPressed: () {
                          widget.onDeleted();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        onPressed: () {
                          setState(() {
                            _showMenu = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getFieldColor() {
    switch (widget.field.type) {
      case FieldType.signature:
        return Colors.blue;
      case FieldType.textbox:
        return Colors.green;
      case FieldType.checkbox:
        return Colors.orange;
      case FieldType.date:
        return Colors.purple;
    }
  }

  IconData _getFieldIcon() {
    switch (widget.field.type) {
      case FieldType.signature:
        return Icons.draw;
      case FieldType.textbox:
        return Icons.text_fields;
      case FieldType.checkbox:
        return Icons.check_box;
      case FieldType.date:
        return Icons.calendar_today;
    }
  }

  String _getFieldLabel() {
    switch (widget.field.type) {
      case FieldType.signature:
        return 'Sign';
      case FieldType.textbox:
        return 'Text';
      case FieldType.checkbox:
        return 'Check';
      case FieldType.date:
        return 'Date';
    }
  }
}

// ==================== BOTTOM ACTION BAR ====================

// lib/features/document/presentation/widgets/bottom_action_bar.dart
class BottomActionBar extends StatelessWidget {
  final DocumentEntity document;
  final VoidCallback onPublish;

  const BottomActionBar({
    super.key,
    required this.document,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${document.fields.length} fields added',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: document.fields.isEmpty ? null : onPublish,
            icon: const Icon(Icons.publish),
            label: const Text('Publish'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}