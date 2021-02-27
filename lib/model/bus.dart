import 'dart:convert';

class Bus {
  String matx;
  String tentx;
  String maxe;
  String ghichu;

  Bus(this.matx, this.tentx, this.maxe, this.ghichu);

  String get tenDecode {
    try {
      String s = tentx;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return tentx;
    }
  }

  String get ghichuDecode {
    try {
      String s = ghichu;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return ghichu;
    }
  }
}
