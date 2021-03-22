class Vehicle {
  String maxe;
  String loaixe;
  String bienso;
  String mac;

  Vehicle(this.maxe, this.loaixe, this.bienso, this.mac);

  Vehicle.fromJson(Map<String, dynamic> json)
      : maxe = json['maxe'],
        loaixe = json['loaixe'],
        bienso = json['bienso'],
        mac = json['mac'];

  Map<String, dynamic> toJson() => {
        'maxe': maxe,
        'loaixe': loaixe,
        'bienso': bienso,
        'mac': mac,
      };
}
