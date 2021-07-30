import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'item.dart';

class ToBuyModel extends ChangeNotifier {
  List<Item> itemList = [];

  String itemText = '';

  Future getItemList() async {
    final docs = await FirebaseFirestore.instance.collection('itemList').get();
    final itemList = docs.docs.map((doc) => Item(doc)).toList();
    this.itemList = itemList;

    notifyListeners();
  }

  void getItemListRealtime() {
    final snapshots =
        FirebaseFirestore.instance.collection('itemList').snapshots();
    snapshots.listen((snapshot) {
      final itemList = snapshot.docs.map((doc) => Item(doc)).toList();
      itemList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      this.itemList = itemList;
      notifyListeners();
    });
  }

  Future addItem() async {
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
