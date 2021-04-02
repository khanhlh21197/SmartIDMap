import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/response/device_response.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/main_screen.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/navigator.dart';

class ChooseStudentScreen extends StatefulWidget {
  final int quyen;

  const ChooseStudentScreen({Key key, this.quyen}) : super(key: key);

  @override
  _ChooseStudentScreenState createState() => _ChooseStudentScreenState();
}

class _ChooseStudentScreenState extends State<ChooseStudentScreen> {
  final TextEditingController _serverUriController = TextEditingController();

  bool isDefault = true;
  SharedPrefsHelper sharedPrefsHelper;
  MQTTClientWrapper mqttClientWrapper;
  static const GET_STUDENT = 'getHSPH';
  static const GET_PHONE = 'getdienthoai';

  String pubTopic;
  String sdtlx;
  String sdtgs;

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var busID;
  bool isLoading = true;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    initMqtt();
    getStudents();
    super.initState();
  }

  void getStudents() async {
    String maph = await sharedPrefsHelper.getStringValuesSF('email');
    Student t = Student('', '', '', '', maph, '', '', Constants.mac);
    pubTopic = GET_STUDENT;
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

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  void dispose() {
    _serverUriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dropDownStudent(),
              SizedBox(height: 10),
              ClipOval(
                child: Material(
                  color: Colors.blue, // button color
                  child: InkWell(
                    splashColor: Colors.red, // inkwell color
                    child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.navigate_next)),
                    onTap: () async {
                      await sharedPrefsHelper.addStringToSF('sdtlx', sdtlx);
                      await sharedPrefsHelper.addStringToSF('sdtgs', sdtgs);
                      navigatorPush(
                          context,
                          MainScreen(
                            quyen: widget.quyen,
                          ));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, Icon prefixIcon,
      TextInputType keyboardType, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: labelText,
          // labelStyle: ,
          // hintStyle: ,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          // suffixIcon: Icon(Icons.account_balance_outlined),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  void getPhoneNumber(String matx) {
    Student t = Student('', '', '', '', '', '', '', Constants.mac);
    t.matx = matx;
    pubTopic = GET_PHONE;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  Widget _dropDownStudent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              "Chọn học sinh",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: busID,
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
                  busID = data;
                  print(busID);
                  getPhoneNumber(
                      students[dropDownStudents.indexOf(busID)].matx);
                });
              },
              items: dropDownStudents
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  void handle(String message) {
    switch (pubTopic) {
      case GET_STUDENT:
        Map responseMap = jsonDecode(message);
        var response = DeviceResponse.fromJson(responseMap);
        students = response.id.map((e) => Student.fromJson(e)).toList();
        dropDownStudents.clear();
        students.forEach((element) {
          if (!dropDownStudents.contains(element.tenDecode)) {
            dropDownStudents.add(element.tenDecode);
          }
        });
        setState(() {});
        break;
      case GET_PHONE:
        final test = testFromJson(message);
        sdtlx = test.id.sdtlx;
        sdtgs = test.id.sdtgs;
        hideLoadingDialog();
        break;
    }
    pubTopic = '';
  }
}

// To parse this JSON data, do
//
//     final test = testFromJson(jsonString);

Test testFromJson(String str) => Test.fromJson(json.decode(str));

String testToJson(Test data) => json.encode(data.toJson());

class Test {
  Test({
    this.errorCode,
    this.message,
    this.id,
    this.result,
  });

  String errorCode;
  String message;
  Id id;
  String result;

  factory Test.fromJson(Map<String, dynamic> json) => Test(
        errorCode: json["errorCode"],
        message: json["message"],
        id: Id.fromJson(json["id"]),
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "errorCode": errorCode,
        "message": message,
        "id": id.toJson(),
        "result": result,
      };
}

class Id {
  Id({
    this.sdtlx,
    this.sdtgs,
  });

  String sdtlx;
  String sdtgs;

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        sdtlx: json["sdtlx"],
        sdtgs: json["sdtgs"],
      );

  Map<String, dynamic> toJson() => {
        "sdtlx": sdtlx,
        "sdtgs": sdtgs,
      };
}
