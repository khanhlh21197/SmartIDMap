import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/main_screen.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/navigator.dart';
import 'package:smartid_map/ui/choose_student_screen.dart';

class BusLoadingPage extends StatefulWidget {
  final String matx;
  final int quyen;

  const BusLoadingPage({Key key, this.matx, this.quyen}) : super(key: key);

  @override
  _BusLoadingPageState createState() => _BusLoadingPageState();
}

class _BusLoadingPageState extends State<BusLoadingPage> {
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  String pubTopic;
  String sdtlx;
  String sdtgs;
  List<Student> students = List();
  bool isLoading = true;

  @override
  void initState() {
    initMqtt();
    super.initState();
  }

  void getPhoneNumber(String matx) {
    Student t = Student('', '', '', '', '', '', '', Constants.mac);
    t.matx = matx;
    pubTopic = Constants.GET_PHONE;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
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
    sharedPrefsHelper = SharedPrefsHelper();
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleDevice(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);

    getPhoneNumber(widget.matx);
  }

  void handleDevice(String message) async {
    switch (pubTopic) {
      case Constants.GET_PHONE:
        final test = phoneFromJson(message);
        sdtlx = test.id.sdtlx;
        sdtgs = test.id.sdtgs;
        await sharedPrefsHelper.addStringToSF('sdtlx', sdtlx);
        await sharedPrefsHelper.addStringToSF('sdtgs', sdtgs);
        // hideLoadingDialog();
        navigatorPush(
            context,
            MainScreen(
              quyen: widget.quyen,
            ));
        break;
    }
    pubTopic = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: 200,
        height: 200,
        decoration: new BoxDecoration(
          // shape: BoxShape.circle,
          color: const Color(0xFF0E3311).withOpacity(0.5),
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
