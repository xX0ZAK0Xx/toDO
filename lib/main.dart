import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("todo");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _task = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  List<Map<String, dynamic>> _tasks = [];
  final _todoList = Hive.box("todo");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  void _refreshItems(){
    final data = _todoList.keys.map((key){
      final task = _todoList.get(key);
      return {"key": key, "task": task["task"],  "desc": task["desc"]};
    }).toList();

    setState(() {
      _tasks = data.reversed.toList();
    });
  }

  Future <void> _addTask(Map<String, dynamic> newItem) async {
    await _todoList.add(newItem);
    // print("Amount of tasks is ${_todoList.length}");
    _refreshItems();
  }
  Future <void> _updateTask(int taskKey, Map<String, dynamic> newItem) async {
    await _todoList.put(taskKey, newItem);
    // print("Amount of tasks is ${_todoList.length}");
    _refreshItems();
  }
  Future <void> _deleteTask(int taskKey) async {
    await _todoList.delete(taskKey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("The task has been deleted", textAlign: TextAlign.center,))
    );
  }

  void _showForm(BuildContext ctx, int? taskKey)async{
    _task.text = "";
    _desc.text = "";
    if(taskKey != null){
      final existingTask = _tasks.firstWhere((element) => element['key']==taskKey);
      _task.text = existingTask['task'];
      _desc.text = existingTask['desc'];
    }
    showModalBottomSheet(
      context: ctx, 
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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

                  Navigator.of(context).pop();
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
      ) 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text("Task", style: TextStyle(color: Colors.black, fontSize: 30),),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (_, index){  
            final currentTask = _tasks[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: Text(
                  currentTask["key"].toString() ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
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
                        _showForm(context, currentTask['key']);
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
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed:() => _showForm(context, null),
        child: Icon(Icons.add, color: Colors.black, size: 30,),
      ),
    );
  }
}