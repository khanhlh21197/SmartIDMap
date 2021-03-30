import 'package:flutter/material.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/login_page.dart';
import 'package:smartid_map/navigator.dart';

import 'helper/mqttClientWrapper.dart';
import 'helper/shared_prefs_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

enum SingingCharacter { defaultValue, inputURI }

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController _serverUriController = TextEditingController();

  bool isDefault = true;
  SingingCharacter _character = SingingCharacter.defaultValue;
  SharedPrefsHelper sharedPrefsHelper;
  MQTTClientWrapper mqttClientWrapper;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    super.initState();
  }

  @override
  void dispose() {
    _serverUriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: const Text('Mặc định'),
                  leading: Radio(
                    value: SingingCharacter.defaultValue,
                    groupValue: _character,
                    onChanged: (SingingCharacter value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Nhập URL'),
                  leading: Radio(
                    value: SingingCharacter.inputURI,
                    groupValue: _character,
                    onChanged: (SingingCharacter value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ),
                _character == SingingCharacter.inputURI
                    ? buildTextField('Server URI', null, TextInputType.text,
                        _serverUriController)
                    : Container(),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.navigate_next)),
                      onTap: () async {
                        if (_character == SingingCharacter.inputURI) {
                          await sharedPrefsHelper.addStringToSF(
                              Constants.server_uri_key,
                              _serverUriController.text);
                        }
                        navigatorPush(context, LoginPage());
                      },
                    ),
                  ),
                ),
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
}
