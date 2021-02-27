class HistoryResponse{
  final String errorCode;
  final String result;
  final String message;
  final List<dynamic> id;
  String idnha;

  HistoryResponse(this.errorCode, this.result, this.message, this.id);

  HistoryResponse.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        result = json['result'],
        message = json['message'],
        id = json['id'],
        idnha = json['idnha'];
}