import 'package:flutter/material.dart';

import 'main.dart';

class LoginPage extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ログイン',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                icon: Icon(Icons.email),
                labelText: "メールアドレス",
                hintText: 'メールアドレスを入力',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '入力してください';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'パスワード',
                hintText: 'パスワードを入力',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '入力してください';
                }
                return null;
              },
              obscureText: true,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Text('確認'))
        ],
      ),
    );
  }
}
