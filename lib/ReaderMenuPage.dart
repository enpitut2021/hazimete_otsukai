import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:tobuy/user_photo_comfirm_page.dart';
import 'main_model.dart';

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

  Future _getImage(BuildContext context, FileMode fileMode) async {
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

    if (_pickedFile != null) {
      final croppedImage = await _cropImage(_pickedFile.path);
      if (croppedImage != null) {
        // 画像切り抜きに成功した場合、確認ページに遷移
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserPhotoConfirmPage(
                    file: _image,
                  )),
        );
      }
    }
  }

  Future _cropImage(String imagePath) async {
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
    );
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainModel(),
      child: Scaffold(
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

                Container(
                    height: 240,

                    // OCR（テキスト検索）の結果をスクロール表示できるようにするため
                    // 結果表示部分をSingleChildScrollViewでラップ
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Consumer<MainModel>(
                            builder: (context, model, child) {
                          return Text(() {
                            // OCR（テキスト認識）の結果（_result）を取得したら表示
                            if (_result != null) {
                              // null safety対応のため_result!とする（_resultはnullにならない）
                              print(_result!.trim().split("\n"));
                              List<String> receiptItemList =
                                  _result!.trim().split("\n");
                              receiptItemList.forEach((element) {
                                model.itemText = element;
                                model.addItem();
                              });
                              return _result!.trim();
                            } else {
                              return 'レシートを撮影または読み込んでください';
                            }
                          }());
                        }))),
              ]),
            ),
          ),
        ),
        floatingActionButton: Column(
          verticalDirection: VerticalDirection.up,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ギャラリー（ファイル）検索起動ボタン
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                heroTag: "hero1",
                onPressed: () async {
                  await _getImage(context, FileMode.GALLERY);
                  await _analysis();
                },
                tooltip: 'Pick Image from gallery',
                child: Icon(Icons.folder_open),
              ),
            ),
            // カメラ起動ボタン
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                heroTag: "hero2",
                onPressed: () async {
                  await _getImage(context, FileMode.CAMERA);
                  await _analysis();
                },
                tooltip: 'Pick Image from camera',
                child: Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
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
