import 'dart:convert';

import 'package:flutter/material.dart';

import '../../helper/models.dart';
import '../../helper/mqttClientWrapper.dart';
import '../../helper/response/device_response.dart';
import '../../model/bus.dart';
import '../../model/student.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;

import '../../model/thietbi.dart';

class StudentBusScreen extends StatefulWidget {
  @override
  _StudentBusScreenState createState() => _StudentBusScreenState();
}

class _StudentBusScreenState extends State<StudentBusScreen> {
  static const GET_STUDENT = 'getHS';
  static const GET_BUS = 'getTuyenxe';
  static const REGISTER_HS_TX = 'registerHSTX';
  static const GET_HS_TX = 'getHSTX';

  MQTTClientWrapper mqttClientWrapper;

  List<Bus> buses = List();
  var dropDownBuses = ['   '];
  var busId;

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var studentId;

  List<HSTX> hstxs = List();

  String pubTopic;
  bool isLoading = true;

  @override
  void initState() {
    initMqtt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Bus'),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: _dropDownBus(),
              ),
              Expanded(
                child: _dropDownStudent(),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    registerHSTX();
                  },
                  child: Text('Thêm'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          buildTableTitle(),
          buildListView(),
        ],
      ),
    );
  }

  void registerHSTX() {
    var hstx = HSTX(Constants.mac, studentId, busId);
    pubTopic = REGISTER_HS_TX;
    publishMessage(pubTopic, jsonEncode(hstx));
    showLoadingDialog();
  }

  Widget buildTableTitle() {
    return Container(
      color: Colors.yellow,
      height: 40,
      child: Row(
        children: [
          buildTextLabel('STT', 1),
          verticalLine(),
          buildTextLabel('Tên HS', 4),
          verticalLine(),
          buildTextLabel('Mã', 2),
          verticalLine(),
          buildTextLabel('Xóa', 1),
        ],
      ),
    );
  }

  Widget buildListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: hstxs.length,
          itemBuilder: (context, index) {
            return itemView(index);
          },
        ),
      ),
    );
  }

  Widget itemView(int index) {
    return InkWell(
      onTap: () async {
        // await showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return Dialog(
        //         shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10.0)),
        //         //this right here
        //         child: Container(
        //           child: EditStudentDialog(
        //             student: students[index],
        //             deleteCallback: (param) {
        //               getStudents();
        //             },
        //             updateCallback: (updatedDevice) {
        //               getStudents();
        //             },
        //           ),
        //         ),
        //       );
        //     });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                children: [
                  buildTextData('${index + 1}', 1),
                  verticalLine(),
                  buildTextData(hstxs[index].tenDecode, 4),
                  verticalLine(),
                  buildTextData(hstxs[index].mahs, 2),
                  verticalLine(),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            horizontalLine(),
          ],
        ),
      ),
    );
  }

  Widget buildTextData(String data, int flexValue) {
    return Expanded(
      child: Text(
        data,
        style: TextStyle(fontSize: 14),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget verticalLine() {
    return Container(
      height: double.infinity,
      width: 1,
      color: Colors.grey,
    );
  }

  Widget horizontalLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey,
    );
  }

  Widget buildTextLabel(String data, int flexValue) {
    return Expanded(
      child: Text(
        data ?? '',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget _dropDownBus() {
    print('_HomePageState._dropDownManage');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Chọn TX",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        DropdownButton<String>(
          value: busId,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.red, fontSize: 18),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String data) {
            setState(() {
              busId = data;
              print(busId);
              getHSTX();
            });
          },
          items: dropDownBuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _dropDownStudent() {
    print('_HomePageState._dropDownManage');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Chọn HS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        DropdownButton<String>(
          value: studentId,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.red, fontSize: 18),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String data) {
            setState(() {
              studentId = data;
              print(studentId);
            });
          },
          items: dropDownStudents.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
      ],
    );
  }

  void getBus() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_BUS;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  void getStudents() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_STUDENT;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  void getHSTX() {
    var hstx = HSTX(Constants.mac, '', busId);
    pubTopic = GET_HS_TX;
    publishMessage(pubTopic, jsonEncode(hstx));
    showLoadingDialog();
  }

  void showLoadingDialog() {
    setState(() {
      isLoading = true;
    });
    // Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    setState(() {
      isLoading = false;
    });
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  Future<void> publishMessage(String topic, String message) async {
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);

    getBus();
    Future.delayed(Duration(seconds: 1), getStudents);
  }

  handle(String message) async {
    DeviceResponse response = DeviceResponse.fromJson(jsonDecode(message));

    print('Response: ${response.id}');

    switch (pubTopic) {
      case GET_BUS:
        buses = response.id.map((e) => Bus.fromJson(e)).toList();
        print('_StudentBusScreenState.handle ${buses.length}');
        dropDownBuses.clear();
        buses.forEach((element) {
          dropDownBuses.add(element.matx);
        });
        setState(() {});
        hideLoadingDialog();
        break;
      case GET_STUDENT:
        students = response.id.map((e) => Student.fromJson(e)).toList();
        dropDownStudents.clear();
        students.forEach((element) {
          dropDownStudents.add(element.mahs);
        });
        print('_StudentBusScreenState.handle ${students.length}');
        setState(() {});
        hideLoadingDialog();
        break;
      case REGISTER_HS_TX:
        if (response.result == 'true') {
          print('Them thanh cong');
        }
        break;
      case GET_HS_TX:
        hstxs = response.id.map((e) => HSTX.fromJson(e)).toList();
        print('_StudentBusScreenState.handle ${hstxs.length}');
        setState(() {});
        break;
    }
    pubTopic = '';
  }
}

class HSTX {
  String mac;
  String mahs;
  String matx;
  String ten;

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

  HSTX(this.mac, this.mahs, this.matx);

  Map<String, dynamic> toJson() => {
        'mac': mac,
        'mahs': mahs,
        'matx': matx,
      };

  HSTX.fromJson(Map<String, dynamic> json)
      : mac = json['mac'],
        mahs = json['mahs'],
        matx = json['matx'],
        ten = json['ten'];
}
