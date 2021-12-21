import 'package:flutter/material.dart';
import 'package:my_mess/widgets/message_input_form.dart';
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
      Provider.of<MessageProvider>(
        context,
        listen: false,
      ).getPersonalMessages(user.userID).then((_) {
        setState(() {
          //chuyển màn hình lại bình thường sau khi lấy data xong
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _showMessageInput(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (context) {
        return MessageInputForm(_isInit, _isLoading,
            ModalRoute.of(ctx)!.settings.arguments as User);
      },
    );
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
        actions: [
          //Nhấn nút này để reload -> xem tin nhắn mới
          IconButton(
            onPressed: () {
              _isInit = true;
              didChangeDependencies();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
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
                ],
              ),
            ),
      //Input Message
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showMessageInput(context),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
