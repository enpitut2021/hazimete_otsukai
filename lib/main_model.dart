import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'item.dart';

class MainModel extends ChangeNotifier {
  //Itemが入ってるリストを作っとく
  List<Item> itemList = [];

  // addItem()で使うやつ
  String itemText = '';

  // Qiitaの記事におけるfetchBooks()の役割
  // FirebaseのFirestore(DB)からデータを取得する
  Future getItemList() async {
    // Firebaseのアプデで、
    // Firestore → FirebaseFirestore
    // getDocuments() → get()
    // documents → docs
    // に変更されてます
    final docs = await FirebaseFirestore.instance.collection('itemList').get();
    final itemList = docs.docs.map((doc) => Item(doc)).toList();
    this.itemList = itemList;

    // notifyListeners()を呼び出すことで、
    // main.dartのConsumer以下が発火して、再描画される(らしい)
    // これでStatelessWidgetで書いたものがStatefulWidgetモドキになる
    notifyListeners();
  }

  // FirebaseのFirestoreにデータを書き込む
  Future addItem() async {
    // 追加するときなんも書かなかったらエラーをthrowする
    // throwしたエラーはtry catch構文で処理できる(らしい)
    // エラーメッセージ出す程度のやつを想定してます
    if (itemText.isEmpty) {
      throw ('入力してください');
    }
  }
}
