//import cái này để convert data sang JSON
import 'dart:convert';

import 'package:flutter/material.dart';
//import cái này để gửi http request
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class MessageProvider with ChangeNotifier {
  //String để lưu giữ Token khi Authentication
  final String? authToken;
  final String? userId;

  /*nhận token qua constructor 
  (truyền vào trong main.dart ở Provider khi khởi tạo Object)*/
  MessageProvider(this.authToken, this.userId);
}
