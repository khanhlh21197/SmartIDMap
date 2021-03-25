import 'dart:convert';

import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final String user;
  @ColumnInfo(name: 'pass', nullable: false)
  final String pass;
  @ColumnInfo(name: 'ten', nullable: false)
  final String ten;
  @ColumnInfo(name: 'sdt', nullable: false)
  final String sdt;
  @ColumnInfo(name: 'nha', nullable: false)
  final String nha;
  @ColumnInfo(name: 'mac', nullable: false)
  final String mac;
  @ColumnInfo(name: 'khoa', nullable: false)
  final String khoa;
  @ColumnInfo(name: 'quyen', nullable: false)
  final String quyen;
  @ColumnInfo(name: 'playerid', nullable: false)
  final String playerid;
  @ColumnInfo(name: 'iduser', nullable: false)
  String iduser;
  String _id;
  String thongbao;
  String trangthai;
  String passmoi;
  String maph;

  User(this.mac, this.user, this.pass, this.ten, this.sdt, this.nha, this.khoa,
      this.quyen, this.playerid,
      {this.maph});

  String toString() => '$user - $ten - $sdt - $nha';

  User.fromJson(Map<String, dynamic> json)
      : user = json['user'],
        pass = json['pass'],
        ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        mac = json['mac'],
        iduser = json['iduser'],
        _id = json['_id'],
        khoa = json['khoa'],
        quyen = json['quyen'],
        playerid = json['playerid'],
        thongbao = json['thongbao'],
        trangthai = json['trangthai'],
        maph = json['maph'];

  Map<String, dynamic> toJson() => {
        'user': user,
        'pass': pass,
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mac': mac,
        'iduser': iduser,
        '_id': _id,
        'khoa': khoa,
        'quyen': quyen,
        'playerid': playerid,
        'thongbao': thongbao,
        'trangthai': trangthai,
        'passmoi': passmoi,
        'maph': maph,
      };

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
}
