import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/model/thietbi.dart';
import 'package:smartid_map/model/user.dart';
import 'package:smartid_map/response/device_response.dart';

class EditParentDialog extends StatefulWidget {
  final User parent;
  final Function(dynamic) updateCallback;
  final Function(dynamic) deleteCallback;

  const EditParentDialog(
      {Key key, this.parent, this.updateCallback, this.deleteCallback})
      : super(key: key);

  @override
  _EditParentDialogState createState() => _EditParentDialogState();
}

class _EditParentDialogState extends State<EditParentDialog> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final scrollController = ScrollController();
  final studentNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final parentIdController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  String pubTopic = '';
  String currentSelectedValue;
  Student updatedStudent;

  List<User> parents = List();
  var dropDownParents = ['   '];
  var parentID;

  @override
  void initState() {
    initMqtt();
    initController();
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    if (responseMap['result'] == 'true' && responseMap['errorCode'] == '0') {
      switch (pubTopic) {
        case Constants.UPDATE_STUDENT:
          widget.updateCallback(updatedStudent);
          Navigator.of(context).pop();
          break;
        case Constants.DELETE_STUDENT:
          widget.deleteCallback('true');
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          break;
        case Constants.GET_PARENT:
          DeviceResponse response =
              DeviceResponse.fromJson(jsonDecode(message));
          parents = response.id.map((e) => User.fromJson(e)).toList();
          dropDownParents.clear();
          parents.forEach((element) {
            dropDownParents.add(element.maph);
          });
          setState(() {});
          break;
      }
    }
  }

  void initController() async {
    studentNameController.text = widget.parent.tenDecode;
    // studentIdController.text = widget.parent.mahs;
    parentIdController.text = widget.parent.maph;
    phoneNumberController.text = widget.parent.sdt;
    addressController.text = widget.parent.nhaDecode;
  }

  @override
  Widget build(BuildContext context) {
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
                buildTextField(
                  'Mã PH/ username',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  parentIdController,
                ),
                buildTextField(
                  'Tên phụ huynh',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  studentNameController,
                ),
                buildTextField(
                  'SĐT',
                  Icon(Icons.vpn_key),
                  TextInputType.number,
                  phoneNumberController,
                ),
                buildTextField(
                  'Địa chỉ',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  addressController,
                ),
                deleteButton(),
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

  Widget deleteButton() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 86,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(1.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: new Text(
                'Xóa ?',
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => {
                    Navigator.of(context).pop(),
                  },
                  child: new Text(
                    'Hủy',
                  ),
                ),
                new FlatButton(
                  onPressed: () {
                    // pubTopic = Constants.DELETE_STUDENT;
                    // var s = Student(widget.parent.mahs, '', '', '', '', '', '',
                    //     Constants.mac);
                    // publishMessage(pubTopic, jsonEncode(s));
                  },
                  child: new Text(
                    'Đồng ý',
                  ),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
            Text(
              'Xóa',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
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
                widget.updateCallback('abc');
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                _tryEdit();
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropDownParent() {
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
              "Chọn PH",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: parentID,
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
                  parentID = data;
                  print(parentID);
                });
              },
              items:
                  dropDownParents.map<DropdownMenuItem<String>>((String value) {
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

  void getParent() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = Constants.GET_PARENT;
    publishMessage(pubTopic, jsonEncode(t));
  }

  Future<void> _tryEdit() async {
    updatedStudent = Student(
        studentIdController.text,
        utf8.encode(studentNameController.text).toString(),
        phoneNumberController.text,
        utf8.encode(addressController.text).toString(),
        parentID,
        '',
        '',
        Constants.mac);
    pubTopic = Constants.UPDATE_STUDENT;
    publishMessage(pubTopic, jsonEncode(updatedStudent));
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
    studentNameController.dispose();
    studentIdController.dispose();
    parentIdController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
