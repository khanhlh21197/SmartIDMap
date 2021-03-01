import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';

final double defaultZoom = 10.8746;
final double newZoom = 15.8746;

//type of add
const int ADD_DEPARTMENT = 0;
const int ADD_ROOM = 1;
const int ADD_DEVICE = 2;

const int EDIT_HOME = 0;
const int EDIT_ROOM = 1;
const int EDIT_DEVICE = 2;

final String defaultMarkerId = "1";

// final String serverUri = "test.mosquitto.org";
// final int port = 1883;
// final String topicName = "Dart/Mqtt_client/testtopic";
// final String serverUri = "45.119.82.186";
// final String serverUri = "192.168.1.237";
final String serverUri = "192.168.2.23";
// final int port = 1234;
final int port = 4567;
final String login_topic = "loginuser";
final String patient_login_topic = "loginbenhnhan";
final String home_status = "statusnha";
final String room_status = "statusphong";
final String device_status = "statusphong";
String mac = "02:00:00:00:00:00";

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

//OneSignal App ID
const one_signal_app_id = 'b773c836-f58c-487d-894a-1fe536eda615';

// Future<String> getId() async {
//   DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   if (Platform.isAndroid) {
//     AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
//     mac = androidDeviceInfo.id;
//     return Future.value(androidDeviceInfo.id);
//   } else if (Platform.isIOS) {
//     IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
//     mac = iosInfo.identifierForVendor;
//     return Future.value(iosInfo.identifierForVendor);
//   }
// }
