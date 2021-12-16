import 'package:flutter/material.dart';
import 'package:my_mess/providers/auth.dart';
import 'package:my_mess/providers/message_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  static const routeName = 'new-message';

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  @override
  Widget build(BuildContext context) {
    //lấy username để hiển thị
    final username = Provider.of<Auth>(context).username;
    /*Global Key để hỗ trợ interact với State của Form: GlobalKey là 1 Generic, 
    mà type truyền vào là 1 State của Widget*/
    final GlobalKey<FormState> _formKey = GlobalKey();
    //Map để lưu giữ thông tin Form submit
    Map<String, String> _messageData = {
      'receiverID': '',
      'receiverUsername': '',
      'messageContent': '',
    };
    //biến cho loading Spinner
    var _isLoading = false;

    //function để show cái error message nếu có khi submit
    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                //ấn nút này thì đóng dialog
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
    }

    Future<void> _submit() async {
      //validate
      if (!_formKey.currentState!.validate()) {
        return;
      }
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      //submit
      try {
        //Lấy userID dựa trên username
        _messageData['receiverID'] = await Provider.of<MessageProvider>(
          context,
          listen: false,
        ).getUserIdByUsername(_messageData['receiverUsername'] as String);

        //Add Message vào DB
        await Provider.of<MessageProvider>(
          context,
          listen: false,
        ).addMessage(
          _messageData['receiverID'] as String,
          _messageData['messageContent'] as String,
        );
      } catch (error) {
        //hiển thị thông báo lỗi
        const errorMessage =
            'Something gone wrong, please try again.\n(Probably incorrect username or Network Connection)';
        _showErrorDialog(errorMessage);
      }

      setState(() {
        _isLoading = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tin nhắn mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Send to
              Container(
                height: 80,
                child: Row(
                  children: [
                    Text(
                      'Tới: ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    //Input send to
                    Container(
                      width: 300,
                      child: TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Nhập tên người dùng'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hãy nhập tên người dùng!';
                          }
                        },
                        onSaved: (value) {
                          _messageData['receiverUsername'] = value as String;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              //Message Content
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    //Input Message
                    Container(
                      width: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          hintText: 'Nhập tin nhắn',
                        ),
                        style: TextStyle(
                          height: 1.5,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hãy nhập tin nhắn!';
                          }
                        },
                        onSaved: (value) {
                          _messageData['messageContent'] = value as String;
                        },
                      ),
                    ),

                    //Submit
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        bottom: 6,
                      ),
                      child: IconButton(
                        onPressed: _submit,
                        icon: Icon(
                          Icons.send,
                          size: 35,
                          color: Color.fromRGBO(31, 105, 36, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
