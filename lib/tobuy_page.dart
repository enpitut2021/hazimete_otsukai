import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tobuy/tobuy_model.dart';

class MyHomePage extends StatelessWidget {
  final TextEditingController _fieldText = TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    final _focusNode = FocusNode();

    return ChangeNotifierProvider(
      create: (context) => ToBuyModel(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'TOBUY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            bottom: TabBar(
              tabs: choices
                  .map((choice) => Tab(
                        text: choice.title,
                      ))
                  .toList(),
            ),
          ),
          body: Column(children: <Widget>[
            Consumer<ToBuyModel>(builder: (context, model, child) {
              return TextField(
                controller: _fieldText,
                decoration: InputDecoration(
                  labelText: "買うものを追加",
                  hintText: "　例) シャンプーの詰め替え",
                ),
                onChanged: (text) {
                  model.itemText = text;
                },
                focusNode: _focusNode,
                onSubmitted: (value) async {
                  try {
                    await model.addItem();
                    _fieldText.clear();
                    model.itemText = '';
                    _focusNode.requestFocus();
                  } catch (e) {
                    await _showDialog(context, e.toString());
                  }
                },
              );
            }),
            SizedBox(
              height: 10,
            ),
            Consumer<ToBuyModel>(builder: (context, model, child) {
              final itemList = model.itemList;
              final listTiles = itemList
                  .map((item) => ListTile(
                        title: Text(item.title!),
                      ))
                  .toList();
              return Flexible(
                  child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        if (index == itemList.length) {
                          return const Divider(
                            height: 1,
                          );
                        }
                        return Dismissible(
                          child: listTiles[index],
                          key: UniqueKey(),
                          background: Container(
                              color: Colors.redAccent,
                              child: Icon(Icons.clear, color: Colors.white)),
                          onDismissed: (direction) {
                            deleteItem(itemList[index]);
                          },
                        );
                      }));
            }),
          ])),
    );
  }

  Future _showDialog(BuildContext context, String title) async {
    await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class Choice {
  const Choice({this.title});

  final String? title;
}

const List<Choice> choices = const <Choice>[
  const Choice(
    title: 'STORAGE',
  ),
  const Choice(
    title: 'TOBUY',
  ),
];
