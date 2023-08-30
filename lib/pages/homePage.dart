import 'package:flutter/material.dart';
import 'package:ToDO/taskManager.dart';
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _taskManager = TaskManager(); // Initialize your task manager

  @override
  void initState() {
    super.initState();
    _taskManager.refreshItems();
    // Set up the callback to trigger a rebuild when a task is added
    _taskManager.onTaskAdded = () {
      setState(() {});
    };
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text("Task", style: TextStyle(color: Colors.black, fontSize: 30)),
      ),
      body: _taskManager.buildTaskList(context), // Use your task manager to build the task list
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => _taskManager.showForm(context, null),
        child: Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
