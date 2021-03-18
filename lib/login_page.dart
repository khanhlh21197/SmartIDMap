import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/loader.dart';
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/response/device_response.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/main_screen.dart';
import 'package:smartid_map/model/user.dart';
import 'package:smartid_map/navigator.dart';
import 'package:smartid_map/secrets.dart';
import 'package:smartid_map/signup.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.registerUser}) : super(key: key);

  final String title;
  final User registerUser;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  bool loading = false;
  bool _switchValue = false;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String iduser;
  var status;
  String playerid = '';
  bool switchValue = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _circularProgress() {
    return Dialog(
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          new CircularProgressIndicator(),
          new Text("Loading"),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initMqtt();
    initOneSignal(Secrets.one_signal_app_id);
    // mqttClientWrapper =
    //     MQTTClientWrapper(() => print('Success'), (message) => login(message));
    // mqttClientWrapper.prepareMqttClient(Constants.mac);
    sharedPrefsHelper = SharedPrefsHelper();
    getSharedPrefs();
  }

  void initOneSignal(oneSignalAppId) async {
    OneSignal.shared.setRequiresUserPrivacyConsent(false);

    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: true
    };
    OneSignal.shared.init(oneSignalAppId, iOSSettings: settings);
    status = await OneSignal.shared.getPermissionSubscriptionState();
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
// will be called whenever a notification is received
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      print('Received: ' + notification?.payload?.body ?? '');
    });
// will be called whenever a notification is opened/button pressed.
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('Opened: ' + result.notification?.payload?.body ?? '');
    });
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => login(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  Future<void> getSharedPrefs() async {
    _emailController.text = await sharedPrefsHelper.getStringValuesSF('email');
    _passwordController.text =
        await sharedPrefsHelper.getStringValuesSF('password');
    _switchValue = await sharedPrefsHelper.getBoolValuesSF('switchValue');
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      await _tryLogin();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    setState(() {
      loading = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (loading) {
        hideLoadingDialog();
        _showToast(context);
      }
    });
    try {
      playerid = await status.subscriptionStatus.userId;
    } catch (e) {
      print('_LoginPageState._tryLogin erorr: ${e.toString()}');
    }
    print('_LoginPageState.initOneSignal playerID: $playerid');
    User user = User(Constants.mac, _emailController.text,
        _passwordController.text, '', '', '', '', '', playerid);

    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      if (switchValue) {
        mqttClientWrapper.patientLogin(user);
      } else {
        mqttClientWrapper.login(user);
      }
    } else {
      await initMqtt();
      mqttClientWrapper.login(user);
    }
  }

  Future<void> login(String message) async {
    hideLoadingDialog();
    print('_LoginPageState.login $message');
    Map responseMap = jsonDecode(message);

    iduser = DeviceResponse.fromJson(responseMap).message;
    await sharedPrefsHelper.addStringToSF('iduser', iduser);

    if (responseMap['result'] == 'true') {
      setState(() {
        loading = false;
      });
      print('Login success');
      if (_switchValue != null) {
        if (_switchValue) {
          await sharedPrefsHelper.addStringToSF('email', _emailController.text);
          await sharedPrefsHelper.addStringToSF(
              'password', _passwordController.text);
          await sharedPrefsHelper.addBoolToSF('switchValue', _switchValue);
        } else {
          await sharedPrefsHelper.removeValues();
        }
      }
      await sharedPrefsHelper.addStringToSF('email', _emailController.text);
      await sharedPrefsHelper.addStringToSF(
          'password', _passwordController.text);
      await sharedPrefsHelper.addBoolToSF('switchValue', _switchValue);
      await sharedPrefsHelper.addBoolToSF('login', true);
      await sharedPrefsHelper.addIntToSF('quyen', responseMap['quyen']);
      navigatorPushAndRemoveUntil(context, MainScreen());
    } else {
      this._showToast(context);
      // Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  void _showToast(BuildContext context) {
    Dialogs.showAlertDialog(
        context, 'Đăng nhập thất bại, vui lòng thử lại sau!');
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController _controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: _controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _saveSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("Lưu tài khoản"),
        Switch(
          value: this._switchValue,
          onChanged: (value) {
            setState(() {
              _switchValue = !_switchValue;
            });
          },
        )
      ],
    );
  }

  void showLoadingDialog() {
    Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        showLoadingDialog();
        await _tryLogin();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.lightBlueAccent, Colors.blueAccent])),
        child: Text(
          'Đăng nhập',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _facebookButton() {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/anco_logo.jpg',
                  ),
                  // Text(
                  //   'Anco',
                  //   style: TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.w400),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Chưa có tài khoản ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Đăng ký',
              style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon(
        //   Icons.local_fire_department,
        //   size: 40,
        //   color: Colors.blue,
        // ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'T',
              style: GoogleFonts.portLligatSans(
                textStyle: Theme.of(context).textTheme.display1,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
              children: [
                TextSpan(
                  text: 'ran',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                TextSpan(
                  text: 'Sportation',
                  style: TextStyle(color: Colors.blue, fontSize: 30),
                ),
              ]),
        ),
      ],
    );
  }

  Widget _emailPasswordWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: <Widget>[
          _entryField("Tên đăng nhập", _emailController),
          _entryField("Mật khẩu", _passwordController, isPassword: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              // Positioned(
              //   top: -height * .15,
              //   right: -MediaQuery.of(context).size.width * .4,
              //   child: BezierContainer(),
              // ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SizedBox(height: height * .2),
                      SizedBox(
                        height: 5,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        child: Image.asset(
                          'assets/images/anco_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 15),
                      _title(),
                      SizedBox(height: 50),
                      _emailPasswordWidget(),
                      // _saveSwitch(),
                      _submitButton(),
                      // switchContainer(),
                      _divider(),
                      // _facebookButton(),
                      _createAccountLabel(),
                    ],
                  ),
                ),
              ),
              // Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget switchContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Quản lý',
          ),
          CupertinoSwitch(
            activeColor: Colors.blue,
            value: switchValue,
            onChanged: (value) {
              setState(() {
                switchValue = value;
              });
            },
          ),
          Text(
            'Bệnh nhân',
          ),
        ],
      ),
    );
  }
}
