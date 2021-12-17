import 'package:flutter/material.dart';

import '../screens/message_detail_screen.dart';
import '../models/user.dart';

//Hiển thị 1 MessageItem trong Home Screen
class MessageItem extends StatelessWidget {
  final User user;

  const MessageItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: GestureDetector(
        //ấn vào thì chuyển sang MessageDetailScreen, gửi user sang để hiển thị
        onTap: () {
          Navigator.of(context).pushNamed(
            MessageDetailScreen.routeName,
            arguments: user,
          );
        },
        child: ListTile(
          title: Text(user.username),
          subtitle: Text('Message sent'),
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/default-avatar.png'),
          ),
          trailing: Icon(Icons.check_circle),
        ),
      ),
    );
  }
}
