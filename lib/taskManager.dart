import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

typedef TaskAddedCallback = void Function();
class TaskManager {
  //below are the editable text fields
  final TextEditingController _task = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  List<Map<String, dynamic>> _tasks = [];
  //this list will contain the data during running the app
  final _todoList = Hive.box("todo");
  //here we will open the existing database called "todo"

  void refreshItems() {
    // it is an important function to refresh the tasks after adding, update, and delete
    final data = _todoList.keys.map((key) {
      // here data is a list of all the tasks. _todoList.keys.map() works like a loop. it iterates over all the tasks with every existing keys, and returns the matched items. 
      final task = _todoList.get(key);
      // the _todoList.get(key) will return the matched task
      return {"key": key, "task": task["task"], "desc": task["desc"]};
      // then the function will return the task as a map then converted to a list
    }).toList();

    _tasks = data.reversed.toList();
    // revered so that the last task to be added appear first
  }

  TaskAddedCallback? onTaskAdded;
  // a void function onTaskAdded created which can also be assigned to null

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

  Future<void> _deleteTask(int taskKey, BuildContext context) async {
    await _todoList.delete(taskKey);
    refreshItems();
    onTaskAdded?.call();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task deleted", textAlign: TextAlign.center,)));
  }

  void showForm(BuildContext ctx, int? taskKey) async {
    _task.text = "";
    _desc.text = "";
    //by default the editable text field will be empty
    if (taskKey != null) {
      // but if I call this function by clicking edit button, it will take the existing text
      final existingTask = _tasks.firstWhere((element) => element['key'] == taskKey);
      _task.text = existingTask['task'];
      _desc.text = existingTask['desc'];
    }
    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          //this is used so that the bottomsheet goes up when the keyboard is enabled
          left: 15,
          right: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // it makes the column take the minimum necessary height 
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
                  taskKey==null? _addTask({"task" : _task.text, "desc": _desc.text}) : _updateTask(taskKey, {"task": _task.text, "desc": _desc.text},);
                  //  if we press the add button then it is a new task and the taskKey is null, so we will call the addTask. and if we press the edit button then the taskkey has a value, so we will call the updateTask. 
                  _task.text = "";
                  _desc.text = "";
                  //  after adding or updating the task, we will clear the textField
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
                      _deleteTask(currentTask['key'], context);
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
