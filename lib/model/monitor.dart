import 'dart:convert';

class Monitor {
  String ten;
  String sdt;
  String nha;
  String mags;
  String mac;

  Monitor(this.ten, this.sdt, this.nha, this.mags, this.mac);

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

  Monitor.fromJson(Map<String, dynamic> json)
      : ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        mags = json['mags'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mags': mags,
        'mac': mac,
      };
}
