class UserResponse {
  final String errorCode;
  final String result;
  final String message;
  Map id;
  String idnha;

  UserResponse(this.errorCode, this.result, this.message, this.id);

  UserResponse.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        result = json['result'],
        message = json['message'],
        id = json['id'],
        idnha = json['idnha'];
}
