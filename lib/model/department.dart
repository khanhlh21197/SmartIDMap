import 'dart:convert';

import 'package:floor/floor.dart';

@entity
class Department {
  @primaryKey
  @ColumnInfo(name: 'tenkhoa', nullable: false)
  final String tenkhoa;
  @ColumnInfo(name: 'makhoa', nullable: false)
  final String makhoa;
  @ColumnInfo(name: 'mac', nullable: false)
  String mac;

  Department(this.tenkhoa, this.makhoa, this.mac);

  String get departmentNameDecode {
    try {
      String s = tenkhoa;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return tenkhoa;
    }
  }

  Department.fromJson(Map<String, dynamic> json)
      : tenkhoa = json['tenkhoa'],
        makhoa = json['makhoa'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'tenkhoa': tenkhoa,
        'makhoa': makhoa,
        'mac': mac,
      };
// Room.fromJson(Map<String, dynamic> json)
//     : email = json['email'],
//       pass = json['pass'],
//       ten = json['ten'],
//       sdt = json['sdt'],
//       nha = json['nha'],
//       mac = json['mac'];
//
// Map<String, dynamic> toJson() => {
//   'email': email,
//   'pass': pass,
//   'ten': ten,
//   'sdt': sdt,
//   'nha': nha,
//   'mac': mac,
// };
}
