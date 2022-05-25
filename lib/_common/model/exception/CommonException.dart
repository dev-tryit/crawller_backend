class CommonException implements Exception {
  String message;
  String code;

  CommonException({this.message = "", this.code = ""});

  @override
  String toString() => message;
}
