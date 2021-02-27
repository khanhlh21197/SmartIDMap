import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/model/monitor.dart';
import 'package:smartid_map/model/thietbi.dart';
import 'package:smartid_map/response/device_response.dart';

class MonitorListScreen extends StatefulWidget {
  @override
  _MonitorListScreenState createState() => _MonitorListScreenState();
}

class _MonitorListScreenState extends State<MonitorListScreen> {
  static const GET_MONITOR = 'getgiamsat';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<Monitor> monitors = List();
  MQTTClientWrapper mqttClientWrapper;

  String pubTopic;
  int selectedIndex;

  bool isLoading = true;

  @override
  void initState() {
    initMqtt();
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleDevice(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
    getDevices();
  }

  void getDevices() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_MONITOR;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
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

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn thoát ứng dụng ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                // Navigator.of(context).pop(true),
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Danh sách thiết bị'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          buildTableTitle(),
          horizontalLine(),
          buildListView(),
          horizontalLine(),
        ],
      ),
    );
  }

  Widget buildTableTitle() {
    return Container(
      color: Colors.yellow,
      height: 40,
      child: Row(
        children: [
          buildTextLabel('STT', 1),
          verticalLine(),
          buildTextLabel('Mã', 4),
          verticalLine(),
          buildTextLabel('Mã khoa', 2),
          verticalLine(),
          buildTextLabel('Ngưỡng', 2),
        ],
      ),
    );
  }

  Widget buildTextLabel(String data, int flexValue) {
    return Expanded(
      child: Text(
        data,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget buildListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: monitors.length,
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
        // selectedIndex = index;
        // Department d = Department('', '', Constants.mac);
        // pubTopic = GET_DEPARTMENT;
        // publishMessage(pubTopic, jsonEncode(d));
        // showLoadingDialog();
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
                  buildTextData(monitors[index].tenDecode, 4),
                  verticalLine(),
                  buildTextData(monitors[index].sdt, 2),
                  verticalLine(),
                  buildTextData('${monitors[index].nhaDecode}', 2),
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
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget buildStatusDevice(bool data, int flexValue) {
    return Expanded(
      child: data
          ? Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            )
          : Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
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

  void removeDevice(int index) async {
    setState(() {
      monitors.removeAt(index);
    });
  }

  void handleDevice(String message) async {
    Map responseMap = jsonDecode(message);
    var response = DeviceResponse.fromJson(responseMap);

    switch (pubTopic) {
      case GET_MONITOR:
        monitors = response.id.map((e) => Monitor.fromJson(e)).toList();
        setState(() {});
        hideLoadingDialog();
        break;
    }
    pubTopic = '';
  }

  @override
  void dispose() {
    super.dispose();
  }
}
