import 'dart:convert';

class Bus {
  String matx;
  String tentuyen;
  String maxe;
  String note;
  String mac;

  Bus(this.matx, this.tentuyen, this.maxe, this.note, this.mac);

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
        mac = json['mac'];

  Map<String, dynamic> toJson() {
    return {
      'matx': matx,
      'tentuyen': tentuyen,
      'maxe': maxe,
      'note': note,
      'mac': mac,
    };
  }
}
