import 'package:flutter/material.dart';
import 'package:my_mess/providers/auth.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  static const routeName = 'new-message';

  @override
  Widget build(BuildContext context) {
    //lấy username để hiển thị
    final username = Provider.of<Auth>(context).username;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tin nhắn mới'),
      ),
      body: Container(),
    );
  }
}
