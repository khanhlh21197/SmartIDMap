import 'dart:convert';

class Driver {
  String ten;
  String sdt;
  String nha;
  String malx;
  String mac;

  Driver(this.ten, this.sdt, this.nha, this.malx, this.mac);

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

  Driver.fromJson(Map<String, dynamic> json)
      : ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        malx = json['malx'],
        mac = json['mac'];
}
