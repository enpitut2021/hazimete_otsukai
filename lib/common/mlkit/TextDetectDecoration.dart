import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';

// -----------------------------------------
// クラス　　 : TextDetectDecoration
// クラス概要 : テキストの位置を返す
// -----------------------------------------
class TextDetectDecoration extends Decoration {
  final Size _originalimageSize;
  final List<VisionText> _texts;

  TextDetectDecoration(this._originalimageSize, this._texts);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TextDetectPainter(_originalimageSize, _texts);
  }
}

// -----------------------------------------
// クラス名　 : _TextDetectPainter
// クラス概要 : テキストの位置を画像に描画する
// -----------------------------------------
class _TextDetectPainter extends BoxPainter {
  final Size _originalimageSize;
  final List<VisionText> _texts;

  _TextDetectPainter(this._originalimageSize, this._texts);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalimageSize.height / configuration.size!.height;
    final _widthRatio = _originalimageSize.width / configuration.size!.width;
    for (var text in _texts) {
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}
