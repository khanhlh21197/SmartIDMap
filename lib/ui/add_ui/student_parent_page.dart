import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/model/class.dart';
import 'package:smartid_map/model/user.dart';

import '../../helper/models.dart';
import '../../helper/mqttClientWrapper.dart';
import '../../helper/response/device_response.dart';
import '../../model/student.dart';
import '../../model/thietbi.dart';

class StudentParentScreen extends StatefulWidget {
  @override
  _StudentParentScreenState createState() => _StudentParentScreenState();
}

class _StudentParentScreenState extends State<StudentParentScreen> {
  MQTTClientWrapper mqttClientWrapper;

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var studentId;

  List<User> parents = List();
  var dropDownParents = ['   '];
  var parentID;

  List<HSPH> hsphs = List();
  List<String> studentParentOldIds = List();
  List<String> addSttudentIds = List();
  List<String> removeStudentIds = List();

  String pubTopic;
  String tableTitle = 'Danh sách học sinh theo phụ huynh';
  bool isLoading = true;

  List<Class> classes = List();

  var dropDownGrades = ['   '];
  var dropDownClasses = ['   '];
  var _grade;
  var _class;

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
        title: Text('TX - HS'),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          _dropDownParent(),
          chooseClassContainer(),
          // FlatButton(
          //   onPressed: () {
          //     registerHSTX();
          //   },
          //   child: Text('Thêm'),
          //   color: Colors.blue,
          // ),
          SizedBox(height: 10),
          Text(
            tableTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          buildTableTitle(),
          buildListView(),
          buildButton(),
          testText(),
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
                var updateHSPH = HSPH(Constants.mac, '', '', parentID);
                updateHSPH.themhs = addSttudentIds;
                updateHSPH.xoahs = removeStudentIds;
                pubTopic = Constants.UPDATE_HS_PH;
                publishMessage(pubTopic, jsonEncode(updateHSPH));
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget testText() {
    return Container(
      child: Column(
        children: [
          Text('Thêm: $addSttudentIds'),
          Text('Xóa: $removeStudentIds'),
        ],
      ),
    );
  }

  void registerHSTX() {
    var hstx = HSPH(Constants.mac, studentId, '', parentID);
    pubTopic = Constants.REGISTER_HS_TX;
    publishMessage(pubTopic, jsonEncode(hstx));
    showLoadingDialog();
  }

  Widget buildTableTitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          buildTextLabel('Chọn', 1),
        ],
      ),
    );
  }

  void getStudents() async {
    Student s = Student('', '', '', '', '', _class, _grade, Constants.mac);
    pubTopic = Constants.GET_STUDENT;
    publishMessage(pubTopic, jsonEncode(s));
    showLoadingDialog();
  }

  void getStudentsByClass() async {
    Student s = Student('', '', '', '', '', _class, _grade, Constants.mac);
    pubTopic = Constants.GET_STUDENT_BY_CLASS;
    publishMessage(pubTopic, jsonEncode(s));
    showLoadingDialog();
  }

  Widget buildListView() {
    List<dynamic> displayList = List();
    switch (pubTopic) {
      case Constants.GET_STUDENT:
      case Constants.GET_STUDENT_BY_CLASS:
        displayList = students;
        break;
      case Constants.GET_HS_PH:
        displayList = hsphs;
        break;
    }
    return displayList.length != 0
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  return itemView(index, displayList);
                },
              ),
            ),
          )
        : Center(
            child: Text(
            'Không có dữ liệu',
            style: TextStyle(fontSize: 22),
          ));
  }

  Widget itemView(int index, List<dynamic> displayList) {
    displayList.forEach((element) {
      if (addSttudentIds.contains(element.mahs)) {
        element.isSelected = true;
      }
    });
    return InkWell(
      onTap: () async {},
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
                  buildTextData(displayList[index].tenDecode ?? '', 4),
                  verticalLine(),
                  buildTextData(displayList[index].mahs, 2),
                  verticalLine(),
                  Expanded(
                    flex: 1,
                    child: Checkbox(
                        value: displayList[index].isSelected,
                        onChanged: (_value) {
                          displayList[index].isSelected =
                              !displayList[index].isSelected;
                          if (displayList[index].isSelected) {
                            if (!studentParentOldIds
                                .contains(displayList[index].mahs)) {
                              addSttudentIds.add(displayList[index].mahs);
                            }
                            removeStudentIds.remove(displayList[index].mahs);
                          }
                          if (!displayList[index].isSelected) {
                            if (studentParentOldIds
                                .contains(displayList[index].mahs)) {
                              removeStudentIds.add(displayList[index].mahs);
                            }
                            addSttudentIds.remove(displayList[index].mahs);
                          }
                          print(
                              '_StudentBusScreenState.itemView $studentParentOldIds');
                          print(
                              '_StudentBusScreenState.itemView $removeStudentIds');
                          setState(() {});
                        }),
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
          Expanded(
            child: Text(
              "HS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: studentId,
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
                  studentId = data;
                  print(studentId);
                });
              },
              items: dropDownStudents
                  .map<DropdownMenuItem<String>>((String value) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              'Chọn Phụ huynh',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: parentID,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.red, fontSize: 18),
              underline: Container(
                  // height: 2,
                  // color: Colors.deepPurpleAccent,
                  ),
              onChanged: (String data) {
                setState(() {
                  parentID = data;
                  print(parentID);
                  _grade = null;
                  _class = null;
                  removeStudentIds.clear();
                  studentParentOldIds.clear();
                  // getAvaiableStudents();
                  // Future.delayed(Duration(milliseconds: 500), getHSTX);
                  getHSPH();
                });
              },
              items:
                  dropDownParents.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value ?? '')),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget chooseClassContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: _dropDownGrade(),
          ),
          Expanded(
            child: _dropDownClass(),
          ),
        ],
      ),
    );
  }

  Widget _dropDownGrade() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                "Khối",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
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
              underline: Container(),
              onChanged: (String data) {
                setState(() {
                  _grade = data;
                  print(_grade);
                  _class = null;
                  getClasses(_grade);
                });
              },
              items:
                  dropDownGrades.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value ?? '')),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  void getClasses(String grade) {
    Class c = Class(grade, '', Constants.mac);
    pubTopic = Constants.GET_CLASS_BY_GRADE;
    publishMessage(pubTopic, jsonEncode(c));
  }

  Widget _dropDownClass() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                "Lớp",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: _class,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.red, fontSize: 18),
              underline: Container(),
              onChanged: (String data) {
                setState(() {
                  _class = data;
                  print(_class);
                  getStudentsByClass();
                });
              },
              items:
                  dropDownClasses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value ?? '')),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  void getBus() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = Constants.GET_BUS;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  void getParent() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = Constants.GET_PARENT;
    publishMessage(pubTopic, jsonEncode(t));
  }

  void getAvaiableStudents() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = Constants.GET_STUDENT_BY_BUS_ID;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  void getHSPH() {
    var hstx = HSPH(Constants.mac, '', '', parentID);
    pubTopic = Constants.GET_HS_PH;
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
    getParent();
    // Future.delayed(Duration(milliseconds: 500), getParent);
  }

  handle(String message) async {
    DeviceResponse response = DeviceResponse.fromJson(jsonDecode(message));

    print('Response: ${response.id}');

    switch (pubTopic) {
      case Constants.GET_STUDENT:
      case Constants.GET_STUDENT_BY_CLASS:
        tableTitle = 'Chỉnh sửa danh sách';
        students = response.id.map((e) => Student.fromJson(e)).toList();
        students.forEach((element) {
          if (studentParentOldIds.contains(element.mahs)) {
            element.isSelected = true;
          }
        });
        setState(() {});
        hideLoadingDialog();
        break;
      case Constants.REGISTER_HS_TX:
        if (response.result == 'true') {
          print('Them thanh cong');
        }
        break;
      case Constants.GET_HS_PH:
        tableTitle = 'Danh sách học sinh theo phụ huynh';
        hsphs = response.id.map((e) => HSPH.fromJson(e)).toList();
        studentParentOldIds.clear();
        hsphs.forEach((element) {
          element.isSelected = true;
          if (!studentParentOldIds.contains(element.mahs)) {
            studentParentOldIds.add(element.mahs);
          }
        });
        setState(() {});
        break;
      case Constants.GET_PARENT:
        parents = response.id.map((e) => User.fromJson(e)).toList();
        dropDownParents.clear();
        parents.forEach((element) {
          dropDownParents.add(element.maph);
        });
        setState(() {});
        break;
      case Constants.GET_CLASS_BY_GRADE:
        classes = response.id.map((e) => Class.fromJson(e)).toList();
        dropDownClasses.clear();
        getStudentsByClass();
        classes.forEach((element) {
          dropDownClasses.add(element.lop);
        });
        setState(() {});
        hideLoadingDialog();
        break;
    }
  }
}

class HSPH {
  String mac;
  String mahs;
  String matx;
  String tenhs;
  String maph;
  bool isSelected = false;
  List<String> themhs;
  List<String> xoahs;

  String get tenDecode {
    try {
      String s = tenhs;
      List<int> ints = List();
      s = s.replaceAll('[', '');
      s = s.replaceAll(']', '');
      List<String> strings = s.split(',');
      for (int i = 0; i < strings.length; i++) {
        ints.add(int.parse(strings[i]));
      }
      return utf8.decode(ints);
    } catch (e) {
      return tenhs;
    }
  }

  HSPH(this.mac, this.mahs, this.matx, this.maph);

  Map<String, dynamic> toJson() => {
        'mac': mac,
        'mahs': mahs,
        'matx': matx,
        'maph': maph,
        'themhs': themhs,
        'xoahs': xoahs,
      };

  HSPH.fromJson(Map<String, dynamic> json)
      : mac = json['mac'],
        mahs = json['mahs'],
        matx = json['matx'],
        maph = json['maph'],
        tenhs = json['tenhs'],
        themhs = json['themhs'],
        xoahs = json['xoahs'];
}
