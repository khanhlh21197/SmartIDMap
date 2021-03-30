import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/response/device_response.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/model/thietbi.dart';

import 'helper/mqttClientWrapper.dart';
import 'helper/shared_prefs_helper.dart';
import 'map_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  HomePage({Key key, this.loginResponse}) : super(key: key);

  final Map loginResponse;

  @override
  _HomePageState createState() => _HomePageState(loginResponse);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  _HomePageState(this.loginResponse);

  static const GET_STUDENT = 'getHSPH';
  final Map loginResponse;
  String iduser;
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  double lat;
  double lon;
  String pubTopic;
  bool isLoading = true;
  List<Student> students = List();
  String manageValue = 'Chọn';
  List<String> manageValues = [
    'Chọn',
  ];

  @override
  void initState() {
    super.initState();
    initMqtt();
    sharedPrefsHelper = SharedPrefsHelper();
    WidgetsBinding.instance.addObserver(this);
    getStudents();
  }

  void getStudents() async {
    String maph = await sharedPrefsHelper.getStringValuesSF('email');
    Student t = Student('', '', '', '', maph, Constants.mac);
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed) {
        print('HomePageLifeCycleState : $state');
        initMqtt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Home Page';

    return MaterialApp(
      title: 'Geolocation Google Maps Demo',
      home: Stack(
        children: [
          _dropDownStudent(),
          MapView(),
        ],
      ),
    );
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    var response = DeviceResponse.fromJson(responseMap);

    switch (pubTopic) {
      case GET_STUDENT:
        students = response.id.map((e) => Student.fromJson(e)).toList();
        students.forEach((element) {
          manageValues.add(element.tenDecode);
        });
        setState(() {});
        hideLoadingDialog();
        break;
    }
    pubTopic = '';
  }

  Widget _dropDownStudent() {
    print('_HomePageState._dropDownManage');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Chọn HS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          DropdownButton<String>(
            value: manageValue,
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
                manageValue = data;
                print(manageValue);
                if (manageValue == manageValues[0]) {}
                if (manageValue == manageValues[1]) {}
                if (manageValue == manageValues[2]) {}
                if (manageValue == manageValues[3]) {}
              });
            },
            items: manageValues.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
