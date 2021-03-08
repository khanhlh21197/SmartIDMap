import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/vehicle.dart';

class EditVehicleDialog extends StatefulWidget {
  final Vehicle vehicle;
  final Function(dynamic) updateCallback;
  final Function(dynamic) deleteCallback;

  const EditVehicleDialog(
      {Key key, this.vehicle, this.updateCallback, this.deleteCallback})
      : super(key: key);

  @override
  _EditVehicleDialogState createState() => _EditVehicleDialogState();
}

class _EditVehicleDialogState extends State<EditVehicleDialog> {
  static const UPDATE_VEHICLE = 'updateXe';
  static const DELETE_VEHICLE = 'deleteXe';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final scrollController = ScrollController();
  final monitorIdController = TextEditingController();
  final driverIdController = TextEditingController();
  final deviceIdController = TextEditingController();
  final vehicleIdController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final licensePlateController = TextEditingController();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  String pubTopic = '';
  String currentSelectedValue;
  Vehicle updatedVehicle;

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
        case UPDATE_VEHICLE:
          widget.updateCallback(updatedVehicle);
          break;
        case DELETE_VEHICLE:
          widget.deleteCallback('true');
          Navigator.of(context).pop();
      }
      Navigator.of(context).pop();
    }
  }

  void initController() async {
    monitorIdController.text = widget.vehicle.mags;
    driverIdController.text = widget.vehicle.malx;
    deviceIdController.text = widget.vehicle.matb;
    vehicleIdController.text = widget.vehicle.maxe;
    vehicleTypeController.text = widget.vehicle.loaixe;
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
                  'Mã xe',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  vehicleIdController,
                ),
                buildTextField(
                  'Loại xe',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  vehicleTypeController,
                ),
                buildTextField(
                  'Biển số',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  licensePlateController,
                ),
                buildTextField(
                  'Mã giám sát',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  monitorIdController,
                ),
                buildTextField(
                  'Mã lái xe',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  driverIdController,
                ),
                buildTextField(
                  'Mã thiết bị',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  deviceIdController,
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
                    pubTopic = DELETE_VEHICLE;
                    var v = Vehicle(
                        widget.vehicle.maxe,
                        '',
                        widget.vehicle.malx,
                        widget.vehicle.mags,
                        widget.vehicle.matb,
                        widget.vehicle.bienso,
                        Constants.mac);
                    publishMessage(pubTopic, jsonEncode(v));
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

  Future<void> _tryEdit() async {
    updatedVehicle = Vehicle(
        vehicleIdController.text,
        vehicleTypeController.text,
        driverIdController.text,
        monitorIdController.text,
        deviceIdController.text,
        licensePlateController.text,
        Constants.mac);
    pubTopic = UPDATE_VEHICLE;
    publishMessage(pubTopic, jsonEncode(updatedVehicle));
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
    monitorIdController.dispose();
    driverIdController.dispose();
    deviceIdController.dispose();
    vehicleIdController.dispose();
    vehicleTypeController.dispose();
    licensePlateController.dispose();
    super.dispose();
  }
}
