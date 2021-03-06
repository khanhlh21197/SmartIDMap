import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/navigator.dart';
import 'package:smartid_map/signup.dart';
import 'package:smartid_map/ui/add_ui/add_bus_page.dart';
import 'package:smartid_map/ui/add_ui/add_class_page.dart';
import 'package:smartid_map/ui/add_ui/add_device_page.dart';
import 'package:smartid_map/ui/add_ui/add_driver_page.dart';
import 'package:smartid_map/ui/add_ui/add_monitor_page.dart';
import 'package:smartid_map/ui/add_ui/add_student_page.dart';
import 'package:smartid_map/ui/add_ui/add_vehicle.dart';
import 'package:smartid_map/ui/add_ui/student_bus_page.dart';
import 'package:smartid_map/ui/add_ui/student_parent_page.dart';

class AddScreen extends StatefulWidget {
  final String quyen;

  const AddScreen({Key key, this.quyen}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  bool isLoading = false;

  @override
  void initState() {
    // showLoadingDialog();
    initMqtt();
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading ? Center(child: CircularProgressIndicator()) : buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildButton('Lái xe', Icons.add, 0),
            horizontalLine(),
            buildButton('Giám sát', Icons.add, 1),
            horizontalLine(),
            buildButton('Xe', Icons.add, 2),
            horizontalLine(),
            buildButton('Thiết bị', Icons.add, 3),
            horizontalLine(),
            buildButton('Học sinh', Icons.add, 5),
            horizontalLine(),
            buildButton('Tuyến xe', Icons.add, 4),
            horizontalLine(),
            buildButton('Phụ huynh', Icons.add, 7),
            horizontalLine(),
            buildButton('HS - TX', Icons.add, 6),
            horizontalLine(),
            buildButton('HS - PH', Icons.add, 9),
            horizontalLine(),
            buildButton('Lớp', Icons.add, 8),
          ],
        ),
      ),
    );
  }

  Widget horizontalLine() {
    return Container(height: 1, width: double.infinity, color: Colors.grey);
  }

  Widget buildButton(String text, IconData icon, int option) {
    return GestureDetector(
      onTap: () {
        switch (option) {
          case 0:
            navigatorPush(context, AddDriverScreen());
            break;
          case 1:
            navigatorPush(context, AddMonitorScreen());
            break;
          case 2:
            navigatorPush(context, AddVehihcleScreen());
            break;
          case 3:
            navigatorPush(context, AddDeviceScreen());
            break;
          case 4:
            navigatorPush(context, AddBusScreen());
            break;
          case 5:
            navigatorPush(
                context,
                AddStudentScreen(
                  isParent: false,
                ));
            break;
          case 6:
            navigatorPush(context, StudentBusScreen());
            break;
          case 7:
            navigatorPush(
                context,
                SignUpPage(
                  title: 'Đăng ký phụ huynh',
                  isAdmin: false,
                ));
            break;
          case 8:
            navigatorPush(context, AddClassScreen());
            break;
          case 9:
            navigatorPush(context, StudentParentScreen());
            break;
        }
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          // borderRadius: BorderRadius.circular(
          //   10,
          // ),
          // border: Border.all(
          //   color: Colors.grey,
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.transparent,
          //     offset: Offset(0.0, 0.1), //(x,y)
          //     blurRadius: 6.0,
          //   )
          // ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(
              icon,
              size: 25,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    hideLoadingDialog();
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

  void showPopup(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.transparent,
              content: Text(
                'Chưa có khoa',
              ),
            ));
  }
}
