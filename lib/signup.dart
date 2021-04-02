import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/loader.dart';
import 'package:smartid_map/helper/models.dart';
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/response/device_response.dart';
import 'package:smartid_map/login_page.dart';
import 'package:smartid_map/model/class.dart';
import 'package:smartid_map/model/student.dart';
import 'package:smartid_map/model/thietbi.dart';
import 'package:smartid_map/model/user.dart';
import 'package:smartid_map/secrets.dart';
import 'package:smartid_map/ui/add_ui/map_view_student.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title, this.isAdmin}) : super(key: key);

  final String title;
  final bool isAdmin;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  static const GET_STUDENT = 'getHS';
  static const REGISTER_USER = 'registeruser';
  static const REGISTER_PARENT = 'registerph';
  static const GET_CLASS = 'getlop';
  static const GET_CLASS_BY_GRADE = 'getloptheokhoi';

  MQTTClientWrapper mqttClientWrapper;
  User registerUser;
  String permissionValue = '2';
  final List<String> permissionItems = ['1', '2'];
  final _places = new GoogleMapsPlaces(apiKey: Secrets.API_KEY);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _success;
  String _userEmail;

  double lat;
  double long;

  var dropDownGrades = ['   '];
  var dropDownClasses = ['   '];
  var _grade;
  var _class;
  List<Student> students = List();
  List<Class> classes = List();

  var pubTopic = '';

  @override
  void initState() {
    initMqtt();
    getGrades();
    super.initState();
  }

  void getGrades() async {
    var grades = await DefaultAssetBundle.of(context)
        .loadString('assets/json/grade.json');
    dropDownGrades = gradeFromJson(grades);
    setState(() {});
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => register(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
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
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please enter some text!';
                }
                return null;
              },
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

  Widget chooseClassContainer() {
    return Container(
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
    pubTopic = GET_CLASS_BY_GRADE;
    publishMessage(pubTopic, jsonEncode(c));
    showLoadingDialog();
  }

  Widget _dropDownClass() {
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

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        _tryRegister();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.only(bottom: 20),
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
          'Đăng ký',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bạn đã có tài khoản ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Đăng nhập',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'H',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.lightBlueAccent,
          ),
          children: [
            TextSpan(
              text: 'ealth',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'Care',
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 30),
            ),
          ]),
    );
  }

  Widget _dropDownPermission() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Phân quyền",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        DropdownButton<String>(
          value: permissionValue,
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
              permissionValue = data;
              print(permissionValue);
              if (permissionValue == permissionItems[0]) {}
              if (permissionValue == permissionItems[1]) {}
            });
          },
          items: permissionItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
//        _entryField("Tên đăng nhập", _emailController),
//        _entryField("Mật khẩu", _passwordController, isPassword: true),
//        _entryField("Tên", _nameController),
//        _entryField("SĐT", _phoneNumberController),
        buildTextField("Tên đăng nhập", Icon(Icons.account_box_outlined),
            TextInputType.text, _emailController),
        buildTextField("Mật khẩu", Icon(Icons.security), TextInputType.text,
            _passwordController,
            obscureText: true),
        buildTextField("Tên", Icon(Icons.perm_identity), TextInputType.text,
            _nameController),
        buildTextField("SĐT", Icon(Icons.phone_android), TextInputType.text,
            _phoneNumberController),
        addressContainer(),
        Container(
          width: double.infinity,
          height: 300,
          child: MapViewStudent(lat: lat, lon: long),
        ),
        _dropDownPermission(),
        // _dropDownDepartment(),
      ],
    );
  }

  Widget buildTextField(String labelText, Icon prefixIcon,
      TextInputType keyboardType, TextEditingController controller,
      {obscureText: false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
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

  Widget addressContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        controller: _addressController,
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
        _addressController.text = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Đăng ký'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              // Positioned(
              //   top: -MediaQuery.of(context).size.height * .15,
              //   right: -MediaQuery.of(context).size.width * .4,
              //   child: BezierContainer(),
              // ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SizedBox(height: height * .1),
                      SizedBox(
                        height: 10,
                      ),
                      _emailPasswordWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      chooseClassContainer(),
                      students.length > 0 ? buildStudentList() : Container(),
                      _submitButton(),
                      // SizedBox(height: height * .14),
                      // _loginAccountLabel(),
                    ],
                  ),
                ),
              ),
            ],
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
          buildTextLabel('Địa chỉ', 2),
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
                  buildTextData(students[index].nhaDecode ?? '', 2),
                  verticalLine(),
                  Checkbox(
                      value: students[index].isSelected,
                      onChanged: (_value) {
                        students[index].isSelected =
                            !students[index].isSelected;
                        setState(() {});
                      }),
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

  void getStudents() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_STUDENT;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();
  }

  void showLoadingDialog() {
    Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  void _tryRegister() async {
    registerUser = User(
      Constants.mac,
      _emailController.text,
      _passwordController.text,
      utf8.encode(_nameController.text).toString(),
      _phoneNumberController.text,
      utf8.encode(_addressController.text).toString(),
      '',
      permissionValue,
      '',
    );
    registerUser.maph = registerUser.user;
    if (widget.isAdmin) {
      pubTopic = REGISTER_USER;
    } else {
      List<String> mahs = List();
      students.forEach((element) {
        if (element.isSelected) {
          mahs.add(element.mahs);
        }
      });
      registerUser.mahs = mahs;
      pubTopic = REGISTER_PARENT;
    }
    publishMessage(pubTopic, jsonEncode(registerUser));
  }

  register(String message) {
    Map responseMap = jsonDecode(message);

    switch (pubTopic) {
      case REGISTER_PARENT:
        if (responseMap['result'] == 'true') {
          print('Signup success');
          Navigator.of(context).pop();
        } else {
          _showToast(context);
        }
        break;
      case REGISTER_USER:
        if (responseMap['result'] == 'true') {
          print('Signup success');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                        registerUser: registerUser,
                      )));
        } else {
          _showToast(context);
        }
        break;
      case GET_STUDENT:
        var response = DeviceResponse.fromJson(responseMap);
        students = response.id.map((e) => Student.fromJson(e)).toList();
        setState(() {});
        hideLoadingDialog();
        break;
      case GET_CLASS:
      case GET_CLASS_BY_GRADE:
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

  void _showToast(BuildContext context) {
    Dialogs.showAlertDialog(context, 'Đăng ký thất bại, vui lòng thử lại sau!');
  }
}
