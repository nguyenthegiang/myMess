//Lưu trữ Model Message
class Message {
  String messageContent;
  String senderId;
  String receiverId;
  DateTime timeStamp;

  Message({
    required this.messageContent,
    required this.senderId,
    required this.receiverId,
    required this.timeStamp,
  });
}
