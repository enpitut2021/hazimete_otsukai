import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tobuy/common/CameraController.dart';
import 'package:image_picker/image_picker.dart';

import 'ReaderDetailPage.dart';

// -----------------------------------
// クラス名　 : ReaderMenuPage
// クラス概要 : 読み込みメニューページ
// -----------------------------------
class ReaderMenuPage extends StatefulWidget {
  ReaderMenuPage({Key? key}) : super(key: key);

  @override
  _ReaderMenuState createState() => _ReaderMenuState();
}

// -----------------------------------
// クラス名　 : _ReaderMenuState
// クラス概要 : 読み込みメニューページステート
// -----------------------------------
class _ReaderMenuState extends State<ReaderMenuPage> {
  // 変数宣言
  /* 読み込み方法 */ ImageSource? _imageSource = ImageSource.camera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("画像認識"),
      ),
      body: Column(
        children: <Widget>[
          Text(
            "読み込み方法を選択してください。",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          RadioListTile<ImageSource>(
            title: Text("カメラ"),
            groupValue: _imageSource,
            value: ImageSource.camera,
            onChanged: (value) {
              _imageSource = value;
              setState(() {});
            },
          ),
          RadioListTile<ImageSource>(
            title: Text("ギャラリー"),
            groupValue: _imageSource,
            value: ImageSource.gallery,
            onChanged: (value) {
              _imageSource = value;
              setState(() {});
            },
          ),
          ElevatedButton(
              child: Text("スキャン開始"),
              onPressed: () async {
                // 指定された読み込み方法で画像を取得
                try {
                  File? file = await CameraController.getAndSaveImageFromDevice(
                      _imageSource!);

                  // 画像が取得できた場合に明細ページに遷移
                  if (file == null) {
                    throw Exception('ファイルを取得できませんでした');
                  }
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new ReaderDetailPage(file)),
                  );
                } catch (e) {}
              }),
        ],
      ),
    );
  }
}
