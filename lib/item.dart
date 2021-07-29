import 'package:cloud_firestore/cloud_firestore.dart';

// 型とか変数の最後に「?」とか「!」とか付いてるけど
// なんか最近Dartのアプデがあったらしくて
// Null safetyってのが追加されたらしい(しらべてね)
// なんか赤下線で怒られたらどっちかつける程度の認識です

// Firebaseのデータを格納するクラスを作る
class Item {
  // これぼくも正直よくわからんです
  Item(DocumentSnapshot? doc) {
    title = doc!['title'];
    final Timestamp timestamp = doc['createdAt'];
    createdAt = timestamp.toDate();
  }

  // Itemに含まれる内容
  String? title;
  DateTime? createdAt; // 登録された時間でソートしたいため
}
