import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String name;

  @HiveField(1)
  String date;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int priority;

  Task({
    required this.name,
    required this.date,
    this.isCompleted = false,
    required this.priority,
  });
}
