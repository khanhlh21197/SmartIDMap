import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/loader.dart';
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/model/user.dart';
import 'package:smartid_map/secrets.dart';
import 'package:smartid_map/ui/add_ui/map_view_student.dart';

import 'package:smartid_map/model/bus.dart';
import 'package:smartid_map/model/thietbi.dart';

import '../../response/device_response.dart';

class AddStudentScreen extends StatefulWidget {
  final bool isParent;

  const AddStudentScreen({Key key, this.isParent}) : super(key: key);

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  static const GET_BUS = 'getTuyenxe';
  static const REGISTER_STUDENT = 'registerHS';
  static const GET_PARENT = 'getph';
  static const GET_STUDENT = 'getHS';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final _places = new GoogleMapsPlaces(apiKey: Secrets.API_KEY);

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  final scrollController = ScrollController();
  final studentNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final parentIdController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  var _descriptionController = TextEditingController();

  String currentSelectedValue;
  String pubTopic;

  double lat;
  double long;

  String busId = '';
  List<Bus> buses = List();
  List<String> busIds = List();

  List<User> parents = List();
  var dropDownParents = ['   '];
  var parentID;

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var studentID;

  @override
  void initState() {
    initMqtt();
    if (widget.isParent) {
      getStudentId();
    } else {
      getParent();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm học sinh',
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
                buildTextField(
                  'Tên học sinh',
                  Icon(Icons.email),
                  TextInputType.text,
                  studentNameController,
                ),
                buildTextField(
                  'SĐT',
                  Icon(Icons.phone_android),
                  TextInputType.text,
                  phoneNumberController,
                ),
                widget.isParent
                    ? _dropDownStudent()
                    : idDeviceContainer(
                        'Mã học sinh *',
                        Icon(Icons.vpn_key),
                        TextInputType.visiblePassword,
                        studentIdController,
                      ),
                widget.isParent ? Container() : _dropDownParent(),
                // idDeviceContainer(
                //   'Mã phụ huynh',
                //   Icon(Icons.vpn_key),
                //   TextInputType.visiblePassword,
                //   parentIdController,
                // ),
                addressContainer(),
                Container(
                  width: double.infinity,
                  height: 300,
                  child: MapViewStudent(lat: lat, lon: long),
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
                if (studentID == null && studentIdController.text.isEmpty) {
                  return;
                }
                Student s = Student(
                    studentID ?? studentIdController.text,
                    utf8.encode(studentNameController.text).toString(),
                    phoneNumberController.text,
                    utf8.encode(addressController.text).toString(),
                    parentID,
                    Constants.mac);
                // ThietBi tb = ThietBi(
                //   idController.text,
                //   currentSelectedValue,
                //   '',
                //   '',
                //   '',
                //   Constants.mac,
                // );
                pubTopic = REGISTER_STUDENT;
                publishMessage(pubTopic, jsonEncode(s));
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget addressContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 44,
      child: TextField(
        onTap: () async {
          // then get the Prediction selected
          Prediction p = await PlacesAutocomplete.show(
              context: context,
              apiKey: Secrets.API_KEY,
              onError: (value) {
                print(
                    '_AddStudentScreenState.searchAddress ${value.errorMessage}');
              });
          displayPrediction(p);
        },
        controller: addressController,
        keyboardType: TextInputType.text,
        autocorrect: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Nhập địa chỉ',
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
          prefixIcon: Icon(FontAwesomeIcons.map),
        ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      lat = detail.result.geometry.location.lat;
      long = detail.result.geometry.location.lng;

      var address = detail.result.formattedAddress;

      print('_AddStudentScreenState.displayPrediction $lat-$long');
      print(address);

      setState(() {
        addressController.text = address;
      });
    }
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
              "Chọn HS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: studentID,
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
                  studentID = data;
                  print(studentID);
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
    var response = DeviceResponse.fromJson(responseMap);
    print('_AddStudentScreenState.handle ${buses.length}');

    switch (pubTopic) {
      case GET_BUS:
        buses = response.id.map((e) => Bus.fromJson(e)).toList();
        busIds.clear();
        buses.forEach((element) {
          busIds.add(element.matx);
        });
        setState(() {});
        // hideLoadingDialog();
        break;
      case REGISTER_STUDENT:
        if (responseMap['result'] == 'true' &&
            responseMap['errorCode'] == '0') {
          Navigator.pop(context);
        }
        break;
      case GET_PARENT:
        parents = response.id.map((e) => User.fromJson(e)).toList();
        print('_StudentBusScreenState.handle ${parents.length}');
        dropDownParents.clear();
        parents.forEach((element) {
          dropDownParents.add(element.maph);
        });
        setState(() {});
        break;
      case GET_STUDENT:
        students = response.id.map((e) => Student.fromJson(e)).toList();
        print('_StudentBusScreenState.handle ${parents.length}');
        dropDownStudents.clear();
        students.forEach((element) {
          dropDownStudents.add(element.mahs);
        });
        setState(() {});
        break;
    }
  }

  void getParent() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_PARENT;
    publishMessage(pubTopic, jsonEncode(t));
  }

  void getStudentId() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_STUDENT;
    publishMessage(pubTopic, jsonEncode(t));
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
    _descriptionController.dispose();
    super.dispose();
  }
}
