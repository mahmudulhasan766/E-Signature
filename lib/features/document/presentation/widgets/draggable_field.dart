import 'package:e_signature/features/document/domain/entities/field_entity.dart';
import 'package:flutter/material.dart';

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
                border: Border.all(color: _getFieldColor(), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getFieldIcon(), color: _getFieldColor(), size: 16),
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
