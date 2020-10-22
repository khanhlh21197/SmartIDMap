class Lenh {
  String lenh;
  String param;
  String iduser;

  Lenh(this.lenh, this.param, this.iduser);

  Lenh.fromJson(Map<String, dynamic> json)
      : lenh = json['lenh'],
        param = json['param'],
        iduser = json['iduser'];

  Map<String, dynamic> toJson() =>
      {'lenh': lenh, 'param': param, 'iduser': iduser};
}
