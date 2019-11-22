import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
    // items.add(Item(title: "Estrutura de dados", done: false));
    // items.add(Item(title: "Sistemas operacionais", done: false));
    // items.add(Item(title: "Banco de dados", done: false));
    // items.add(Item(title: "RPA", done: true));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textController = TextEditingController();
 
  _HomePageState() {
    loadTasks();
  }
  void _showDialog(var item) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Deseja realmente excluir este item?"),
          content: new Text(widget.items[item].title),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Sim"),
              onPressed: () {
                removeTask(item);
                save();
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Não"),
              onPressed: () {
               
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addTask() {
    if (textController.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: textController.text, done: false));
      textController.text = "";
    });
    save();
  }

  void removeTask(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
  }

  Future loadTasks() async {
    var pref = await SharedPreferences.getInstance();
    var data = pref.getString("data");
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString("data", jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: textController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.9),
            ),
            onDismissed: (direction) {
              // DismissDirection.startToEnd
             _showDialog(index);
             
              //removeTask(index);
              //save();
              //print(direction);
            },
            confirmDismiss: (teste){
              print(teste);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTask();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
