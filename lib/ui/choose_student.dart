import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/main_screen.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/navigator.dart';
import 'package:smartid_map/response/device_response.dart';
import 'package:smartid_map/ui/choose_student_screen.dart';

class ChooseStudentPage extends StatefulWidget {
  final int quyen;

  const ChooseStudentPage({Key key, this.quyen}) : super(key: key);

  @override
  _ChooseStudentPageState createState() => _ChooseStudentPageState();
}

class _ChooseStudentPageState extends State<ChooseStudentPage> {
  String pubTopic;
  String sdtlx;
  String sdtgs;
  String matx;

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var busID;
  bool isLoading = true;

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    initMqtt();
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleDevice(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
    getStudents();
  }

  void getStudents() async {
    String maph = await sharedPrefsHelper.getStringValuesSF('email');
    Student t = Student('', '', '', '', maph, '', '', Constants.mac);
    pubTopic = Constants.GET_HS_PH;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  void getPhoneNumber(String matx) async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) async {
      try {
        final test = phoneFromJson(message);
        if (test.result == 'false') {
          sdtlx = '';
          sdtgs = '';
        } else {
          sdtlx = test.id.sdtlx;
          sdtgs = test.id.sdtgs;
        }
      } catch (e) {
        print('_ChooseStudentPageState.getPhoneNumber $e');
      } finally {
        await sharedPrefsHelper.addStringToSF('sdtlx', sdtlx);
        await sharedPrefsHelper.addStringToSF('sdtgs', sdtgs);
        hideLoadingDialog();
        navigatorPush(
            context,
            MainScreen(
              quyen: widget.quyen,
            ));
      }
    });
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
    Student t = Student('', '', '', '', '', '', '', Constants.mac);
    t.matx = matx;
    pubTopic = Constants.GET_PHONE;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
  }

  void getBusIdByStudentId(String mahs) {
    Student t = Student(mahs, '', '', '', '', '', '', Constants.mac);
    pubTopic = Constants.GET_BUS_BY_STUDENT_ID;
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Quản lý học sinh'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : buildBody());
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
          buildTextLabel('Tên HS', 4),
          verticalLine(),
          buildTextLabel('Mã HS', 2),
          // verticalLine(),
          // buildTextLabel('Mã tuyến', 2),
        ],
      ),
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

  Widget buildListView() {
    return students.length != 0
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: students.length,
            itemBuilder: (context, index) {
              return itemView(index);
            },
          )
        : Center(child: Text('Không có thông tin'));
  }

  Widget itemView(int index) {
    return InkWell(
      onTap: () async {
        getBusIdByStudentId(students[index].mahs);
        // getPhoneNumber(students[index].matx);
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
                  buildTextData(students[index].tenDecode ?? '', 4),
                  verticalLine(),
                  buildTextData(students[index].mahs ?? '', 2),
                  // verticalLine(),
                  // buildTextData(students[index].matx ?? '', 2),
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
      students.removeAt(index);
    });
  }

  void handleDevice(String message) async {
    switch (pubTopic) {
      case Constants.GET_HS_PH:
        Map responseMap = jsonDecode(message);
        var response = DeviceResponse.fromJson(responseMap);
        students = response.id.map((e) => Student.fromJson(e)).toList();
        setState(() {});
        hideLoadingDialog();
        break;
      case Constants.GET_PHONE:
        final test = phoneFromJson(message);
        sdtlx = test.id.sdtlx;
        sdtgs = test.id.sdtgs;
        await sharedPrefsHelper.addStringToSF('sdtlx', sdtlx);
        await sharedPrefsHelper.addStringToSF('sdtgs', sdtgs);
        hideLoadingDialog();
        navigatorPush(
            context,
            MainScreen(
              quyen: widget.quyen,
            ));
        break;
      case Constants.GET_BUS_BY_STUDENT_ID:
        Map responseMap = jsonDecode(message);
        var response = DeviceResponse.fromJson(responseMap);
        matx = response.id[0]['matx'];
        // hideLoadingDialog();
        getPhoneNumber(matx);
        // navigatorPush(
        //     context,
        //     BusLoadingPage(
        //       matx: matx,
        //       quyen: widget.quyen,
        //     ));
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
