import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tobuy/common/mlkit/TextDetectDecoration.dart';
import 'package:mlkit/mlkit.dart';
import 'package:image/image.dart' as img;

import 'TextDetectDecoration.dart';

// MLKitのインスタンスを生成
FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;

// 認識結果を格納するリストを生成
List<VisionText> currentTextLabels = <VisionText>[];

// -----------------------------------------
// メソッド名 : reader
// 処理概要　 : 画像から文字orバーコードを認識する
// -----------------------------------------
Future<bool> reader(File? file) async {
  // 画像がnullである場合、falseを返却する
  if (file == null) {
    return false;
  }

  // 読み込み対象によって処理を分岐
  currentTextLabels = await textDetector.detectFromPath(file.path);

  return true;
}

// -----------------------------------------
// メソッド名: buildImage
// 処理概要: 画像データを生成
// -----------------------------------------
Widget buildImage(BuildContext context, File file) {
  // 画像を読み込み
  img.Image? i = img.decodeImage(file.readAsBytesSync());
  Size size = Size(i!.width.toDouble(), i.height.toDouble());

  return Container(
      // 画像を表示
      child: Center(
          child: file == null
              ? Text("画像を撮影してください")
              : Container(
                  foregroundDecoration:
                      TextDetectDecoration(size, currentTextLabels),
                  child: Image.file(file, fit: BoxFit.fitWidth))));
}

// -----------------------------------------
// メソッド名: buildTextList
// 処理概要: 文字リストを生成
// -----------------------------------------
Widget buildTextList(BuildContext context) {
  if (currentTextLabels.length == 0) {
    return Text("文字の認識に失敗しました。");
  }

  return Container(
      child: ListView.builder(
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    // padding: const EdgeInsets.all(1.0),
    itemCount: currentTextLabels.length,
    itemBuilder: (context, i) {
      return _buildRow(currentTextLabels[i].text);
    },
  ));
}

// -----------------------------------------
// メソッド名: _buildRow
// 処理概要: ListViewの行を生成
// -----------------------------------------
Widget _buildRow(text) {
  return ListTile(
    title: Text("$text"),
  );
}
