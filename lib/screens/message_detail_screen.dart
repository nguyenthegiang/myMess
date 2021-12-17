import 'package:flutter/material.dart';

import '../models/user.dart';

//hiển thị chi tiết tin nhắn vs 1 ng cụ thể, và tính năng chat
class MessageDetailScreen extends StatelessWidget {
  const MessageDetailScreen({Key? key}) : super(key: key);

  static const routeName = 'message-detail';

  @override
  Widget build(BuildContext context) {
    //Lấy user trong argument từ named route
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: Text('hi'),
    );
  }
}
