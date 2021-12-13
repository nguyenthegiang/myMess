/*Class này để tạo 1 Exception có thể tung ra khi cần (khi kết nối với Server)
vì Flutter ko muốn mình dùng thẳng class Exception của nó*/
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}
