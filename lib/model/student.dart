import 'dart:convert';

class Student {
  String mahs;
  String ten;
  String sdt;
  String nha;
  String mac;
  String maph;
  String matx;
  String lop;
  String khoi;
  String tenhs;
  bool isSelected = false;

  Student(this.mahs, this.ten, this.sdt, this.nha, this.maph, this.lop,
      this.khoi, this.mac);

  String get tenDecode {
    try {
      String s = ten ?? tenhs;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return ten ?? tenhs;
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
        matx = json['matx'],
        lop = json['lop'],
        tenhs = json['tenhs'],
        khoi = json['khoi'];

  Map<String, dynamic> toJson() => {
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mahs': mahs,
        'maph': maph,
        'mac': mac,
        'matx': matx,
        'lop': lop,
        'khoi': khoi,
        'tenhs': tenhs,
      };
}
