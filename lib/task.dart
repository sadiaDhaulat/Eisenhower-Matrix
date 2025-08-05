import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int quadrant;

  @HiveField(2)
  late bool isCompleted;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  Task({required this.name, required this.quadrant, this.isCompleted = false}) {
    date = DateTime.now();
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  Task.empty();

  void toggleCompletion() {
    isCompleted = !isCompleted;
    updatedAt = DateTime.now();
    save();
  }

  // Helper to convert quadrant int to enum
  Quadrant get quadrantEnum {
    switch (quadrant) {
      case 0:
        return Quadrant.one;
      case 1:
        return Quadrant.two;
      case 2:
        return Quadrant.three;
      case 3:
        return Quadrant.four;
      default:
        return Quadrant.one;
    }
  }
}

enum Quadrant { one, two, three, four }
