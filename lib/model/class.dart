import 'dart:convert';

Map<String, List<String>> classFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) =>
        MapEntry<String, List<String>>(k, List<String>.from(v.map((x) => x))));

String classToJson(Map<String, List<String>> data) =>
    json.encode(Map.from(data).map((k, v) =>
        MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))));

List<String> gradeFromJson(String str) =>
    List<String>.from(json.decode(str).map((x) => x));

String gradeToJson(List<String> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));

List<ClassResponse> classResponseFromJson(String str) => List<ClassResponse>.from(json.decode(str).map((x) => ClassResponse.fromJson(x)));

String classResponseToJson(List<ClassResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClassResponse {
  ClassResponse({
    this.lop,
    this.khoi,
    this.time,
    this.ngayupdate,
  });

  String lop;
  dynamic khoi;
  String time;
  String ngayupdate;

  factory ClassResponse.fromJson(Map<String, dynamic> json) => ClassResponse(
    lop: json["lop"],
    khoi: json["khoi"],
    time: json["time"],
    ngayupdate: json["ngayupdate"],
  );

  Map<String, dynamic> toJson() => {
    "lop": lop,
    "khoi": khoi,
    "time": time,
    "ngayupdate": ngayupdate,
  };
}

class Class {
  String lop;
  String mac;
  String khoi;

  Class(this.khoi, this.lop, this.mac);

  Map<String, dynamic> toJson() => {
        'khoi': khoi,
        'lop': lop,
        'mac': mac,
      };

  Class.fromJson(Map<String, dynamic> json) {
    lop = json['lop'];
    khoi = json['khoi'];
    mac = json['mac'];
  }
}
