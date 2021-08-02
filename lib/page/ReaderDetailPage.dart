import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tobuy/common/mlkit/MLKitModule.dart';

// -----------------------------------
// クラス名　 : ReaderDetailPage
// クラス概要 : 読み込み明細ページ
// -----------------------------------
class ReaderDetailPage extends StatefulWidget {
  // 変数宣言
  /* 処理対象画像 */ final File _file;

  ReaderDetailPage(this._file);

  @override
  _ReaderDetailState createState() => _ReaderDetailState();
}

// -----------------------------------
// クラス名　 : _ReaderDetailState
// クラス概要 : 読み込み明細ページステート
// -----------------------------------
class _ReaderDetailState extends State<ReaderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("読み込み結果"),
          ),
          body: SingleChildScrollView(
              child: FutureBuilder<bool>(
                  future: reader(widget._file),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          Image.file(widget._file),
                          Container(
                            width: double.infinity,
                            color: Colors.cyan[50],
                            child: Text(
                              "大根\nたまねぎ\nチョコパンBB\nISPポテトS\nはまソーダ500ML\n姫かま\n",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasData) {
                      return Column(
                        children: <Widget>[
                          // 読み込み結果を表示
                          Text("読み込み成功"),
                          buildImage(context, widget._file),
                          buildTextList(context)
                        ],
                      );
                    } else if (snapshot.hasError)
                      return Text('error');
                    else {
                      return Text('none');
                    }
                  }))),
    );
  }
}
