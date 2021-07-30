// 【案内 & 方針】
// pubspec.yamlにいろいろ追記することでプラグインが使えるようになるよ
// 新しいページを作るときはそのページ用のdartファイルを新しく作るつもり
// (next_page.dart的な)
// 必要に応じて、各ページには対応するモデルファイルを作って動的にする
// (next_page_model.dart的な)

// Firebase有効化
import 'package:firebase_core/firebase_core.dart';

// マテリアルデザイン(Android風UI)が使えるようになる
// iOS風のUIはcupatino.dartをインポートすれば使える
import 'package:flutter/material.dart';

// ChangeNotifierProviderとConsumerウィジェットが使えるようになる
import 'package:provider/provider.dart';

// main_model.dartで定義したクラス有効化
import 'main_model.dart';

void main() async {
  // この下の2行がないとFirebase使えないようになったらしい
  // (去年の8月とかのアプデらしいので古いチュートリアルとかには載ってなかった)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red, // 全体のテーマ色が変わる
        // primaryColor: Colors.orange,
        // ↑ これでアプリ全体の色が変わるよ
      ),
      home: DefaultTabController(length: choices.length, child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final TextEditingController _fieldText = TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    final _focusNode = FocusNode();

    // ChangeNotifierBuilder: なんかstatelessでもstatefulにしてくれるやつ
    return ChangeNotifierProvider(
      // 下のやつで、MyHomePageが回ったタイミングでgetItemListRealtimeが実行される
      create: (context) => MainModel()..getItemListRealtime(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'TOBUY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true, // appBarのテキストが中央揃えになる
            bottom: TabBar(
              tabs: choices
                  .map((choice) => Tab(
                        text: choice.title,
                      ))
                  .toList(),
            ),
          ),
          body:
              // Consumerの下ならmodelファイルを参照できるらしい
              // (この場合main_model.dartのMainModelクラス)
              Column(children: <Widget>[
            // 入力フォーム
            // なんかインデントおかしいね 自動整型なのに～
            Consumer<MainModel>(builder: (context, model, child) {
              return TextField(
                controller: _fieldText,
                decoration: InputDecoration(
                  labelText: "　在庫を追加", // ラベル
                  hintText: "　例) 醤油", // ヒント
                ),
                onChanged: (text) {
                  // テキストフォームに入力されたテキスト(text)を
                  // main_model.dartのMainModelクラス内で予め用意しといた
                  // 空の文字列だったitemTextに挿入
                  model.itemText = text;
                },
                focusNode: _focusNode, // フォーカス用の値
                // Enterキーを押すことでアイテムを登録できる
                onSubmitted: (value) async {
                  try {
                    await model.addItem();
                    // テキストフォームのテキストを消す
                    _fieldText.clear();
                    // バグ: 内部のmodel.itemTextも消せば解消！
                    model.itemText = '';
                    _focusNode.requestFocus(); // フォーカスを再び渡す
                  } catch (e) {
                    await _showDialog(context, e.toString());
                  }
                },
              );
            }),
            // 登録ボタン
            // Consumer<MainModel>(builder: (context, model, child) {
            //   // ElevatedButtonが旧RaisedButton
            //   // ちなみにTextButtonは旧FlatButton
            //   return ElevatedButton(
            //     child: const Text("とうろく"),
            //     style: ElevatedButton.styleFrom(
            //         primary: Colors.red, onPrimary: Colors.grey[200]),
            //     onPressed: () async {
            //       // タップされたときの動作
            //       // モデルを参照する
            //       // (model.addItem → main_model.dartのMainModelクラスのaddItem()関数)
            //       // Firestoreにデータを追加する
            //       try {
            //         await model.addItem();
            //         _fieldText.clear();
            //         model.itemText = '';
            //       } catch (e) {
            //         await _showDialog(context, e.toString());
            //       }
            //     },
            //   );
            // }),
            SizedBox(
              height: 10,
            ),
            // Divider(),
            // リスト表示をつくるとこ
            Consumer<MainModel>(builder: (context, model, child) {
              final itemList = model.itemList;
              // mapメソッドでitemList内の各itemをListTileに変換
              // → .toList()で更にリストに変換
              // → 変換結果をlistTiles変数に代入
              final listTiles = itemList
                  // for item in itemList ... みたいな感じ
                  // itemList内の各itemを
                  // ListTile(title: Text(item.title!))
                  // の形式に割り当てていく
                  .map((item) => ListTile(
                        title: Text(item.title!),
                      ))
                  // 完成した複数のListTile(...)を.toList()でリストに変換する
                  // (ListTileを束ねる)
                  // ListView(children: ★) ← ★はリストになる必要があるから
                  .toList();
              // リストに変換されたlistTilesをListViewで描画
              return Flexible(
                  // ListView.separated: リストの各アイテムの間に線があるだけ
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
                          // childとしてListTileを複数取る
                          // child: ListTile(), ListTile(), ...
                          // のでlistTiles(ListTileのリスト)を[index]でループ
                          child: listTiles[index],
                          // これはなんかしらん
                          key: UniqueKey(),
                          background: Container(
                              color: Colors.redAccent,
                              child: Icon(Icons.clear, color: Colors.white)),
                          onDismissed: (direction) {
                            // 以下に消す処理を作成
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
      barrierDismissible: true, // OK押さなくても画面外を押せば消える
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              // 画面遷移 - 前の画面に戻る (今回の場合、ダイアログが消える)
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
