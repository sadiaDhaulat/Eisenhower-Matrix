import 'package:flutter/material.dart';

class CustomAlertDialog extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final Function(String taskName) onAdd;

  // ADD THESE NEW OPTIONAL PARAMETERS for editing
  // These parameters will be used to handle task editing
  final bool isEditing; // To know if we're editing
  final Function(String, int)? onUpdate; // Update callback with quadrant
  final int? currentQuadrant; // Current quadrant for editing

  const CustomAlertDialog({
    super.key,
    required this.controller,
    required this.title,
    required this.onAdd,
    this.isEditing = false, // Default to false
    this.onUpdate, // Optional update callback
    this.currentQuadrant, // Optional current quadrant
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  late int selectedQuadrant;

  @override
  void initState() {
    super.initState();
    selectedQuadrant = widget.currentQuadrant ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Add a Task', textAlign: TextAlign.center),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter task name'),
            controller: widget.controller,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                if (widget.isEditing) {
                  widget.onUpdate?.call(value, selectedQuadrant);
                } else {
                  widget.onAdd(value);
                }
                widget.controller.clear();
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 15),

          if (widget.isEditing) ...[
            const Text(
              'MOve to Quadrant:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (index) {
              return RadioListTile<int>(
                dense: true,
                title: Text(_getQuadrantName(index)),
                value: index,
                groupValue: selectedQuadrant,
                onChanged: (value) {
                  setState(() {
                    selectedQuadrant = value!;
                  });
                },
              );
            }),
          ],
          Row(
            children: [
              // Add Task button to add the task
              ElevatedButton(
                onPressed: () {
                  if (widget.controller.text.isNotEmpty) {
                    if (widget.isEditing) {
                      widget.onUpdate?.call(
                        widget.controller.text,
                        selectedQuadrant,
                      );
                    } else {
                      widget.onAdd(widget.controller.text);
                    }
                  }
                  widget.controller.clear();
                  Navigator.of(context).pop();
                },
                child: Text(
                  widget.isEditing ? 'Update Task' : 'Add Task',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 15),
              // Cancel button to close the dialog
              ElevatedButton(
                onPressed: () {
                  widget.controller.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQuadrantName(int index) {
    switch (index) {
      case 0:
        return 'Quadrant 1';
      case 1:
        return 'Quadrant 2';
      case 2:
        return 'Quadrant 3';
      case 3:
        return 'Quadrant 4';
      default:
        return 'Unknown Quadrant';
    }
  }
}
