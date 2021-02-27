import 'dart:convert';

class Student {
  String mahs;
  String ten;
  String sdt;
  String nha;
  String mac;

  Student(this.mahs, this.ten, this.sdt, this.nha, this.mac);

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
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mahs': mahs,
        'mac': mac,
      };
}
