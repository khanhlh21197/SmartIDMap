import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/loader.dart';
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/class.dart';
import 'package:smartid_map/model/thietbi.dart';

class AddClassScreen extends StatefulWidget {
  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  static const REGISTER_CLASS = 'registerlop';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  final scrollController = ScrollController();
  final classController = TextEditingController();
  final idController = TextEditingController();
  var _descriptionController = TextEditingController();

  String currentSelectedValue;
  String pubTopic = '';

  var dropDownGrades = ['   '];
  var _grade;

  @override
  void initState() {
    initMqtt();
    getGrades();
    super.initState();
  }

  void getGrades() async {
    var grades = await DefaultAssetBundle.of(context)
        .loadString('assets/json/grade.json');
    dropDownGrades = gradeFromJson(grades);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm lớp',
        ),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: scrollController,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dropDownGrade(),
                buildTextField(
                  'Lớp',
                  Icon(Icons.class_),
                  TextInputType.text,
                  classController,
                ),
                // buildTextField(
                //   'Khu vực',
                //   Icon(Icons.vpn_key),
                //   TextInputType.visiblePassword,
                //   idController,
                // ),
                // buildDescriptionContainer(
                //   'Mô tả',
                //   Icon(Icons.description),
                //   TextInputType.text,
                //   _descriptionController,
                // ),
                buildButton(),
              ],
            ),
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

  Widget idDeviceContainer(String labelText, Icon prefixIcon,
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
          suffixIcon: IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () async {
              String cameraScanResult = await scanner.scan();
              controller.text = cameraScanResult;
            },
          ),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Widget buildDescriptionContainer(String labelText, Icon prefixIcon,
      TextInputType keyboardType, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        maxLines: 4,
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        enabled: labelText == 'Mã' ? false : true,
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

  Widget _dropDownGrade() {
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
          Expanded(
            child: Text(
              "Khối",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: _grade,
              isExpanded: true,
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
                  _grade = data;
                  print(_grade);
                });
              },
              items:
                  dropDownGrades.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value ?? ''),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget buildButton() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 32,
      ),
      child: Row(
        children: [
          Expanded(
            child: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                if (classController.text.isEmpty) {
                  return;
                }
                Class c = Class(
                  _grade,
                  classController.text,
                  Constants.mac,
                );
                pubTopic = REGISTER_CLASS;
                publishMessage(pubTopic, jsonEncode(c));
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  void showLoadingDialog() {
    Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    if (responseMap['result'] == 'true' && responseMap['errorCode'] == '0') {
      Navigator.pop(context);
    }
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

  @override
  void dispose() {
    scrollController.dispose();
    classController.dispose();
    idController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
