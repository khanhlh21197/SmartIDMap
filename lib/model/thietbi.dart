class ThietBi {
  String mathietbi;
  String makhoa;
  String trangthai;
  String nguong;
  String thoigian;
  String mac;
  String imageUri;

  ThietBi(this.mathietbi, this.makhoa, this.trangthai, this.nguong,
      this.thoigian, this.mac);

  ThietBi.fromJson(Map<String, dynamic> json)
      : mathietbi = json['mathietbi'],
        makhoa = json['makhoa'],
        trangthai = json['trangthai'],
        nguong = json['nguong'],
        thoigian = json['thoigian'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'mathietbi': mathietbi,
        'makhoa': makhoa,
        'trangthai': trangthai,
        'nguong': nguong,
        'thoigian': thoigian,
        'mac': mac,
      };

  @override
  String toString() {
    return '$mathietbi - $makhoa - $nguong - $thoigian';
  }
}
