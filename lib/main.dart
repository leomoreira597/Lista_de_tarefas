import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoControler = TextEditingController();

  List  _toDoList = [];
  late Map<String, dynamic> _removerUltimo;
  late int _removerUltimoPos;


  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo(){
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoControler.text;
      _toDoControler.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(()  {
      _toDoList.sort((a, b){
        if(a["ok"] && !b["ok"]){
          return 1;
        }
        else if(!a["ok"] && b["ok"]){
          return -1;
        }
        else{
          return 0;
        }
      });

      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(child:
                TextField(
                  controller: _toDoControler,
                  decoration: InputDecoration(labelText: "Nova Tarefa",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
                ),
                ElevatedButton(style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent[700],
                    textStyle: TextStyle(color: Colors.white)
                ), onPressed: _addToDo, child: const Text("Adicionar")
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem,
                ),
                onRefresh: _refresh,
              )
          )
        ],
      ),
    );
  }

  Widget buildItem (context, index){
    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(
              -0.9, 0.0
            ),
            child: Icon(Icons.delete, color: Colors.white,
            ),
          ),
          ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(_toDoList[index]["title"] == null?"" : _toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(
                _toDoList[index]["ok"] ? Icons.check : Icons.error
            ),
          ),
          onChanged: (c) {
            setState(() {
              _toDoList[index]["ok"] = c;
              _saveData();
            });
          },
        ),
      onDismissed: (direction){
        setState(() {
          _removerUltimo = Map.from(_toDoList[index]);
          _removerUltimoPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_removerUltimo["title"]} Removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _toDoList.insert(_removerUltimoPos, _removerUltimo);
                  _saveData();
                });
              },
            ),
            duration: Duration(
              seconds: 2
            ),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
        );
  }

 /* */

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    }
    catch (e) {
      return "falso";
    }
  }

}

