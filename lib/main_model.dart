import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'item.dart';

class MainModel extends ChangeNotifier {
  //Itemが入ってるリストを作っとく
  List<Item> itemList = [];

  // addItem()で使うやつ
  // テキストフォームに入力されたテキストを格納する用の変数
  String itemText = '';

  // Qiitaの記事におけるfetchBooks()の役割
  // FirebaseのFirestore(DB)からデータを取得する
  Future getItemList() async {
    // Firebaseのアプデで、
    // Firestore → FirebaseFirestore
    // getDocuments() → get()
    // documents → docs
    // に変更されてます のでQiitaのとはちょっと違うよ
    final docs = await FirebaseFirestore.instance.collection('itemList').get();
    final itemList = docs.docs.map((doc) => Item(doc)).toList();
    this.itemList = itemList;

    // notifyListeners()を呼び出すことで、
    // main.dartのConsumer以下が発火して、アプリのページが再描画される(らしい)
    // これでStatelessWidgetで書いたものがStatefulWidgetモドキになる
    // 逆にいうと、ページ内で変化があってもこれ呼び出さないと何も変わらない
    notifyListeners();
  }

  void getItemListRealtime() {
    final snapshots =
        FirebaseFirestore.instance.collection('itemList').snapshots();
    // pythonでいうとfor snpashot in snapshots みたいな感じ
    // snapshotsがデータの流れ(Stream型)。
    // データの流れからそれぞれのデータを1個1個取り出して、{}内の処理を行う
    // forの代わりにlistenってやってると思えばいいかも？
    snapshots.listen((snapshot) {
      final itemList = snapshot.docs.map((doc) => Item(doc)).toList();
      itemList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      this.itemList = itemList;
      notifyListeners();
    });
  }

  // FirebaseのFirestoreにデータを書き込む
  Future addItem() async {
    // 追加するときなんも書かなかったらエラーをthrowする
    // throwしたエラーはtry catch構文で処理できる(らしい)
    // エラーメッセージ出す程度のやつを想定してます
    if (itemText.isEmpty) {
      throw ('入力してください');
    }

    final docs = FirebaseFirestore.instance.collection('itemList');
    await docs.add({
      'title': itemText,
      'createdAt': Timestamp.now(),
    });
  }

  Future reload() async {
    notifyListeners();
  }
}

Future deleteItem(Item item) async {
  await FirebaseFirestore.instance
      .collection('itemList')
      .doc(item.documentID)
      .delete();
}

Future addToBuy(Item item) async {
  await FirebaseFirestore.instance.collection('toBuyList').add({
    'title': item.title,
    'createdAt': Timestamp.now(),
  });
}
