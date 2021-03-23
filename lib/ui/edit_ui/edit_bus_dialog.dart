import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/bus.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditBusDialog extends StatefulWidget {
  final Bus bus;
  final Function(dynamic) updateCallback;
  final Function(dynamic) deleteCallback;

  const EditBusDialog(
      {Key key, this.bus, this.updateCallback, this.deleteCallback})
      : super(key: key);

  @override
  _EditBusDialogState createState() => _EditBusDialogState();
}

class _EditBusDialogState extends State<EditBusDialog> {
  static const UPDATE_BUS = 'updateTuyenxe';
  static const DELETE_BUS = 'deleteTuyenxe';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final scrollController = ScrollController();
  final busNameController = TextEditingController();
  final busIdController = TextEditingController();
  final vehicleIdController = TextEditingController();
  final noteController = TextEditingController();
  final monitorIdController = TextEditingController();
  final driverIdController = TextEditingController();
  final deviceIdController = TextEditingController();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  String pubTopic = '';
  String currentSelectedValue;
  Bus updatedBus;

  DateTime currentTime = DateTime.now();
  String morningStartTime = '6 : 0';
  String morningEndTime = '8 : 0';
  String afternoonStartTime = '13 : 0';
  String afternoonEndTime = '18 : 0';
  String relaxTime = '';

  //syncfution_flutter_datepicker
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

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
        case UPDATE_BUS:
          widget.updateCallback(updatedBus);
          break;
        case DELETE_BUS:
          widget.deleteCallback('true');
          Navigator.of(context).pop();
      }
      Navigator.of(context).pop();
    }
  }

  void initController() async {
    busNameController.text = widget.bus.tenDecode;
    busIdController.text = widget.bus.matx;
    vehicleIdController.text = widget.bus.maxe;
    noteController.text = widget.bus.ghichuDecode;
    monitorIdController.text = widget.bus.mags;
    driverIdController.text = widget.bus.malx;
    deviceIdController.text = widget.bus.matb;
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
                  'Mã tuyến xe',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  busIdController,
                ),
                buildTextField(
                  'Tên tuyến xe',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  busNameController,
                ),
                buildTextField(
                  'Mã xe',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  vehicleIdController,
                ),
                buildTextField(
                  'Ghi chú',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  noteController,
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
                    pubTopic = DELETE_BUS;
                    var b = Bus(
                        widget.bus.matx,
                        '',
                        widget.bus.maxe,
                        driverIdController.text,
                        monitorIdController.text,
                        deviceIdController.text,
                        '',
                        '',
                        '',
                        '',
                        Constants.mac);
                    publishMessage(pubTopic, jsonEncode(b));
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
                showTimerPicker((value) => {
                      morningStartTime = '${value.hour} : ${value.minute}',
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
                showTimerPicker((value) => {
                      morningEndTime = '${value.hour} : ${value.minute}',
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
                showTimerPicker((value) => {
                      afternoonStartTime = '${value.hour} : ${value.minute}',
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
                showTimerPicker((value) => {
                      afternoonEndTime = '${value.hour} : ${value.minute}',
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

  Future<void> _tryEdit() async {
    updatedBus = Bus(
        busIdController.text,
        utf8.encode(busNameController.text).toString(),
        vehicleIdController.text,
        driverIdController.text,
        monitorIdController.text,
        deviceIdController.text,
        utf8.encode(noteController.text).toString(),
        '',
        '',
        '',
        Constants.mac);
    pubTopic = UPDATE_BUS;
    publishMessage(pubTopic, jsonEncode(updatedBus));
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
    monitorIdController.dispose();
    driverIdController.dispose();
    deviceIdController.dispose();
    super.dispose();
  }
}
