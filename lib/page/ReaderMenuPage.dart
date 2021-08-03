import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';

// -----------------------------------
// クラス名　 : ReaderMenuPage
// クラス概要 : 読み込みメニューページ
// -----------------------------------
class ReaderMenuPage extends StatefulWidget {
  // null safety対応のため、Keyに?をつけ、titleは初期値""を設定
  ReaderMenuPage({Key? key, this.title = ""}) : super(key: key);

  final String title;

  @override
  ReaderMenuState createState() => ReaderMenuState();
}

class ReaderMenuState extends State<ReaderMenuPage> {
  // null safety対応のため、?でnull許容
  File? _image;
  String? _text;

  final _picker = ImagePicker();

  // null safety対応のため、?でnull許容
  String? _result;

  @override
  void initState() {
    super.initState();
    _signIn();
  }

  // 匿名でのFirebaseログイン処理
  void _signIn() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  Future _getImage(FileMode fileMode) async {
    // null safety対応のため、lateで宣言
    late final _pickedFile;

    // image_pickerの機能で、カメラからとギャラリーからの2通りの画像取得（パスの取得）を設定
    if (fileMode == FileMode.CAMERA) {
      _pickedFile = await _picker.pickImage(source: ImageSource.camera);
    } else {
      _pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      if (_pickedFile != null) {
        _image = File(_pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('レシート読み取り'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),

          // 写真のサイズによって画面はみ出しエラーが生じるのを防ぐため、
          // Columnの上にもSingleChildScrollViewをつける
          child: SingleChildScrollView(
            child: Column(children: [
              // 画像を取得できたら表示
              // null safety対応のため_image!とする（_imageはnullにならない）
              if (_image != null) Image.file(_image!, height: 400),

              // 画像を取得できたら解析ボタンを表示
              Container(
                  height: 240,

                  // OCR（テキスト検索）の結果をスクロール表示できるようにするため
                  // 結果表示部分をSingleChildScrollViewでラップ
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text((() {
                        // OCR（テキスト認識）の結果（_result）を取得したら表示
                        if (_result != null) {
                          // null safety対応のため_result!とする（_resultはnullにならない）
                          return _result!;
                        } else {
                          return 'レシートを撮影または読み込んでください';
                        }
                      }())))),
            ]),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // カメラ起動ボタン
          FloatingActionButton(
            onPressed: () async {
              await _getImage(FileMode.CAMERA);
              await _analysis();
            },
            tooltip: 'Pick Image from camera',
            child: Icon(Icons.camera_alt),
          ),

          // ギャラリー（ファイル）検索起動ボタン
          FloatingActionButton(
            onPressed: () async {
              await _getImage(FileMode.GALLERY);
              await _analysis();
            },
            tooltip: 'Pick Image from gallery',
            child: Icon(Icons.folder_open),
          ),
        ],
      ),
    );
  }

  // OCR（テキスト認識）開始処理
  Future _analysis() async {
    List<int> _imageBytes = _image!.readAsBytesSync();
    String _base64Image = base64Encode(_imageBytes);

    // Firebase上にデプロイしたFunctionを呼び出す処理
    HttpsCallable _callable =
        FirebaseFunctions.instance.httpsCallable('annotateImage');
    final params = '''{
          "image": {"content": "$_base64Image"},
          "features": [{"type": "TEXT_DETECTION"}],
          "imageContext": {
            "languageHints": ["ja"]
          }
        }''';

    _text = await _callable(params).then((v) {
      return v.data[0]["fullTextAnnotation"]["text"];
    }).catchError((e) {
      print('ERROR: $e');
      return '読み取りエラーです';
    });

    // OCR（テキスト認識）の結果を更新
    setState(() {
      _result = _text;
    });
  }
}

// カメラ経由かギャラリー（ファイル）経由かを示すフラグ
enum FileMode {
  CAMERA,
  GALLERY,
}
