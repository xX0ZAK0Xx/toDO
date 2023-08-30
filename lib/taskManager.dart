import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

typedef TaskAddedCallback = void Function();
class TaskManager {
  final TextEditingController _task = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  List<Map<String, dynamic>> _tasks = [];
  final _todoList = Hive.box("todo");

  void refreshItems() {
    final data = _todoList.keys.map((key) {
      final task = _todoList.get(key);
      return {"key": key, "task": task["task"], "desc": task["desc"]};
    }).toList();

    _tasks = data.reversed.toList();
  }

  // Callback function to be set by the widget using TaskManager
  TaskAddedCallback? onTaskAdded;

  Future<void> _addTask(Map<String, dynamic> newItem) async {
    await _todoList.add(newItem);
    refreshItems(); // Update the list of tasks
    onTaskAdded?.call(); // Trigger the callback
  }

  Future<void> _updateTask(int taskKey, Map<String, dynamic> newItem) async {
    await _todoList.put(taskKey, newItem);
    refreshItems();
    onTaskAdded?.call();
  }

  Future<void> _deleteTask(int taskKey) async {
    await _todoList.delete(taskKey);
    refreshItems();
    onTaskAdded?.call();
    // Show SnackBar
  }

  void showForm(BuildContext ctx, int? taskKey) async {
    _task.text = "";
    _desc.text = "";
    if (taskKey != null) {
      final existingTask = _tasks.firstWhere((element) => element['key'] == taskKey);
      _task.text = existingTask['task'];
      _desc.text = existingTask['desc'];
    }
    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        // Build your modal bottom sheet content
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _task,
              decoration: InputDecoration(hintText: "Task"),
            ),
            SizedBox(height: 15,),
            TextField(
              controller: _desc,
              decoration: InputDecoration(hintText: "Description"),
            ),
            SizedBox(height: 15,),
            Container(
              width: double.infinity, // Make button width match screen width
              child: ElevatedButton(
                onPressed: () async {
                  taskKey==null? _addTask({"task" : _task.text, "desc": _desc.text}) : _updateTask(taskKey, {"task": _task.text, "desc": _desc.text});

                  _task.text = "";
                  _desc.text = "";

                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black, // Change button color to black
                ),
                child: Text(taskKey==null?"Add Task" : "Update Task", style: TextStyle(color: Colors.white, fontSize: 25)),
              ),
            ),
            SizedBox(height: 15,),
          ],
        ),
      ),
    );
  }

  Widget buildTaskList(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (_, index) {
          final currentTask = _tasks[index];
          return Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                currentTask["task"] ?? "",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              subtitle: Text(
                currentTask["desc"] ?? "",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: (){
                      showForm(context, currentTask['key']);
                    },
                    icon: Icon(Icons.edit, color: Colors.white,)
                  ),
                  IconButton(
                    onPressed: (){
                      _deleteTask(currentTask['key']);
                    },
                    icon: Icon(Icons.delete, color: Colors.white,)
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
