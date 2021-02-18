class DeviceResponse {
  final String errorCode;
  final String result;
  final String message;
  final int quyen;
  final String khoa;
  List<dynamic> id;
  String idnha;

  DeviceResponse(this.errorCode, this.result, this.message, this.id, this.quyen,
      this.khoa);

  DeviceResponse.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        result = json['result'],
        message = json['message'],
        id = json['id'],
        idnha = json['idnha'],
        quyen = json['quyen'],
        khoa = json['khoa'];
}
