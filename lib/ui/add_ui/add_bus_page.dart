import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/loader.dart';
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/response/mqtt_response.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/bus.dart';
import 'package:smartid_map/model/class.dart';
import 'package:smartid_map/model/driver.dart';
import 'package:smartid_map/model/monitor.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/model/thietbi.dart';
import 'package:smartid_map/model/vehicle.dart';
import 'package:smartid_map/response/device_response.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddBusScreen extends StatefulWidget {
  @override
  _AddBusScreenState createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final String SUB_MONITOR = Constants.mac + 'monitor';
  final String SUB_DRIVER = Constants.mac + 'driver';
  final String SUB_DEVICE = Constants.mac + 'device';
  final String SUB_VEHICLE = Constants.mac + 'vehicle';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  final scrollController = ScrollController();
  final busNameController = TextEditingController();
  final busIdController = TextEditingController();
  final vehicleIdController = TextEditingController();
  final noteController = TextEditingController();
  var _descriptionController = TextEditingController();
  final monitorIdController = TextEditingController();
  final driverIdController = TextEditingController();
  final deviceIdController = TextEditingController();

  DateTime currentTime = DateTime.now();
  String morningStartTime = '6:0';
  String morningEndTime = '8:0';
  String afternoonStartTime = '13:0';
  String afternoonEndTime = '18:0';
  String relaxTime = '';

  //syncfution_flutter_datepicker
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  String currentSelectedValue;
  List<String> stringDates = List();

  List<Monitor> monitors = List();
  var dropDownMonitors = ['   '];
  var monitorId;

  List<Driver> drivers = List();
  var dropDownDrivers = ['   '];
  var driverId;

  List<ThietBi> devices = List();
  var dropDownDevices = ['   '];
  var deviceId;

  List<Vehicle> vehicles = List();
  var dropDownVehicles = ['   '];
  var vehicleId;

  var dropDownGrades = ['   '];
  var dropDownClasses = ['   '];
  var _grade;
  var _class;
  List<Student> students = List();
  List<Class> classes = List();
  List<String> mahs = List();

  var pubTopic = '';

  @override
  void initState() {
    initMqtt().then((value) => getIdAll());
    getGrades();
    super.initState();
  }

  void getGrades() async {
    var grades = await DefaultAssetBundle.of(context)
        .loadString('assets/json/grade.json');
    dropDownGrades = gradeFromJson(grades);
    setState(() {});
  }

  void getDevices() async {
    ThietBi t = ThietBi('', '', '', '', '', SUB_DEVICE);
    pubTopic = Constants.GET_DEVICE;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
  }

  void getMonitors() async {
    ThietBi t = ThietBi('', '', '', '', '', SUB_MONITOR);
    pubTopic = Constants.GET_MONITOR;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
  }

  void getDrivers() async {
    ThietBi t = ThietBi('', '', '', '', '', SUB_DRIVER);
    pubTopic = Constants.GET_DRIVER;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
  }

  void getVehicles() async {
    ThietBi t = ThietBi('', '', '', '', '', SUB_VEHICLE);
    pubTopic = Constants.GET_VEHICLE;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
  }

  void getIdAll() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = Constants.GET_ID_ALL;
    publishMessage(pubTopic, jsonEncode(t));
    // showLoadingDialog();
  }

  void getStudents() async {
    Student s = Student('', '', '', '', '', _class, _grade, Constants.mac);
    pubTopic = Constants.GET_STUDENT;
    publishMessage(pubTopic, jsonEncode(s));
    showLoadingDialog();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range =
            DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
                ' - ' +
                DateFormat('dd/MM/yyyy')
                    .format(args.value.endDate ?? args.value.startDate)
                    .toString();
      } else if (args.value is DateTime) {
        _selectedDate = args.value;
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm tuyến xe',
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
                idDeviceContainer(
                  'Mã tuyến xe *',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  busIdController,
                ),
                idDeviceContainer(
                  'Tên tuyến xe',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  busNameController,
                ),
                _dropDownDevice(),
                _dropDownDriver(),
                _dropDownMonitor(),
                _dropDownVehicle(),
                buildTextField(
                  'Ghi chú',
                  Icon(Icons.email),
                  TextInputType.text,
                  noteController,
                ),
                Text(
                  'Chọn học sinh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                chooseClassContainer(),
                students.length > 0 ? buildStudentList() : Container(),
                // Text(
                //   'Cài đặt thời gian theo dõi : ',
                //   style: TextStyle(fontSize: 18),
                // ),
                // morningTime(),
                // afternoonTime(),
                // FlatButton(
                //     onPressed: () {
                //       navigatorPush(context, MultipleDatePicker(
                //         datePickerCallback: (value) {
                //           List<DateTime> dates = value;
                //           dates.forEach((element) {
                //             stringDates
                //                 .add(DateFormat('dd/MM/yyyy').format(element));
                //           });
                //           relaxTime = '';
                //           relaxTime = stringDates.toString();
                //           Bus b = Bus(
                //             busIdController.text,
                //             utf8.encode(busNameController.text).toString(),
                //             vehicleIdController.text,
                //             driverIdController.text,
                //             monitorIdController.text,
                //             deviceIdController.text,
                //             utf8.encode(noteController.text).toString(),
                //             '$morningStartTime:$morningEndTime',
                //             '$afternoonStartTime:$afternoonEndTime',
                //             stringDates.toString(),
                //             relaxTime,
                //             Constants.mac,
                //           );
                //           // publishMessage('registerTuyenxe', jsonEncode(b));
                //           print(
                //               '_AddBusScreenState.buildButton ${jsonEncode(b)}');
                //           publishMessage(REGISTER_LICH_KLV, jsonEncode(b));
                //           setState(() {});
                //         },
                //       ));
                //     },
                //     child: wrapText(
                //         relaxTime == '' ? 'Chọn lịch nghỉ' : relaxTime)),
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

  Widget buildStudentList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
      ),
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
          buildTextLabel('Mã', 2),
          verticalLine(),
          buildTextLabel('Chọn', 1),
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
                  buildTextData(students[index].tenDecode ?? '', 4),
                  verticalLine(),
                  buildTextData(students[index].mahs ?? '', 2),
                  verticalLine(),
                  Expanded(
                    flex: 1,
                    child: Checkbox(
                        value: students[index].isSelected,
                        onChanged: (_value) {
                          students[index].isSelected =
                              !students[index].isSelected;
                          if (students[index].isSelected) {
                            mahs.add(students[index].mahs);
                          }
                          if (!students[index].isSelected) {
                            if (mahs.contains(students[index].mahs)) {
                              mahs.remove(students[index].mahs);
                            }
                          }
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

  Widget wrapText(String text) {
    double cWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: cWidth,
      child: Column(
        children: <Widget>[
          Text(
            text,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

  Widget morningTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Text('Sáng : '),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                showTimerPicker((value) {
                  morningStartTime = '${value.hour}:${value.minute}';
                  Bus b = Bus(
                    busIdController.text,
                    utf8.encode(busNameController.text).toString(),
                    vehicleId,
                    driverId,
                    monitorId,
                    deviceId,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$morningStartTime:$morningEndTime',
                    mahs,
                    Constants.mac,
                  );
                  publishMessage(Constants.TX_HDS, jsonEncode(b));
                });
              },
              child: Text('Bắt đầu $morningStartTime'),
              color: Colors.blue,
            ),
            flex: 2,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                showTimerPicker((value) {
                  morningEndTime = '${value.hour}:${value.minute}';
                  Bus b = Bus(
                    busIdController.text,
                    utf8.encode(busNameController.text).toString(),
                    vehicleId,
                    driverId,
                    monitorId,
                    deviceId,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$morningStartTime:$morningEndTime',
                    mahs,
                    Constants.mac,
                  );
                  publishMessage(Constants.TX_HDS, jsonEncode(b));
                });
              },
              child: Text('Kết thúc $morningEndTime'),
              color: Colors.red,
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget afternoonTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Text('Chiều : '),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                showTimerPicker((value) {
                  afternoonStartTime = '${value.hour}:${value.minute}';
                  Bus b = Bus(
                    busIdController.text,
                    utf8.encode(busNameController.text).toString(),
                    vehicleId,
                    driverId,
                    monitorId,
                    deviceId,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$afternoonStartTime:$afternoonEndTime',
                    mahs,
                    Constants.mac,
                  );
                  publishMessage(Constants.TX_HDC, jsonEncode(b));
                });
              },
              child: Text('Bắt đầu $afternoonStartTime'),
              color: Colors.blue,
            ),
            flex: 2,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                showTimerPicker((value) {
                  afternoonEndTime = '${value.hour}:${value.minute}';
                  Bus b = Bus(
                    busIdController.text,
                    utf8.encode(busNameController.text).toString(),
                    vehicleId,
                    driverId,
                    monitorId,
                    deviceId,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$afternoonStartTime:$afternoonEndTime',
                    mahs,
                    Constants.mac,
                  );
                  publishMessage(Constants.TX_HDC, jsonEncode(b));
                });
              },
              child: Text('Kết thúc $afternoonEndTime'),
              color: Colors.red,
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget relaxTimeChoosing() {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Selected date: ' + _selectedDate),
                Text('Selected date count: ' + _dateCount),
                Text('Selected range: ' + _range),
                Text('Selected ranges count: ' + _rangeCount)
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 80,
            right: 0,
            bottom: 0,
            child: SfDateRangePicker(
              onSelectionChanged: _onSelectionChanged,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                  DateTime.now().subtract(const Duration(days: 4)),
                  DateTime.now().add(const Duration(days: 3))),
            ),
          )
        ],
      ),
    );
  }

  void showTimerPicker(Function(TimeOfDay) onPickSuccess) {
    showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: currentTime.hour, minute: currentTime.minute),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    ).then((value) {
      onPickSuccess(value);
      setState(() {});
    });
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

  Widget _dropDownMonitor() {
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
              "Giám sát",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: monitorId,
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
                  monitorId = data;
                  print(monitorId);
                });
              },
              items: dropDownMonitors
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

  Widget _dropDownVehicle() {
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
              "Xe",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: vehicleId,
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
                  vehicleId = data;
                  print(vehicleId);
                });
              },
              items: dropDownVehicles
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

  Widget _dropDownDriver() {
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
              "Lái xe",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: driverId,
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
                  driverId = data;
                  print(driverId);
                });
              },
              items:
                  dropDownDrivers.map<DropdownMenuItem<String>>((String value) {
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

  Widget _dropDownDevice() {
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
              "Thiết bị",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: deviceId,
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
                  deviceId = data;
                  print(deviceId);
                });
              },
              items:
                  dropDownDevices.map<DropdownMenuItem<String>>((String value) {
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

  Widget chooseClassContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  _class = null;
                  getClasses(_grade);
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
            child: Text(
              "Lớp",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String data) {
                setState(() {
                  _class = data;
                  print(_class);
                  getStudents();
                });
              },
              items:
                  dropDownClasses.map<DropdownMenuItem<String>>((String value) {
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
                Bus b = Bus(
                  busIdController.text,
                  utf8.encode(busNameController.text).toString(),
                  vehicleId ?? '',
                  driverId ?? '',
                  monitorId ?? '',
                  deviceId ?? '',
                  utf8.encode(noteController.text).toString(),
                  '$morningStartTime:$morningEndTime',
                  '$afternoonStartTime:$afternoonEndTime',
                  stringDates.toString(),
                  '',
                  mahs,
                  Constants.mac,
                );
                pubTopic = Constants.REGISTER_BUS;
                publishMessage(pubTopic, jsonEncode(b));
                print('_AddBusScreenState.buildButton ${jsonEncode(b)}');
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
    // getDevices();
    // Future.delayed(Duration(milliseconds: 300), getDrivers);
    // Future.delayed(Duration(milliseconds: 600), getMonitors);
    // Future.delayed(Duration(milliseconds: 900), getVehicles);
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);

    switch (pubTopic) {
      case Constants.REGISTER_BUS:
        if (responseMap['result'] == 'true' &&
            responseMap['errorCode'] == '0') {
          Navigator.pop(context);
        }
        break;
      case Constants.GET_STUDENT:
        var response = DeviceResponse.fromJson(responseMap);
        students = response.id.map((e) => Student.fromJson(e)).toList();
        students.forEach((element) {
          if (mahs.contains(element.mahs)) {
            element.isSelected = true;
          }
        });
        setState(() {});
        hideLoadingDialog();
        break;
      case Constants.GET_CLASS:
      case Constants.GET_CLASS_BY_GRADE:
        var response = DeviceResponse.fromJson(responseMap);
        print('_AddBusScreenState.handle $responseMap');
        classes = response.id.map((e) => Class.fromJson(e)).toList();
        dropDownClasses.clear();
        classes.forEach((element) {
          dropDownClasses.add(element.lop);
        });
        setState(() {});
        hideLoadingDialog();
        break;
      // case GET_DEVICE:
      //   devices = response.id.map((e) => ThietBi.fromJson(e)).toList();
      //   dropDownDevices.clear();
      //   devices.forEach((element) {
      //     dropDownDevices.add(element.matb);
      //   });
      //   setState(() {});
      //   // hideLoadingDialog();
      //   break;
      // case GET_MONITOR:
      //   monitors = response.id.map((e) => Monitor.fromJson(e)).toList();
      //   dropDownMonitors.clear();
      //   monitors.forEach((element) {
      //     dropDownMonitors.add(element.mags);
      //   });
      //   setState(() {});
      //   // hideLoadingDialog();
      //   break;
      // case GET_DRIVER:
      //   drivers = response.id.map((e) => Driver.fromJson(e)).toList();
      //   dropDownDrivers.clear();
      //   drivers.forEach((element) {
      //     dropDownDrivers.add(element.malx);
      //   });
      //   setState(() {});
      //   // hideLoadingDialog();
      //   break;
      // case GET_VEHICLE:
      //   vehicles = response.id.map((e) => Vehicle.fromJson(e)).toList();
      //   dropDownVehicles.clear();
      //   vehicles.forEach((element) {
      //     dropDownVehicles.add(element.maxe);
      //   });
      //   // hideLoadingDialog();
      //   setState(() {});
      //   break;
      case Constants.GET_ID_ALL:
        var response = MqttResponse.fromJson(responseMap);
        dropDownVehicles.clear();
        dropDownDrivers.clear();
        dropDownMonitors.clear();
        dropDownDevices.clear();
        response.id.maxe.forEach((element) {
          dropDownVehicles.add(element.maxe);
        });
        response.id.malx.forEach((element) {
          dropDownDrivers.add(element.malx);
        });
        response.id.mags.forEach((element) {
          dropDownMonitors.add(element.mags);
        });
        response.id.matb.forEach((element) {
          dropDownDevices.add(element.matb);
        });
        setState(() {});
        break;
    }
    pubTopic = '';
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
    busNameController.dispose();
    busIdController.dispose();
    vehicleIdController.dispose();
    noteController.dispose();
    _descriptionController.dispose();
    monitorIdController.dispose();
    driverIdController.dispose();
    deviceIdController.dispose();
    super.dispose();
  }
}
