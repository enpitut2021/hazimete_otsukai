import 'dart:io';

import 'package:flutter/material.dart';

class UserPhotoConfirmPage extends StatefulWidget {
  UserPhotoConfirmPage({Key? key, required file}) : super(key: key);

  @override
  _UserPhotoConfirmPageState createState() => _UserPhotoConfirmPageState();
}

class _UserPhotoConfirmPageState extends State<UserPhotoConfirmPage> {
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(file!),
            ),
          ),
        ),
      ),
    );
  }
}
