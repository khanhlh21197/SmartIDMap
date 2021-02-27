class ThietBi {
  String matb;
  String makhoa;
  String trangthai;
  String nguong;
  String thoigian;
  String mac;
  String imageUri;

  ThietBi(this.matb, this.makhoa, this.trangthai, this.nguong,
      this.thoigian, this.mac);

  ThietBi.fromJson(Map<String, dynamic> json)
      : matb = json['matb'],
        makhoa = json['makhoa'],
        trangthai = json['trangthai'],
        nguong = json['nguong'],
        thoigian = json['thoigian'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'matb': matb,
        'makhoa': makhoa,
        'trangthai': trangthai,
        'nguong': nguong,
        'thoigian': thoigian,
        'mac': mac,
      };

  @override
  String toString() {
    return '$matb - $makhoa - $nguong - $thoigian';
  }
}
