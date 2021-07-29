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
        primarySwatch: Colors.blue, // ← よくわかんない
        // primaryColor: Colors.orange,
        // ↑ これでアプリ全体の色が変わるよ
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierBuilder: なんかstatelessでもstatefulにしてくれるやつ
    return ChangeNotifierProvider(
      create: (context) => MainModel()..getItemList(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('在庫'),
            centerTitle: true, // appBarのテキストが中央揃えになる
          ),
          body:
              // Consumerの下ならmodelファイルを参照できるらしい
              // (この場合main_model.dartのMainModelクラス)
              Column(children: <Widget>[
            // 入力フォーム
            // なんかインデントおかしいね 自動整型なのに～
            Consumer<MainModel>(builder: (context, model, child) {
              return TextField(
                  decoration: InputDecoration(
                    labelText: "在庫を追加", // ラベル
                    hintText: "例) シャンプーの詰め替え", // ヒント
                  ),
                  onChanged: (text) {
                    // テキストフォームに入力されたテキスト(text)を
                    // main_model.dartのMainModelクラス内で予め用意しといた
                    // 空の文字列だったitemTextに挿入
                    model.itemText = text;
                  });
            }),
            // 登録ボタン
            Consumer<MainModel>(builder: (context, model, child) {
              // ElevatedButtonが旧RaisedButton
              // ちなみにTextButtonは旧FlatButton
              return ElevatedButton(
                child: const Text("とうろく"),
                style: ElevatedButton.styleFrom(
                    primary: Colors.red, onPrimary: Colors.grey[200]),
                onPressed: () {
                  // タップされたときの動作
                  // モデル参照
                  //(model.addItem → main_model.dartのMainModelクラスのaddItem()関数)
                  // Firestoreにデータを追加する
                  model.addItem();
                },
              );
            }),
            // リスト表示をつくるとこ
            Consumer<MainModel>(builder: (context, model, child) {
              final itemList = model.itemList;
              // mapメソッドでitemList内の書くitemをListTileに変換
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
                  // ListView(children: ★) ← ★はリストになる必要があるから
                  .toList();
              // リストに変換されたlistTilesをListViewで描画
              return Flexible(child: ListView(children: listTiles));
            }),
          ])),
    );
  }
}
