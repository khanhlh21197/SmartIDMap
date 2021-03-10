import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/model/monitor.dart';
import 'package:smartid_map/secrets.dart';

class EditMonitorDialog extends StatefulWidget {
  final Monitor monitor;
  final Function(dynamic) updateCallback;
  final Function(dynamic) deleteCallback;

  const EditMonitorDialog(
      {Key key, this.monitor, this.updateCallback, this.deleteCallback})
      : super(key: key);

  @override
  _EditMonitorDialogState createState() => _EditMonitorDialogState();
}

class _EditMonitorDialogState extends State<EditMonitorDialog> {
  static const UPDATE_MONITOR = 'updategiamsat';
  static const DELETE_MONITOR = 'deletegiamsat';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final _places = new GoogleMapsPlaces(apiKey: Secrets.API_KEY);
  final scrollController = ScrollController();

  final nameController = TextEditingController();
  final idController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  String pubTopic = '';
  String currentSelectedValue;
  Monitor updatedMonitor;
  double lat;
  double long;

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
        case UPDATE_MONITOR:
          widget.updateCallback(updatedMonitor);
          break;
        case DELETE_MONITOR:
          widget.deleteCallback('true');
          Navigator.of(context).pop();
      }
      Navigator.of(context).pop();
    }
  }

  void initController() async {
    nameController.text = widget.monitor.tenDecode;
    idController.text = widget.monitor.mags;
    phoneNumberController.text = widget.monitor.sdt;
    addressController.text = widget.monitor.nhaDecode;
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
                  'Mã giám sát',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  idController,
                ),
                buildTextField(
                  'Tên giám sát',
                  Icon(Icons.vpn_key),
                  TextInputType.text,
                  nameController,
                ),
                buildTextField(
                  'SĐT',
                  Icon(Icons.vpn_key),
                  TextInputType.number,
                  phoneNumberController,
                ),
                addressContainer(),
                deleteButton(),
                buildButton(),
              ],
            ),
          ),
        ),
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
                    pubTopic = DELETE_MONITOR;
                    var m =
                        Monitor('', '', '', widget.monitor.mags, Constants.mac);
                    publishMessage(pubTopic, jsonEncode(m));
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
    updatedMonitor = Monitor(
        utf8.encode(nameController.text).toString(),
        phoneNumberController.text,
        utf8.encode(addressController.text).toString(),
        idController.text,
        Constants.mac);
    pubTopic = UPDATE_MONITOR;
    publishMessage(pubTopic, jsonEncode(updatedMonitor));
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
    nameController.dispose();
    idController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
