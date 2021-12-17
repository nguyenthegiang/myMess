import 'package:flutter/material.dart';
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
      child: ListTile(
        title: Text(user.username),
        subtitle: Text('Message sent'),
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/default-avatar.png'),
        ),
        trailing: Icon(Icons.check_circle),
      ),
    );
  }
}
