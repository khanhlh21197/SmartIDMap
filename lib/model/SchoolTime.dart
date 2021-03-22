class SchoolTime {
  String gio;
  String phut;
  String ngay;
  String thang;
  String nam;
  String mac;

  SchoolTime(this.gio, this.phut, this.ngay, this.thang, this.nam, this.mac);

  Map<String, dynamic> toJson() {
    return {
      'gio': gio,
      'phut': phut,
      'ngay': ngay,
      'thang': thang,
      'nam': nam,
      'mac': mac,
    };
  }

  SchoolTime.fromJson(Map<String, dynamic> json)
      : gio = json['gio'],
        phut = json['phut'],
        ngay = json['ngay'],
        thang = json['thang'],
        nam = json['nam'],
        mac = json['mac'];
}
