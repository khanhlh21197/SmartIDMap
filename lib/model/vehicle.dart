class Vehicle {
  String maxe;
  String loaixe;
  String malx;
  String mags;
  String matb;
  String bienso;
  String mac;

  Vehicle(this.maxe, this.loaixe, this.malx, this.mags, this.matb, this.bienso,
      this.mac);

  Vehicle.fromJson(Map<String, dynamic> json)
      : maxe = json['maxe'],
        loaixe = json['loaixe'],
        malx = json['malx'],
        mags = json['mags'],
        matb = json['matb'],
        bienso = json['bienso'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'maxe': maxe,
        'loaixe': loaixe,
        'malx': malx,
        'mags': mags,
        'matb': matb,
        'bienso': bienso,
        'mac': mac,
      };
}
