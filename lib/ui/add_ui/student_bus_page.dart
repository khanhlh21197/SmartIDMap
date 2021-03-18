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

  MQTTClientWrapper mqttClientWrapper;

  List<Bus> buses = List();
  var dropDownBuses = ['   '];
  var busId;

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var studentId;

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
      child: Row(
        children: [
          Expanded(
            child: _dropDownBus(),
          ),
          Expanded(
            child: _dropDownStudent(),
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {},
              child: Text('Đồng ý'),
            ),
          ),
        ],
      ),
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
            });
          },
          items: dropDownBuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Flexible(child: Text(value)),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _dropDownBus() {
    print('_HomePageState._dropDownManage');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Chọn Tuyến xe",
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
              child: Flexible(child: Text(value)),
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
    }
    pubTopic = '';
  }
}
