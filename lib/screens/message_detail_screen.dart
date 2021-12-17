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
    //List lưu giữ tn của cả 2 list để cho vào hiển thị
    List<Message> allMessages = receivedMessages;
    allMessages.addAll(sentMessages);
    //sắp xếp các Message theo thứ tự thời gian để hiển thị
    allMessages.sort((message1, message2) {
      return -message1.timeStamp.compareTo(message2.timeStamp);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  /*Message List*/
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        160,
                    width: double.infinity,
                    child: ListView.separated(
                      itemCount: allMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        /*hiển thị các Message item: tùy thuộc vào việc ID của 
                        mình là receiver hay sender mà hiển thị message ở bên 
                        trái hay bên phải; và style của message cx khác nhau*/
                        bool isSender =
                            allMessages[index].receiverId == user.userID;

                        return Align(
                          alignment: isSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: FittedBox(
                            //set cho width của nó linh động theo text
                            fit: BoxFit.cover,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  allMessages[index].messageContent,
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              color: isSender ? Colors.green : Colors.white70,
                              shape: const StadiumBorder(
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      //Làm cho nó scroll từ dưới lên
                      reverse: true,
                      //cái sẽ phân cách giữa các item (chỉ dùng trong ListView.separated)
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 10),
                    ),
                  ),

                  //Input Message
                  Form(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
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
                                //_messageData['messageContent'] = value as String;
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
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : IconButton(
                                    onPressed: () {}, //_submit,
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
                  ),
                ],
              ),
            ),
    );
  }
}
