//import cái này để convert data sang JSON
import 'dart:convert';

import 'package:flutter/material.dart';
//import cái này để gửi http request
import 'package:http/http.dart' as http;

import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  //String để lưu giữ Token khi Authentication
  final String? authToken;
  final String? userId;

  /*nhận token qua constructor 
  (truyền vào trong main.dart ở Provider khi khởi tạo Object)*/
  MessageProvider(this.authToken, this.userId);

  /* function để lấy userID dựa trên username -> làm senderID khi tạo tin nhắn
  mới, trả về userID đó*/
  Future<String> getUserIdByUsername(String username) async {
    //get từ table User
    final filterString = 'orderBy="username"&equalTo="$username"';
    final url =
        'https://my-mess-39d32-default-rtdb.firebaseio.com/user.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(
        Uri.parse(url),
      );

      //decode data
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      //null thì return luôn
      if (extractedData == null) {
        return '';
      }

      //lưu userId lấy đc vào đây
      String userID = '';

      //gán vào attribute
      extractedData.forEach((id, data) {
        userID = data['userID'];
      });

      return userID;
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  /* Function để tạo 1 tin nhắn mới */
  Future<void> addMessage(String receiverID, String messageContent) async {
    final url =
        'https://my-mess-39d32-default-rtdb.firebaseio.com/message.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'messageContent': messageContent,
          'senderID': userId,
          'receiverID': receiverID,
          'timeStamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  /* Function để lấy những list người đã nhắn tin với mình -> Hiển thị List Message */
  Future<List<String>> getFriends() async {
    //list lưu những message tới mình hoặc mình gửi đi -> từ đó lọc ra friend
    List<Message> listMess = [];

    //Lấy những Message có mình là sender
    listMess.addAll(await getMessages(isSender: true));

    //Lấy những Message có mình là receiver
    listMess.addAll(await getMessages(isSender: false));

    //list những ng đã nhắn tin vs mình
    List<String> friendList = [];

    print(listMess[1]);

    return friendList;
  }

  /* function để lấy những message có mình là sender hoặc receiver từ server */
  Future<List<Message>> getMessages({required bool isSender}) async {
    //biến để lưu list message
    List<Message> listMess = [];

    //biến để gán vào filterString tùy theo muốn tìm theo sender hay receiver
    String role = isSender ? 'senderID' : 'receiverID';

    final filterString = 'orderBy="' + role + '"&equalTo="$userId"';
    final url =
        'https://my-mess-39d32-default-rtdb.firebaseio.com/message.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(
        Uri.parse(url),
      );

      //decode data
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      //null thì return luôn
      if (extractedData == null) {
        return listMess;
      }

      //gán vào list message
      extractedData.forEach((id, data) {
        listMess.add(
          Message(
            messageContent: data['messageContent'],
            senderId: data['senderID'],
            receiverId: data['receiverID'],
            timeStamp: DateTime.parse(data['timeStamp']),
          ),
        );
      });

      return listMess;
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
