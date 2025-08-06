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

  String _getQuadrantShortName(int index) {
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

  void _handleSubmit() {
    final taskName = widget.controller.text.trim();
    if (taskName.isNotEmpty) {
      widget.controller.clear();
      Navigator.of(context).pop();
      if (widget.isEditing) {
        widget.onUpdate?.call(taskName, selectedQuadrant);
      } else {
        widget.onAdd(taskName);
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on a small screen
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      // Make dialog more compact on small screens
      contentPadding: EdgeInsets.fromLTRB(
        24.0,
        20.0,
        24.0,
        isSmallScreen ? 16.0 : 24.0,
      ),
      title: Center(
        child: Text(
          widget.isEditing ? 'Edit Task' : 'Add a Task',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter task name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              controller: widget.controller,
              maxLines: isSmallScreen ? 1 : 2,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  if (widget.isEditing) {
                    widget.onUpdate?.call(value.trim(), selectedQuadrant);
                  } else {
                    widget.onAdd(value.trim());
                  }
                  widget.controller.clear();
                  Navigator.of(context).pop();
                }
              },
            ),

            if (widget.isEditing) ...[
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Move to Quadrant:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),

              // Use dropdown for small screens, radio buttons for large screens
              if (isSmallScreen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedQuadrant,
                      items: List.generate(4, (index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            _getQuadrantShortName(index),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedQuadrant = value;
                          });
                        }
                      },
                    ),
                  ),
                )
              else
                // Radio buttons for larger screens
                Column(
                  children: List.generate(4, (index) {
                    return RadioListTile<int>(
                      dense: true,
                      title: Text(_getQuadrantShortName(index)),
                      value: index,
                      groupValue: selectedQuadrant,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedQuadrant = value;
                          });
                        }
                      },
                    );
                  }),
                ),
            ],

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Buttons - Always horizontal
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                    ),
                    child: Text(
                      widget.isEditing ? 'Update Task' : 'Add Task',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleCancel,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
