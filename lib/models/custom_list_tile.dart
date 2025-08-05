import 'package:eishen_matrix/task.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Task task;
  final Function()? onTap;

  const CustomListTile({
    required this.task,
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
      ),
      title: Text(task.name,
      style: TextStyle(decoration: task.isCompleted? TextDecoration.lineThrough: TextDecoration.none)),
      onTap: onTap,
    );
  }
}