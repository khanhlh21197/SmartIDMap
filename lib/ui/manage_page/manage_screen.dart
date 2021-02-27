import 'package:flutter/material.dart';
import 'package:smartid_map/ui/manage_page/bus_list_screen.dart';
import 'package:smartid_map/ui/manage_page/device_list_screen.dart';
import 'package:smartid_map/ui/manage_page/driver_list_screen.dart';
import 'package:smartid_map/ui/manage_page/monitor_list_screen.dart';
import 'package:smartid_map/ui/manage_page/student_list_screen.dart';
import 'package:smartid_map/ui/manage_page/vehicle_list_screen.dart';

class ManageScreen extends StatefulWidget {
  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  String manageValue = 'Lái xe';
  List<String> manageValues = [
    'Lái xe',
    'Giám sát',
    'Xe',
    'Thiết bị',
    'Tuyến xe',
    'Học sinh'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý'),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          _dropDownManage(),
          manageContainer(),
        ],
      ),
    );
  }

  Widget manageContainer() {
    if (manageValue == manageValues[0]) return DriverListScreen();
    if (manageValue == manageValues[1]) return MonitorListScreen();
    if (manageValue == manageValues[2]) return VehicleListScreen();
    if (manageValue == manageValues[3]) return DeviceListScreen();
    if (manageValue == manageValues[4]) return BusListScreen();
    if (manageValue == manageValues[5]) return StudentListScreen();
    return Container();
  }

  Widget _dropDownManage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Chọn mục quản lý",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        DropdownButton<String>(
          value: manageValue,
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
              manageValue = data;
              print(manageValue);
              if (manageValue == manageValues[0]) {}
              if (manageValue == manageValues[1]) {}
              if (manageValue == manageValues[2]) {}
              if (manageValue == manageValues[3]) {}
            });
          },
          items: manageValues.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
      ],
    );
  }
}
