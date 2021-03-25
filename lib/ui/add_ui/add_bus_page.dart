import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/loader.dart';
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/bus.dart';
import 'package:smartid_map/navigator.dart';
import 'package:smartid_map/ui/multiple_date_picker/multiple_date_picker_page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddBusScreen extends StatefulWidget {
  @override
  _AddBusScreenState createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final String REGISTER_LICH_KLV = 'registerlichklv';
  final String TX_HDS = 'updateTuyenxegiohds';
  final String TX_HDC = 'updateTuyenxegiohdc';

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

  @override
  void initState() {
    initMqtt();
    super.initState();
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
                  'Mã xe *',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  vehicleIdController,
                ),
                idDeviceContainer(
                  'Tên tuyến xe',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  busNameController,
                ),
                idDeviceContainer(
                  'Mã giám sát *',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  monitorIdController,
                ),
                idDeviceContainer(
                  'Mã lái xe *',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  driverIdController,
                ),
                idDeviceContainer(
                  'Mã thiết bị *',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  deviceIdController,
                ),
                buildTextField(
                  'Ghi chú',
                  Icon(Icons.email),
                  TextInputType.text,
                  noteController,
                ),
                Text(
                  'Cài đặt thời gian theo dõi : ',
                  style: TextStyle(fontSize: 18),
                ),
                morningTime(),
                afternoonTime(),
                FlatButton(
                    onPressed: () {
                      navigatorPush(context, MultipleDatePicker(
                        datePickerCallback: (value) {
                          List<DateTime> dates = value;
                          dates.forEach((element) {
                            stringDates
                                .add(DateFormat('dd/MM/yyyy').format(element));
                          });
                          relaxTime = '';
                          relaxTime = stringDates.toString();
                          Bus b = Bus(
                            busIdController.text,
                            utf8.encode(busNameController.text).toString(),
                            vehicleIdController.text,
                            driverIdController.text,
                            monitorIdController.text,
                            deviceIdController.text,
                            utf8.encode(noteController.text).toString(),
                            '$morningStartTime:$morningEndTime',
                            '$afternoonStartTime:$afternoonEndTime',
                            stringDates.toString(),
                            relaxTime,
                            Constants.mac,
                          );
                          // publishMessage('registerTuyenxe', jsonEncode(b));
                          print(
                              '_AddBusScreenState.buildButton ${jsonEncode(b)}');
                          publishMessage(REGISTER_LICH_KLV, jsonEncode(b));
                          setState(() {});
                        },
                      ));
                    },
                    child: wrapText(
                        relaxTime == '' ? 'Chọn lịch nghỉ' : relaxTime)),
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
                    vehicleIdController.text,
                    driverIdController.text,
                    monitorIdController.text,
                    deviceIdController.text,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$morningStartTime:$morningEndTime',
                    Constants.mac,
                  );
                  publishMessage(TX_HDS, jsonEncode(b));
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
                    vehicleIdController.text,
                    driverIdController.text,
                    monitorIdController.text,
                    deviceIdController.text,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$morningStartTime:$morningEndTime',
                    Constants.mac,
                  );
                  publishMessage(TX_HDS, jsonEncode(b));
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
                    vehicleIdController.text,
                    driverIdController.text,
                    monitorIdController.text,
                    deviceIdController.text,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$afternoonStartTime:$afternoonEndTime',
                    Constants.mac,
                  );
                  publishMessage(TX_HDC, jsonEncode(b));
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
                    vehicleIdController.text,
                    driverIdController.text,
                    monitorIdController.text,
                    deviceIdController.text,
                    utf8.encode(noteController.text).toString(),
                    '$morningStartTime:$morningEndTime',
                    '$afternoonStartTime:$afternoonEndTime',
                    stringDates.toString(),
                    '$afternoonStartTime:$afternoonEndTime',
                    Constants.mac,
                  );
                  publishMessage(TX_HDC, jsonEncode(b));
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
                  vehicleIdController.text,
                  driverIdController.text,
                  monitorIdController.text,
                  deviceIdController.text,
                  utf8.encode(noteController.text).toString(),
                  '$morningStartTime:$morningEndTime',
                  '$afternoonStartTime:$afternoonEndTime',
                  stringDates.toString(),
                  '',
                  Constants.mac,
                );
                // publishMessage('registerTuyenxe', jsonEncode(b));
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
