import 'package:ToDO/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //if main function has any asynchronous task, then we need to ensure that all the widgets are binded properly before the app starts
  await Hive.initFlutter();
  await Hive.openBox("todo");
  //creates the database named "todo"
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
