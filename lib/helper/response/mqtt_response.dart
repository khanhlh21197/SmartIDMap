class MqttResponse {
  String errorCode;
  String message;
  Id id;
  String result;

  MqttResponse({this.errorCode, this.message, this.id, this.result});

  MqttResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    message = json['message'];
    id = json['id'] != null ? new Id.fromJson(json['id']) : null;
    result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errorCode'] = this.errorCode;
    data['message'] = this.message;
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    data['result'] = this.result;
    return data;
  }
}

class Id {
  List<Maxe> maxe;
  List<Malx> malx;
  List<Mags> mags;
  List<Matb> matb;

  Id({this.maxe, this.malx, this.mags, this.matb});

  Id.fromJson(Map<String, dynamic> json) {
    if (json['maxe'] != null) {
      maxe = new List<Maxe>();
      json['maxe'].forEach((v) {
        maxe.add(new Maxe.fromJson(v));
      });
    }
    if (json['malx'] != null) {
      malx = new List<Malx>();
      json['malx'].forEach((v) {
        malx.add(new Malx.fromJson(v));
      });
    }
    if (json['mags'] != null) {
      mags = new List<Mags>();
      json['mags'].forEach((v) {
        mags.add(new Mags.fromJson(v));
      });
    }
    if (json['matb'] != null) {
      matb = new List<Matb>();
      json['matb'].forEach((v) {
        matb.add(new Matb.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.maxe != null) {
      data['maxe'] = this.maxe.map((v) => v.toJson()).toList();
    }
    if (this.malx != null) {
      data['malx'] = this.malx.map((v) => v.toJson()).toList();
    }
    if (this.mags != null) {
      data['mags'] = this.mags.map((v) => v.toJson()).toList();
    }
    if (this.matb != null) {
      data['matb'] = this.matb.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Maxe {
  String maxe;

  Maxe({this.maxe});

  Maxe.fromJson(Map<String, dynamic> json) {
    maxe = json['maxe'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['maxe'] = this.maxe;
    return data;
  }
}

class Malx {
  String malx;

  Malx({this.malx});

  Malx.fromJson(Map<String, dynamic> json) {
    malx = json['malx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['malx'] = this.malx;
    return data;
  }
}

class Mags {
  String mags;

  Mags({this.mags});

  Mags.fromJson(Map<String, dynamic> json) {
    mags = json['mags'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mags'] = this.mags;
    return data;
  }
}

class Matb {
  String matb;

  Matb({this.matb});

  Matb.fromJson(Map<String, dynamic> json) {
    matb = json['matb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['matb'] = this.matb;
    return data;
  }
}