import 'dart:ui';

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
final String server_uri_key = 'serverUri';
// final String serverUri = "192.168.1.237";
// final String serverUri = "192.168.137.1";
final String serverUri = "103.237.145.184";

// final String serverUri = "192.168.2.5";
// final int port = 1234;
final int port = 4568;
// final int port = 4567;
final String login_topic = "loginuser";
final String patient_login_topic = "loginbenhnhan";
final String home_status = "statusnha";
final String room_status = "statusphong";
final String device_status = "statusphong";
String mac = "02:00:00:00:00:00";

const LOGIN_PARENT = 'loginph';
const REGISTER_USER = 'registeruser';
const REGISTER_PARENT = 'registerph';
const REGISTER_DEVICE = 'registertb';
const REGISTER_DRIVER = 'registerlaixe';
const REGISTER_MONITOR = 'registergiamsat';
const REGISTER_STUDENT = 'registerHS';
const REGISTER_HS_TX = 'registerHSTX';
const REGISTER_CLASS = 'registerlop';
const REGISTER_VEHICLE = 'registerXe';
const REGISTER_HS_PH = 'registerHSPH';
const GET_HS_PH = 'getHSPH';
const GET_PHONE = 'getdienthoai';

const String GET_STUDENT = 'getHS';
const GET_STUDENT_BY_BUS_ID = 'getHSkmatx';
const GET_BUS = 'getTuyenxe';
const GET_BUS_BY_STUDENT_ID = 'getTuyenxemahs';
const GET_PARENT = 'getph';
const String GET_CLASS = 'getlop';
const String GET_CLASS_BY_GRADE = 'getloptheokhoi';
const String GET_STUDENT_BY_CLASS = 'getHStheolop';
const UPDATE_HS_TX = 'updateHSTX';
const UPDATE_HS_PH = 'updateHSPH';
const GET_HS_TX = 'getHSTX';
final String REGISTER_LICH_KLV = 'registerlichklv';
final String TX_HDS = 'updateTuyenxegiohds';
final String TX_HDC = 'updateTuyenxegiohdc';
const GET_MONITOR = 'getgiamsat';
const GET_DRIVER = 'getlaixe';
const GET_DEVICE = 'gettb';
const GET_VEHICLE = 'getXe';
const REGISTER_BUS = 'registerTuyenxe';
const GET_ID_ALL = 'getmaall';

const UPDATE_BUS = 'updateTuyenxe';
const DELETE_BUS = 'deleteTuyenxe';
const UPDATE_DEVICE = 'updatethietbi';
const DELETE_DEVICE = 'deletetb';
const UPDATE_DRIVER = 'updatelaixe';
const DELETE_DRIVER = 'deletelaixe';
const UPDATE_MONITOR = 'updategiamsat';
const DELETE_MONITOR = 'deletegiamsat';
const UPDATE_STUDENT = 'updateHS';
const DELETE_STUDENT = 'deleteHS';
const UPDATE_VEHICLE = 'updateXe';
const DELETE_VEHICLE = 'deleteXe';
const UPDATE_USER = 'updateuser';
const UPDATE_PARENT = 'updateph';
const DELETE_PARENT = 'deleteph';
const DELETE_USER = 'deleteuser';
const CHANGE_PASSWORD_USER = 'updatepass';
const CHANGE_PASSWORD_PARENT = 'updatepassph';

const GET_INFO_USER = 'getinfouser';
const GET_INFO_PARENT = 'getinfoph';
const GET_DEPARTMENT = 'loginkhoa';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

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
