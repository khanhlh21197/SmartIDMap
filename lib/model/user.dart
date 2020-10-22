import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final String email;
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

  User(this.mac, this.email, this.pass, this.ten, this.sdt, this.nha);

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        pass = json['pass'],
        ten = json['ten'],
        sdt = json['sdt'],
        nha = json['nha'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'pass': pass,
        'ten': ten,
        'sdt': sdt,
        'nha': nha,
        'mac': mac,
      };
}
