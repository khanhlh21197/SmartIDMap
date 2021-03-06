import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartid_map/helper/constants.dart' as Constants;
import 'package:smartid_map/helper/mqttClientWrapper.dart';
import 'package:smartid_map/helper/response/device_response.dart';
import 'package:smartid_map/helper/shared_prefs_helper.dart';
import 'package:smartid_map/secrets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'helper/models.dart';
import 'model/student.dart';
import 'model/thietbi.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const GET_STUDENT = 'getHS';
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  Position _currentPosition;
  Position _busPosition;
  String _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;
  BitmapDescriptor customIcon;

  String pubTopic;
  String sdtgs;
  String sdtlx;

  var latTemp = 20.999855;
  var lonTemp = 105.723318;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  List<Student> students = List();
  var dropDownStudents = ['   '];
  var studentID;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _dropDownStudent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              "Chọn HS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: studentID,
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
                  studentID = data;
                  print(studentID);
                });
              },
              items: dropDownStudents
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  void getStudentId() async {
    ThietBi t = ThietBi('', '', '', '', '', Constants.mac);
    pubTopic = GET_STUDENT;
    publishMessage(pubTopic, jsonEncode(t));
  }

  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Placemark> startPlacemark =
          await _geolocator.placemarkFromAddress(_startAddress);
      List<Placemark> destinationPlacemark =
          await _geolocator.placemarkFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : _busPosition;
        // Position destinationCoordinates = destinationPlacemark[0].position;
        Position destinationCoordinates =
            Position(latitude: latTemp, longitude: lonTemp);

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Vị trí của bạn',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
            // latTemp,
            // lonTemp,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that
        // southwest coordinate <= northeast coordinate
        if (startCoordinates.latitude <= destinationCoordinates.latitude) {
          _southwestCoordinates = startCoordinates;
          _northeastCoordinates = destinationCoordinates;
        } else {
          _southwestCoordinates = destinationCoordinates;
          _northeastCoordinates = startCoordinates;
        }

        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
                // latTemp,
                // lonTemp,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('Khoảng cách: $_placeDistance km');
          print('polylines: ${polylineCoordinates.length}');
        });

        final double distance = await Geolocator().distanceBetween(
            startCoordinates.latitude,
            startCoordinates.longitude,
            destinationCoordinates.latitude,
            destinationCoordinates.longitude);
        print('Distance: ${distance / 1000}');

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      // PointLatLng(destination.latitude, destination.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    print('result : ${result.points.length}');
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    initMqtt();
    getSharedPrefs();
    _getCurrentLocation();
    _busPosition = Position(
      latitude: 20.9862851635164,
      longitude: 105.78253055508404,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(12, 12)),
        'assets/icons/bus.png',
      );
      setState(() {});
    });
    super.initState();
  }

  void getSharedPrefs() async {
    sharedPrefsHelper = SharedPrefsHelper();
    sdtgs = await sharedPrefsHelper.getStringValuesSF('sdtgs') ?? '0963003197';
    sdtlx = await sharedPrefsHelper.getStringValuesSF('sdtlx') ?? '0963003197';
  }

  Future<void> busMoving() async {
    List<Position> positions = [
      //
      Position(
        latitude: 20.986220258323666,
        longitude: 105.78295123736535,
      ),
      //
      Position(
        latitude: 20.98541888371997,
        longitude: 105.7820285574718,
      ),
      //
      Position(
        latitude: 20.98484790169856,
        longitude: 105.78112733525663,
      ),
      //
      Position(
        latitude: 20.98541888371997,
        longitude: 105.78068745298496,
      ),
      //
      Position(
        latitude: 20.986370515572155,
        longitude: 105.77981841727745,
      ),
      //
      Position(
        latitude: 20.987282073029398,
        longitude: 105.77898156807765,
      ),
      //
      Position(
        latitude: 20.98806340356485,
        longitude: 105.77983987494925,
      ),
      //
      Position(
        latitude: 20.988674441274906,
        longitude: 105.78066599532109,
      ),
      //
      Position(
        latitude: 20.989495832301422,
        longitude: 105.78186762495648,
      ),
      //
      Position(
        latitude: 20.99044743819112,
        longitude: 105.78320872944974,
      ),
      //
      Position(
        latitude: 20.991108550336055,
        longitude: 105.78414213820093,
      ),
      //
      Position(
        latitude: 20.99230054808303,
        longitude: 105.78611624401135,
      ),
      //
      Position(
        latitude: 20.99341240294214,
        longitude: 105.7883049265339,
      ),
    ];
    for (final position in positions) {
      await Future.delayed(Duration(seconds: 5));
      _busPosition = position;
      markers.clear();
      markers.add(Marker(
          markerId: MarkerId(_busPosition.longitude.toString()),
          position: LatLng(_busPosition.latitude, _busPosition.longitude),
          // infoWindow: InfoWindow(title: address, snippet: "go here"),
          icon: customIcon));
      setState(() {});
      animateCamera(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    print('_MapViewState.build ${dropDownStudents.length}');
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            dropDownStudents.length > 0
                ? FlatButton(onPressed: () {}, child: Text('ádfadsfasd'))
                : Container(),
            // Map View
            mapContainer(),
            // Show zoom buttons
            zoomButtons(),
            // Show the place input fields & button for
            // showing the route
            // directContainer(width),
            // Show current location button
            callDriverButton(),
            callMonitorButton(),
            currentLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget mapContainer() {
    print('_MapViewState.mapContainer ${markers.length}');
    markers.forEach((element) {});
    markers.isNotEmpty
        ? print(
            '_MapViewState.mapContainer ${markers.elementAt(0).position.toString()}, ${markers.elementAt(0).icon}, ${markers.elementAt(0).markerId}')
        : print('_MapViewState.mapContainer');
    return GoogleMap(
      gestureRecognizers: Set()
        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
      markers: markers != null ? Set<Marker>.from(markers) : null,
      myLocationEnabled: true,
      initialCameraPosition: _initialLocation,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      polylines: Set<Polyline>.of(polylines.values),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        markers.add(Marker(
            markerId: MarkerId(_busPosition.longitude.toString()),
            position: LatLng(_busPosition.latitude, _busPosition.longitude),
            // infoWindow: InfoWindow(title: address, snippet: "go here"),
            icon: customIcon));
        // busMoving();
      },
    );
  }

  Widget zoomButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Material(
                color: Colors.blue[100], // button color
                child: InkWell(
                  splashColor: Colors.blue, // inkwell color
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.add),
                  ),
                  onTap: () {
                    mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ClipOval(
              child: Material(
                color: Colors.blue[100], // button color
                child: InkWell(
                  splashColor: Colors.blue, // inkwell color
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.remove),
                  ),
                  onTap: () {
                    mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget directContainer(double width) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            width: width * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Places',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 10),
                  _textField(
                      label: 'Vị trí của bạn',
                      hint: 'Chọn điểm bắt đầu',
                      prefixIcon: Icon(Icons.looks_one),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: () {
                          startAddressController.text = _currentAddress;
                          _startAddress = _currentAddress;
                        },
                      ),
                      controller: startAddressController,
                      width: width,
                      locationCallback: (String value) {
                        setState(() {
                          _startAddress = value;
                        });
                      }),
                  SizedBox(height: 10),
                  _textField(
                      label: 'Vị trí xe bus',
                      hint: 'Chọn điểm đến',
                      prefixIcon: Icon(Icons.looks_two),
                      controller: destinationAddressController,
                      width: width,
                      locationCallback: (String value) {
                        setState(() {
                          _destinationAddress = value;
                        });
                      }),
                  SizedBox(height: 10),
                  Visibility(
                    visible: _placeDistance == null ? false : true,
                    child: Text(
                      'Khoảng cách: $_placeDistance km',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  RaisedButton(
                    onPressed:
                        (_startAddress != '' && _destinationAddress != '')
                            ? () async {
                                setState(() {
                                  if (markers.isNotEmpty) markers.clear();
                                  if (polylines.isNotEmpty) polylines.clear();
                                  if (polylineCoordinates.isNotEmpty)
                                    polylineCoordinates.clear();
                                  _placeDistance = null;
                                });

                                _calculateDistance().then((isCalculated) {
                                  if (isCalculated) {
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Tính khoảng cách thành công'),
                                      ),
                                    );
                                  } else {
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text('Có lỗi xảy ra'),
                                      ),
                                    );
                                  }
                                });
                              }
                            : null,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Chỉ đường'.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget callMonitorButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 30.0),
          child: ClipOval(
            child: Material(
              color: Colors.red, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Giám sát',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  launch("tel://$sdtgs");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget callDriverButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 100.0),
          child: ClipOval(
            child: Material(
              color: Colors.green, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Lái xe',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  launch("tel://$sdtlx");
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget currentLocationButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
          child: ClipOval(
            child: Material(
              color: Colors.orange[100], // button color
              child: InkWell(
                splashColor: Colors.orange, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.my_location),
                ),
                onTap: () {
                  animateCamera(_currentPosition);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  animateCamera(Position position) {
    getBusLocation(position);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            position.latitude,
            position.longitude,
          ),
          zoom: 18.0,
        ),
      ),
    );
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient('gps');

    // getStudentId();
  }

  void handle(String message) {
    print('_HomePageState.handle $message');
    double lat = double.parse(message.split('&')[0]);
    double lon = double.parse(message.split('&')[1]);
    print('_HomePageState.handle $lat - $lon');
    animateCamera(Position(latitude: lat, longitude: lon));

    Map responseMap = jsonDecode(message);
    var response = DeviceResponse.fromJson(responseMap);

    switch (pubTopic) {
      case GET_STUDENT:
        students = response.id.map((e) => Student.fromJson(e)).toList();
        students.forEach((element) {
          dropDownStudents.add(element.tenDecode);
        });
        setState(() {});
        break;
    }
    pubTopic = '';
    // Map responseMap = jsonDecode(message);

    // if (responseMap['result'] == 'true') {
    //   helper.response = DeviceResponse.fromJson(loginResponse);
    //   devices.clear();
    //   devices = helper.response.id.map((e) => Device.fromJson(e)).toList();
    //
    //   devices.forEach((element) {
    //     if (element.trangthai == 'BAT') {
    //       element.isEnable = true;
    //     } else {
    //       element.isEnable = false;
    //     }
    //   });
    // }
  }

  getBusLocation(Position position) async {
    //call this async method from whereEver you need

    // LocationData myLocation;
    // String error;
    // Location location = new Location();
    // try {
    //   myLocation = await location.getLocation();
    // } on PlatformException catch (e) {
    //   if (e.code == 'PERMISSION_DENIED') {
    //     error = 'please grant permission';
    //     print(error);
    //   }
    //   if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
    //     error = 'permission denied- please enable it from app settings';
    //     print(error);
    //   }
    //   myLocation = null;
    // }
    // currentLocation = myLocation;
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    String printValue =
        // '${first.locality ?? ''} '
        // '${first.adminArea ?? ''}
        // ${first.subLocality ?? ''} '
        // '${first.subAdminArea ?? ''}'
        // '${first.featureName ?? ''} '
        '${first.addressLine ?? ''} ';
    // '${first.thoroughfare ?? ''} ';
    // '${first.subThoroughfare ?? ''}';
    print('_MapViewState.getBusLocation $printValue');
    Fluttertoast.showToast(msg: printValue);
    return first;
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

// Widget _searchMapPlace() {
//   return SearchMapPlaceWidget(
//     apiKey: Secrets.API_KEY,
//     language: 'en',
//     // The position used to give better recomendations. In this case we are using the user position
//     radius: 30000,
//     // location: userPosition.coordinates,
//     location: LatLng(20.9868276, 105.7826455),
//     onSelected: (Place place) async {
//       final geolocation = await place.geolocation;
//       print(geolocation.toString());
//
//       // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
//       final GoogleMapController controller = await mapController.future;
//       controller
//           .animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
//       controller
//           .animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
//     },
//   );
// }
}
