import 'package:flutter/material.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

//hiển thị chi tiết tin nhắn vs 1 ng cụ thể, và tính năng chat
class MessageDetailScreen extends StatefulWidget {
  const MessageDetailScreen({Key? key}) : super(key: key);

  static const routeName = 'message-detail';

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  //Biến để cho didChangeDependencies() chỉ chạy 1 lần thôi
  var _isInit = true;
  //biến để làm loading spinner
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    /* Khi mới vào screen thì load list message*/
    if (_isInit) {
      setState(() {
        //chuyển màn hình sang loading
        _isLoading = true;
      });

      //Lấy user trong argument từ named route
      final user = ModalRoute.of(context)!.settings.arguments as User;
      //gọi getPersonalMessages() để lấy list message từ server
      Provider.of<MessageProvider>(context)
          .getPersonalMessages(user.userID)
          .then((_) {
        setState(() {
          //chuyển màn hình lại bình thường sau khi lấy data xong
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //Lấy user trong argument từ named route
    final user = ModalRoute.of(context)!.settings.arguments as User;
    //các list lưu giữ tin nhắn
    List<Message> receivedMessages =
        Provider.of<MessageProvider>(context).receivedMessages;
    List<Message> sentMessages =
        Provider.of<MessageProvider>(context).sentMessages;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Text(sentMessages[0].messageContent),
    );
  }
}
