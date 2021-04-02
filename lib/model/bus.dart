import 'dart:convert';

class Bus {
  String matx;
  String tentuyen;
  String maxe;
  String note;
  String mac;
  String malx;
  String mags;
  String matb;
  String giohds;
  String giohdc;
  dynamic ngay;
  dynamic data;
  List<String> mahs;

  Bus(
      this.matx,
      this.tentuyen,
      this.maxe,
      this.malx,
      this.mags,
      this.matb,
      this.note,
      this.giohds,
      this.giohdc,
      this.ngay,
      this.data,
      this.mahs,
      this.mac);

  String get tenDecode {
    try {
      String s = tentuyen;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return tentuyen;
    }
  }

  String get ghichuDecode {
    try {
      String s = note;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return note;
    }
  }

  Bus.fromJson(Map<String, dynamic> json)
      : matx = json['matx'],
        tentuyen = json['tentuyen'],
        maxe = json['maxe'],
        note = json['note'],
        mac = json['mac'],
        malx = json['malx'],
        mags = json['mags'],
        giohds = json['giohds'],
        giohdc = json['giohdc'],
        ngay = json['ngay'],
        data = json['data'],
        mahs = json['mahs'],
        matb = json['matb'];

  Map<String, dynamic> toJson() {
    return {
      'matx': matx,
      'tentuyen': tentuyen,
      'maxe': maxe,
      'malx': malx,
      'mags': mags,
      'matb': matb,
      'note': note,
      'giohds': giohds,
      'giohdc': giohdc,
      'ngay': ngay,
      'data': data,
      'mahs': mahs,
      'mac': mac,
    };
  }

  @override
  String toString() {
    return '$matx - $tentuyen - $maxe - $note - $mac - $malx - $mags - $matb';
  }
}
