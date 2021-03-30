import 'dart:convert';

class Student {
  String mahs;
  String ten;
  String sdt;
  String nha;
  String mac;
  String maph;
  String matx;

  Student(this.mahs, this.ten, this.sdt, this.nha, this.maph, this.mac);

  String get tenDecode {
    try {
      String s = ten;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return ten;
    }
  }

  String get nhaDecode {
    try {
      String s = nha;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return nha;
    }
  }

  Student.fromJson(Map<String, dynamic> json)
      : ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        mahs = json['mahs'],
        maph = json['maph'],
        mac = json['mac'],
        matx = json['matx'];

  Map<String, dynamic> toJson() => {
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mahs': mahs,
        'maph': maph,
        'mac': mac,
        'matx': matx,
      };
}
