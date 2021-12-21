import 'package:flutter/material.dart';
import 'package:my_mess/models/user.dart';
import 'package:my_mess/providers/message_provider.dart';
import 'package:provider/provider.dart';

//Message Input in MessageDetail Screen
class MessageInputForm extends StatefulWidget {
  //Biến để cho didChangeDependencies() chỉ chạy 1 lần thôi
  var _isInit = true;
  //biến để làm loading spinner
  var _isLoading = false;
  //user để lấy id
  User user;

  //1 số thứ truyền vào qua constructor
  MessageInputForm(
    this._isInit,
    this._isLoading,
    this.user,
  );

  @override
  _MessageInputFormState createState() => _MessageInputFormState();
}

class _MessageInputFormState extends State<MessageInputForm> {
  /*Global Key để hỗ trợ interact với State của Form: GlobalKey là 1 Generic, 
    mà type truyền vào là 1 State của Widget*/
  final GlobalKey<FormState> _formKey = GlobalKey();
  //Map để lưu giữ thông tin Form submit
  Map<String, String> _messageData = {
    'receiverID': '',
    'messageContent': '',
  };

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

  Future<void> _submit(BuildContext context) async {
    //validate
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      widget._isLoading = true;
    });

    //submit
    try {
      //Lấy user trong argument từ named route
      final user = widget.user;
      //Lấy friendID dựa trên User truyền vào
      _messageData['receiverID'] = user.userID;

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
      widget._isLoading = false;
    });

    /* Submit xong thì load lại list message để thấy thay đổi -> gọi lại
    didChangeDependencies() */
    widget._isInit = true;
    didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1),
          ),
        ),
        child: Row(
          children: [
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
              //khi đang load thì nút submit chuyển thành loading spinner
              child: widget._isLoading
                  ? CircularProgressIndicator()
                  : IconButton(
                      onPressed: () {
                        _submit(context);
                      },
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
    );
  }
}
