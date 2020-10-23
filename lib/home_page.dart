import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:smartid_map/secrets.dart';
import 'package:smartid_map/user_profile_page.dart';

import 'file:///E:/KhanhLH/AndroidStudioProjects/my_first_flutter_project/lib/helper/constants.dart'
    as Constants;

import 'helper/mqttClientWrapper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  HomePage({Key key, this.loginResponse}) : super(key: key);

  final Map loginResponse;

  @override
  _HomePageState createState() => _HomePageState(loginResponse);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  _HomePageState(this.loginResponse);

  final Map loginResponse;
  String iduser;

  MQTTClientWrapper mqttClientWrapper;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn thoát ứng dụng ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                // Navigator.of(context).pop(true),
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        _onWillPop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            // Text('Back',
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.white))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initMqtt();
    WidgetsBinding.instance.addObserver(this);
    // response = DeviceResponse.fromJson(loginResponse);
    // iduser = response.message;
    // devices = response.id.map((e) => Device.fromJson(e)).toList();
    // devices.forEach((element) {
    //   if (element.trangthai == 'BAT') {
    //     element.isEnable = true;
    //   } else {
    //     element.isEnable = false;
    //   }
    // });
    // mqttClientWrapper =
    //     MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    // mqttClientWrapper.prepareMqttClient(Constants.mac);

    // initMqtt();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed) {
        print('HomePageLifeCycleState : $state');
        initMqtt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Home Page';

    return MaterialApp(
      title: 'Geolocation Google Maps Demo',
      home: MapView(),
    );
  }

  Widget _upperContainer() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hello Khanh!',
                    style: TextStyle(color: Colors.white, fontSize: 26),
                  ),
                ],
              ),
              GestureDetector(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://store.playstation.com/store/api/chihiro/00_09_000/container/US/en/999/UP1018-CUSA00133_00-AV00000000000015/1553561653000/image?w=256&h=256&bg_color=000000&opacity=100&_version=00_09_000'),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => UserProfilePage()));
                },
              )
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.circular(25)),
                child: Icon(
                  Icons.power,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '7.9',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'kwh',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Text(
                    'Điện năng tiêu thụ trong ngày',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _roomLabel(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Color(0xffb2b0b9), fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);

    // if (responseMap['result'] == 'true') {
    //   response = DeviceResponse.fromJson(loginResponse);
    //   devices.clear();
    //   devices = response.id.map((e) => Device.fromJson(e)).toList();
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

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final snackBar = SnackBar(
      content: Text('Đăng nhập thất bại!'),
      action: SnackBarAction(
        label: 'Quay lại',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    scaffold.showSnackBar(snackBar);
  }
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  Position _currentPosition;
  String _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  var latTemp = 20.989592;
  var lonTemp = 105.785735;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
            : startPlacemark[0].position;
        Position destinationCoordinates = destinationPlacemark[0].position;

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            // destinationCoordinates.latitude,
            // destinationCoordinates.longitude,
            latTemp,
            lonTemp,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
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
                // _southwestCoordinates.latitude,
                // _southwestCoordinates.longitude,
                latTemp,
                lonTemp,
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
          print('DISTANCE: $_placeDistance km');
        });

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
      PointLatLng(latTemp, lonTemp),
      travelMode: TravelMode.transit,
    );

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
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show zoom buttons
            SafeArea(
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
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
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
                              label: 'Start',
                              hint: 'Choose starting point',
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
                              label: 'Destination',
                              hint: 'Choose destination',
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
                              'DISTANCE: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          RaisedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    setState(() {
                                      if (markers.isNotEmpty) markers.clear();
                                      if (polylines.isNotEmpty)
                                        polylines.clear();
                                      if (polylineCoordinates.isNotEmpty)
                                        polylineCoordinates.clear();
                                      _placeDistance = null;
                                    });

                                    _calculateDistance().then((isCalculated) {
                                      if (isCalculated) {
                                        _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Distance Calculated Sucessfully'),
                                          ),
                                        );
                                      } else {
                                        _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error Calculating Distance'),
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
                                'Show Route'.toUpperCase(),
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
            ),
            // Show current location button
            SafeArea(
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
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

class SnackBarPage extends StatelessWidget {
  final String data;
  final String buttonLabel;

  SnackBarPage(this.data, this.buttonLabel);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          final snackBar = SnackBar(
            content: Text(data),
            action: SnackBarAction(
              label: buttonLabel,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        },
        child: Text('Show SnackBar'),
      ),
    );
  }
}
