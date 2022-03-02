import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remover o banner de debug
      title: 'Flutter Demo', // Nome do icone
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  List<Item> items = [];

  HomePage() {
    items = [];
    // items.add(Item(title: 'Item 1', done: false));
    // items.add(Item(title: 'Item 2', done: true));
    // items.add(Item(title: 'Item 3', done: false));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTextController = TextEditingController(); // captura os dados do input

  void add() {
    if (newTextController.text.isEmpty) return; // verifica se está vazio.
    setState(() {
      widget.items.add(
        Item(
          title: newTextController.text,
          done: false,
        ),
      );
      newTextController.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
    save();
  }

  Future load() async {
    var pref = await SharedPreferences.getInstance();
    var data = pref.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          // Campo para input de dados
          controller:
              newTextController, // informa ao TextFormField quem controla
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
              labelText: "Nova tarefa",
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final items = widget.items[index];
          return Dismissible(
            key: Key(items.title!),
            background: Container(
              color: Colors.red,
              child: const Center(
                child: Text(
                  "Excluir",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            child: Container(
              height: 50,
              color: Colors.amber[index * 100],
              child: CheckboxListTile(
                title: Text(items.title!),
                value: items.done,
                onChanged: (value) {
                  setState(() {
                    items.done = value;
                    save();
                  });
                },
              ),
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
