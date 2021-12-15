/* Sign up - Login - Session */
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  /*token thường sẽ expire sau 1 khoảng thời gian (với Firebase là 1 tiếng)
  nên phải lưu lại thời gian expire*/
  String? _userId;
  //timer để tự động logout
  Timer? _authTimer;

  /* Kiểm tra xem đã login chưa, dùng cho main.dart;
  Rule: nếu có token và token chưa expire thì là login rồi */
  bool get isAuth {
    //nếu getter token ko null thì return true
    return token != null;
  }

  //kiểm tra xem có token ko và token đó phải chưa expire
  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    //nếu ko có hoặc đã expire thì return null
    return null;
  }

  //getter cho userId (dùng khi add Favorite)
  String? get userId {
    return _userId;
  }

  /*Sign up:
  Hướng dẫn: https://firebase.google.com/docs/reference/rest/auth#section-create-email-password */
  Future<void> signup(String email, String password) async {
    //phải return để cái loading spinner hoạt động bình thường đc
    return _authenticate(email, password, 'signUp');
  }

  /* Login:
  Hướng dẫn: https://firebase.google.com/docs/reference/rest/auth#section-sign-in-email-password */
  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  /* Optional: vì 2 function login và signup có code tương tự -> có thể dùng
  chung 1 function thôi, truyền vào URL vì đó là cái khác duy nhất */
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    /* API Key để cho vào URL: copy từ Firebase -> Project Settings -> Web API Key */
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAQjs7T7XyZMNiUFse_kwgsPSLV-Q2Dpx4';
    //URL gắn vs URL truyền vào

    //cho vào try catch để nếu có lỗi gì thì xử lý
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      /* (nếu là server API khác thì có thể truyền về error code -> http.post()
      sẽ throw ra error) nhưng Firebase luôn trả về code 200, kế cả có lỗi, và
      lỗi thì ở trong message thôi -> mình phải tự check message xem có lỗi thì
      throw ra*/
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        /*nếu có key 'error' trong Map (khi có lỗi sẽ có) thì throw ra cái 
        exception mà mình tạo ra*/
        throw HttpException(responseData['error']['message']);
        //throw ra cái message của Firebase -> xử lý bên auth_screen
      }

      //set token và các thứ để check chuyển page sang home
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //response chỉ có số giây (string) cho đến lúc expire thôi -> phải tự tính
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      /* gọi đến autoLogout() để nó bắt đầu tính Timer */
      _autoLogout();

      notifyListeners();

      /* Lưu trữ Token vào SharedPreferences cho tính năng auto Login;
      cái này có dùng Future nên phải cho vào async (ở đây có sẵn r) */

      /*truy cập SharedPreferences để dùng (cái này return về Future, mà sau đó 
      sẽ return về SharedPreferences) -> dùng cái này để truy cập vào device storage*/
      final prefs = await SharedPreferences.getInstance();
      /* giờ có thể dùng prefs để read/write data vào storage:
      write: set() method, có thể write string, boolean,...
      nếu có 1 map thì có thể convert về json rồi write vì json sẽ đc convert
      thành String*/
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      //lưu trữ theo kiểu key-data
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }

    //print(json.decode(response.body));
  }

  /* method để lấy dữ liệu từ device storage để tự động login khi mở app,
  nếu thành công thì return true */
  Future<bool> tryAutoLogin() async {
    //get access to SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    //kiểm tra xem có data ko
    if (!prefs.containsKey('userData')) {
      //nếu ko có SharedPreferences với key này thì là ko có thông tin để auto login
      return false;
    }

    //extract user data: lấy String có key là 'userData' và decode sang Map
    final extractedUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, dynamic>;
    //Sửa so với vid: cái này phải là dynamic chứ ko phải Object ko sẽ bị Exception

    //kiểm tra xem data có valid ko
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      //nếu expiryDate trc DateTime.now() -> token expire rồi
      return false;
    }

    //data valid -> set lại các attribute và tự động login
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;

    notifyListeners();

    //gọi auto logout để reset timer
    _autoLogout();

    return true;
  }

  //Log user out
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;

    /*nếu là trg hợp ng dùng chọn logout -> nếu login vào lại thì sẽ bị có 2 
    timer chạy cùng lúc -> phải xóa timer đi trc khi logout*/
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    notifyListeners();

    /* Xóa data trong SharedPreferences đi kẻo nó lại tự login lại */
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData'); //xóa 1 data nhất định
    prefs.clear(); //xóa hết: dùng cx đc vì mình chỉ có 1 cái
  }

  //Tự động log out sau 1 thời gian (khi token expire)
  void _autoLogout() {
    //nếu đang có 1 timer rồi thì xóa nó đi dã xong mới tạo cái khác
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    //tính thời gian đến lúc expire
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    /*dùng class Timer trong library dart:async để set timer, truyền vào 1 
    Duration để expire và 1 function để thực hiện khi expire*/
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
