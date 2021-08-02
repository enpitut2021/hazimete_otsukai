import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class CameraController {
  // ドキュメントのパスを取得
  static Future get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 画像をドキュメントへ保存する
  static Future saveLocalImage(File image) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMddHHmmss');
    String formatted = formatter.format(now);

    final documentPath = await localPath;
    final imagePath = "$documentPath/$formatted-image.jpg";

    File imageFile = File(imagePath);

    // 一時フォルダに保存された画像をドキュメントへ保存し直す
    var saveFile = await imageFile.writeAsBytes(await image.readAsBytes());

    return saveFile;
  }

  // ドキュメントの画像を取得する
  static Future leadLocalImage() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMddHHmmss');
    String formatted = formatter.format(now);

    final path = await localPath;
    final imagePath = "$path/$formatted-image.jpg";
    return File(imagePath);
  }

  static Future<File?> getAndSaveImageFromDevice(ImageSource source) async {
    // 撮影した画像を取得
    var imageFile = await ImagePicker().pickImage(source: source);

    // 撮影せず閉じた場合はnullが格納される
    if (imageFile == null) {
      return null;
    }

    var saveFile = await CameraController.saveLocalImage(File(imageFile.path));

    return saveFile;
  }
}
