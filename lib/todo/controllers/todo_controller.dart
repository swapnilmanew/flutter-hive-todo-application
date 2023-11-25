import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../model/task.dart';

class TodoController extends GetxController {
  late Box todoBox;
  List todoList = [];

  @override
  void onInit() {
    super.onInit();
    todoBox = Hive.box('todo__box');
  }

  // GETTING ALL THE TASKS
  void getTasks() async {
    todoList.addAll(todoBox.values);
    update();
  }

// ADDING A NEW TASK
  void addTask(Task task) {
    todoBox.add(task);
    todoList.add(task);
    update();
  }

  // UPDATING THE TASK STATUS
  void updateIsCompleted(int index, Task task) {
    todoBox.putAt(index, task);
    update();
  }

  // EDITING AN EXISTING TASK
  void editTask(int index, Task task) {
    todoBox.putAt(index, task);
    update();
  }

  // DELETING A TASK
  void deleteTask(int index) {
    todoBox.deleteAt(index);
    todoList.removeAt(index);
    update();
  }

  // FILTER TASKS FROM LOW TO HIGH PRIORITY
  void filterLowToHigh() {
    todoList.clear();
    todoList.addAll(todoBox.values.toList()
      ..sort((a, b) {
        return (a as Task).priority.compareTo((b as Task).priority);
      }));
    update();
  }

// FILTER TASKS FROM HIGH TO LOW PRIORITY
  void filterHighToLow() {
    todoList.clear();
    todoList.addAll(todoBox.values.toList()
      ..sort((a, b) {
        return (b as Task).priority.compareTo((a as Task).priority);
      }));
    update();
  }
}
