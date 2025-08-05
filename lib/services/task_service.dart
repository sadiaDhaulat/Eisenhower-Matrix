import 'package:eishen_matrix/task.dart';
import 'package:hive/hive.dart';

class TaskService {
  static const String _boxName = 'tasks';

  //get the Hive box for tasks
  Box<Task> get _box => Hive.box<Task>(_boxName);

  //get all taks
  List<Task> getAllTasks() {
    return _box.values.toList();
  }

  //add a task
  Future<void> addTask(Task task) async {
    await _box.add(task);
  }

  //update a task
  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await task.save();
  }

  //delete a task
  Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  //get task by quadrant
  List<Task> getTasksByQuadrant(Quadrant quadrant) {
    return _box.values.where((task) => task.quadrantEnum == quadrant).toList();
  }

  List<Task> getTasksByQuadrantAndDate(Quadrant quadrant, DateTime date) {
    return _box.values
        .where(
          (task) =>
              task.quadrantEnum == quadrant && _isSameDay(task.date, date),
        )
        .toList();
  }

  // Get tasks for a specific date (all quadrants)
  List<Task> getTasksByDate(DateTime date) {
    return _box.values.where((task) => _isSameDay(task.date, date)).toList();
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Initialize the Hive box
  static Future<void> init() async {
    await Hive.openBox<Task>(_boxName);
  }

  // Close the box when app is disposed
  static Future<void> dispose() async {
    await Hive.box<Task>(_boxName).close();
  }
}
