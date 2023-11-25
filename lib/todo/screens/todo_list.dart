import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_crud/todo/controllers/todo_controller.dart';
import 'package:intl/intl.dart';

import '../model/task.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoController _todoController = Get.put(TodoController());
  late Box todoBox;
  @override
  void initState() {
    super.initState();
    todoBox = Hive.box('todo__box');
    _todoController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: GetBuilder<TodoController>(builder: (controller) {
        return controller.todoList.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
                child: ListView.builder(
                  itemCount: controller.todoList.length,
                  itemBuilder: (context, index) {
                    Task task = controller.todoBox.getAt(index);
                    String title = "";
                    Color color = Colors.red;
                    switch (task.priority) {
                      case 1:
                        title = "High";
                        color = Colors.red;
                        break;
                      case 2:
                        title = "Medium";
                        color = Colors.blue;
                      default:
                        title = "Low";
                        color = Colors.green;
                    }
                    DateTime date = DateTime.parse(task.date);

                    return Card(
                      child: ListTile(
                          title: Text(
                            task.name,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text(
                                  'Date: ${DateFormat('dd MMM yyyy').format(date)}'),
                              Row(
                                children: [
                                  Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (value) {
                                      setState(() {
                                        task.isCompleted = value!;
                                      });
                                      controller.editTask(index, task);
                                    },
                                  ),
                                  const Text("Mark as Completed"),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 4),
                                  child: Text(
                                    title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _editTask(context, index, task.name,
                                        task.date, task.priority);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    _deleteTask(index);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ))
                            ],
                          )),
                    );
                  },
                ),
              )
            : const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You haven't added any task !",
                      style: TextStyle(fontSize: 40),
                    ),
                    Divider(),
                    Text("Click on the Add Task button to add a task "),
                  ],
                )),
              );
      }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: "addTask",
            onPressed: () {
              _addTask(context);
            },
            label: const Row(
              children: [
                Text(
                  "Add Task",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.add)
              ],
            ),
            backgroundColor: Colors.blue,
          ),
          const SizedBox(
            width: 30,
          ),
          FloatingActionButton.extended(
            heroTag: "filters",
            onPressed: () {
              _filterTasks(context);
            },
            label: const Row(
              children: [
                Text(
                  "Filter Tasks",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.sort)
              ],
            ),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

// ADDING TASK
  void _addTask(BuildContext context) {
    TextEditingController taskNameController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int priority = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a New Task'),
              content: Column(
                children: [
                  TextField(
                    controller: taskNameController,
                    decoration: const InputDecoration(labelText: 'Task Name'),
                  ),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          dateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Date'),
                  ),
                  Row(
                    children: [
                      const Text("High"),
                      Radio(
                        value: 1,
                        groupValue: priority,
                        onChanged: (value) {
                          setState(() {
                            priority = value as int;
                          });
                        },
                      ),
                      const Text("Medium"),
                      Radio(
                        value: 2,
                        groupValue: priority,
                        onChanged: (value) {
                          setState(() {
                            priority = value as int;
                          });
                        },
                      ),
                      const Text("Low"),
                      Radio(
                        value: 3,
                        groupValue: priority,
                        onChanged: (value) {
                          setState(() {
                            priority = value as int;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Task task = Task(
                      name: taskNameController.text,
                      date: dateController.text,
                      priority: priority,
                    );
                    _todoController.addTask(task);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task added successfully"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // EDITITNG THE TASK
  void _editTask(BuildContext context, index, taskName, date, taskPriority) {
    TextEditingController taskNameController =
        TextEditingController(text: taskName);
    TextEditingController dateController = TextEditingController(text: date);
    DateTime selectedDate = DateTime.parse(date ?? '');
    int priority = taskPriority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a New Task'),
              content: Column(
                children: [
                  TextField(
                    controller: taskNameController,
                    decoration: const InputDecoration(labelText: 'Task Name'),
                  ),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          dateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Date'),
                  ),
                  Row(
                    children: [
                      const Text("High"),
                      Radio(
                        value: 1,
                        groupValue: priority,
                        onChanged: (value) {
                          setState(() {
                            priority = value as int;
                          });
                        },
                      ),
                      const Text("Medium"),
                      Radio(
                        value: 2,
                        groupValue: priority,
                        onChanged: (value) {
                          setState(() {
                            priority = value as int;
                          });
                        },
                      ),
                      const Text("Low"),
                      Radio(
                        value: 3,
                        groupValue: priority,
                        onChanged: (value) {
                          setState(() {
                            priority = value as int;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Task task = Task(
                      name: taskNameController.text,
                      date: dateController.text,
                      priority: priority,
                    );
                    _todoController.editTask(index, task);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task updated successfully"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Update Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DELETING THE TASK
  void _deleteTask(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a New Task'),
              content: const Text("Are you really want to delete the task ?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _todoController.deleteTask(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task deleted successfully"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Tasks'),
              content: Column(
                children: [
                  CustomButton(
                      title: "Sort By High to Low",
                      onTap: () {
                        _todoController.filterHighToLow();
                        Navigator.pop(context);
                      },
                      icon: Icons.sort,
                      backgroundColor: Colors.red),
                  const Divider(),
                  CustomButton(
                      title: "Sort By Low to High",
                      onTap: () {
                        _todoController.filterLowToHigh();
                        Navigator.pop(context);
                      },
                      icon: Icons.sort,
                      backgroundColor: Colors.blue),
                  const Divider(),
                  CustomButton(
                      title: "Clear Filters",
                      onTap: () {},
                      icon: Icons.sort,
                      backgroundColor: Colors.blue),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close Filters"))
              ],
            );
          },
        );
      },
    );
  }
}

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
    required this.backgroundColor,
  });
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final Color backgroundColor;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: widget.backgroundColor,
      onPressed: widget.onTap,
      label: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            width: 10,
          ),
          const Icon(Icons.sort)
        ],
      ),
    );
  }
}
