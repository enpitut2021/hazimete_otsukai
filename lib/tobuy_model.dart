import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'item.dart';

class ToBuyModel extends ChangeNotifier {
  List<Item> toBuyList = [];

  String toBuyText = '';

  void getToBuyListRealtime() {
    final snapshots =
        FirebaseFirestore.instance.collection('toBuyList').snapshots();
    snapshots.listen((snapshot) {
      final toBuyList = snapshot.docs.map((doc) => Item(doc)).toList();
      toBuyList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      this.toBuyList = toBuyList;
      notifyListeners();
    });
  }

  Future addToBuy() async {
    if (toBuyText.isEmpty) {
      throw ('入力してください');
    }

    final docs = FirebaseFirestore.instance.collection('toBuyList');
    await docs.add({
      'title': toBuyText,
      'createdAt': Timestamp.now(),
    });
  }

  Future reload() async {
    notifyListeners();
  }
}

Future deleteToBuy(Item item) async {
  await FirebaseFirestore.instance
      .collection('toBuyList')
      .doc(item.documentID)
      .delete();
}
