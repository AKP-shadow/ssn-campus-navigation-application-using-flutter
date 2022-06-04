import 'dart:convert';
import 'dart:io';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/secrets.dart'; // Stores the Google Maps API Key
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui';
// import 'stream';
import 'package:csv/csv.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final locations = File('./assets/data/location.csv').readAsLinesSync();
  var location_details = [];
  _get_location_details(String place) {
    for (String line in locations) {
      final values = line.split(',');
      if (place == values[0]) {
        return [values[0], values[1]];
      }
      // location_details.add({
      //   values[0]: [values[1], values[2]],
      // });
    }
    // print(location_details);
    // return location_details;
  }

  // List<String> items = [
  //   'Department of Information Technology',
  //   'Department of Computer Science Engineering',
  //   'Department of Electronics and Communications Engineering',
  //   'Department of Electrical and Electronics  Engineering',
  //   'Department of Chemical  Engineering',
  //   'Department of Biomedical  Engineering',
  //   'Department of Civil Engineering',
  //   'Department of Mechanical Engineering',
  //   'Fountain',
  //   'Admin Block',
  //   'SSN Clinic',
  //   'Mini Auditorium',
  //   'Main Auditorium',
  //   'Rishaabs Foods',
  //   'Snow Cube Foods',
  //   'Main Canteen',
  //   'Vishvaas Needs Store',
  // ];
  late String dropdownvalue = "Select Destination";
  CameraPosition _initialLocation = CameraPosition(
      target: LatLng(12.752725872023166, 80.19659423867354), zoom: 18);
  late GoogleMapController mapController;

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};
  // markers.add(Marker)
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
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
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // This function is triggered when the floating button is pressed
  // final input = new File('assets/data/marker_loc.csv').openRead();
  // late final fields = input
  //     .transform(utf8.decoder)
  //     .transform(new CsvToListConverter())
  //     .toList();
  // Future<List<List>> _data = fields;

  // _loadAsset() async {
  //   final myData = await rootBundle.loadString("assets/Book1.csv");
  //   List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);

  //   data = csvTable;};

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
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
      List<Placemark> p = await placemarkFromCoordinates(
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
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      late String dropdownvalue = 'Clock Tower';
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      // Marker destinationMarker = Marker(
      //   markerId: MarkerId(destinationCoordinatesString),
      //   position: LatLng(destinationLatitude, destinationLongitude),
      //   infoWindow: InfoWindow(
      //     title: 'Destination $destinationCoordinatesString',
      //     snippet: _destinationAddress,
      //   ),
      //   icon: BitmapDescriptor.defaultMarker,
      // );

      // Adding the markers to the list
      // _addmarker(LatLng(12.75122381,80.19693846))
      // markers.add(startMarker);
      // markers.add(destinationMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      //Adding markers
      // void _onMapCreated(GoogleMapController controller, String marker_label) {
      //   mapController = controller;

      //   final marker = Marker(
      //     markerId: MarkerId('place_name'),
      //     position: LatLng(9.669111, 80.014007),
      //     // icon: BitmapDescriptor.,
      //     infoWindow: InfoWindow(
      //       title: 'title',
      //       snippet: 'address',
      //     ),
      //   );

      //   setState(() {
      //     markers[MarkerId('place_name')] = marker;
      //   });
      // }

      Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

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
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
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
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onLongPress: _addmarker,
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
                        color: Colors.blue.shade100, // button color
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
                        color: Colors.blue.shade100, // button color
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
                            'FindBear',
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
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),

                          DropdownButton<String>(
                              focusColor: Color(6),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              value: dropdownvalue,
                              hint: Text('Select destination'),
                              items: <String>[
                                'Department of Information Technology',
                                'Department of Computer Science Engineering',
                                'Department of Electronics and Communications Engineering',
                                'Department of Electrical and Electronics  Engineering',
                                'Department of Chemical  Engineering',
                                'Department of Biomedical  Engineering',
                                'Department of Civil Engineering',
                                'Department of Mechanical Engineering',
                                'Fountain',
                                'Admin Block',
                                'SSN Clinic',
                                'SNU',
                                'Mini Auditorium',
                                'Main Auditorium',
                                'Rishaabs Foods',
                                'Snow Cube Foods',
                                'Main Canteen',
                                'Vishvaas Needs Store',
                              ].map((String items) {
                                return DropdownMenuItem<String>(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? newvalue) {
                                setState(() {
                                  dropdownvalue = newvalue!;
                                  _destinationAddress =
                                      _get_location_details(newvalue);
                                });
                              }),
                          // _textField(
                          //     label: 'Destination',
                          //     hint: 'Choose destination',
                          //     prefixIcon: Icon(Icons.looks_two),
                          //     controller: destinationAddressController,
                          //     focusNode: desrinationAddressFocusNode,
                          //     width: width,
                          //     locationCallback: (String value) {
                          //       setState(() {
                          //         _destinationAddress = value;
                          //       });
                          //     }),
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
                          ElevatedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    startAddressFocusNode.unfocus();
                                    desrinationAddressFocusNode.unfocus();
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Distance Calculated Sucessfully'),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error Calculating Distance'),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                : null,
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
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
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
                      color: Colors.orange.shade100, // button color
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

  late Marker _origin;
  late Marker _destination;

  void _addmarker(LatLng pos) {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: MarkerId("it_dept1"),
          position: pos,
          infoWindow: InfoWindow(
            title: 'Department of Information Technology',
            // snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: MarkerId("it_dept1"),
          position: pos,
          infoWindow: InfoWindow(
            title: 'Department of Information Technology',
            // snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });
    }
  }
}
