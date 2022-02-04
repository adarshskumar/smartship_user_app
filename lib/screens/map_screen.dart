import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Utils/policy.dart';
import '../Utils/smart.dart';
import '../Utils/utils.dart';
import '../components/loading_warpper.dart';
import '../constant/constant.dart';
import '../screens/emergencyBreakdown_screen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

// API KEY = AIzaSyABOaKzPhGpPx89VcTk8bKoo8jh6gQcxxk
// Dibiyapur co-ordinates  = 26.629708817051203, 79.55114666372538

class MapScreen extends StatefulWidget {
  static String route = '/mapScreen';

  final vehicleData;
  dynamic projectData;
  final String projectId;
  final String vehicleId;
  MapScreen(
      {this.vehicleData, this.projectData, this.projectId, this.vehicleId});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Utils utils = new Utils();

  String searchText = "";
  bool isLoading = false;
  LatLng selectedLoc;
  bool inRide = false;
  bool isLoop = false;
  bool emergency = false;
  String serviceTitle = "Go";
  String tripDate;
  Map<String, dynamic> myLocation = {'lat': null, 'long': null};
  Map projectLocation = {};
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.32373608841897, -121.99228405952452),
    zoom: 12,
  );
  Set<Circle> circles;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDd0kfaaaa2a-W3IfTlXv2A68smycZqvjY";
  GoogleMapController mapController;
  String closingKm;
  String openReading;

  // Services
  LocationService locationService = new LocationService();
  DatabaseService databaseService = new DatabaseService();

  // Future<void> _goToPos(lat, long) async {
  //   CameraPosition target = CameraPosition(target: LatLng(lat, long), zoom: 12);
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(target));
  // }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3);
    setState(() {
      polylines[id] = polyline;
      isLoading = false;
    });
  }

  _getPolyline() async {
    print("poly fn");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(myLocation['lat'], myLocation['long']),
        PointLatLng(projectLocation['Lat'], projectLocation['Long']),
        travelMode: TravelMode.driving);
    polylines.clear();
    polylineCoordinates.clear();
    print("pints");
    print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  void initState() {
    // widget.projectData["Project Location"]["Lat"] = 28.7041;
    // widget.projectData["Project Location"]["Long"] = 77.1025;

    _loadData();
    print("Init state");

    super.initState();
  }

  final Set<Marker> _markers = {};
  addMarker(double latitude, double longitude) async {
    if (_markers.length >= 1) {
      _markers.clear();
    }
    _markers.add(Marker(
      markerId: MarkerId('SomeId'),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
    ));
    setState(() {});
  }

  void _loadData() async {
    if (widget.vehicleData['emergency']) {
      print("Loading emergency data");
      projectLocation['Lat'] = widget.vehicleData['emergencyLocation']['Lat'];
      projectLocation['Long'] = widget.vehicleData['emergencyLocation']['Long'];
      tripDate = widget.projectData['tripDate'];
      Smart.prefs.setString('tripDate', tripDate);
      emergency = true;
    } else {
      print("Loading normal data");
      projectLocation['Lat'] = widget.projectData['Project Location']['Lat'];
      projectLocation['Long'] = widget.projectData['Project Location']['Long'];
    }
    isLoop = widget.projectData['loop'];
    marker();
    _getMyLocation();
    setState(() {
      inRide = widget.vehicleData['InRide'];
      if (inRide) {
        serviceTitle = 'Logout';
      } else {
        serviceTitle = 'Go';
      }
    });
  }

  void marker() {
    addMarker(projectLocation['Lat'], projectLocation['Long']);
    circles = Set.from([
      Circle(
          circleId: CircleId("1"),
          center: LatLng(projectLocation['Lat'], projectLocation['Long']),
          radius: 50,
          strokeWidth: 0,
          fillColor: Colors.lightBlueAccent.shade100)
    ]);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _controller.complete(controller);
    //  await Future.delayed(Duration(seconds: 1, milliseconds: 1000));
    //  collapse();
  }

  void collapse() {
    print("collapse fn");
    List<LatLng> _latlanglist1 = [];
    _latlanglist1.add(LatLng(myLocation['lat'], myLocation['long']));
    _latlanglist1.add(LatLng(projectLocation['Lat'], projectLocation['Long']));
    Future.delayed(
        Duration(milliseconds: 200),
        () => mapController.animateCamera(CameraUpdate.newLatLngBounds(
            boundsFromLatLngList(_latlanglist1), 150)));
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  void handleService() async {
    switch (serviceTitle) {
      case 'Go':
        {
          await launch(
              'https://www.google.com/maps/search/?api=1&query=${projectLocation['Lat']},${projectLocation['Long']}');
          break;
        }
      case 'Login':
        {
          Utils utils = new Utils();
          openReading = await utils.showBottomDateSheet(context);
          if (openReading != null && inRide == false) {
            setState(() {
              isLoading = true;
            });
            print("open");
            print(openReading);
            bool check = false;
            if (!emergency && !widget.projectData["loop"]) {
              check = true;
            }
            print("check");
            print(check);
            String replacementFor;
            if (widget.vehicleData["ReplacementFor"] != null) {
              replacementFor = widget.vehicleData["ReplacementFor"];
            } else {
              replacementFor = "";
            }
            var res = await databaseService.startService(
                projectLocation['Lat'],
                projectLocation['Long'],
                openReading,
                widget.projectId,
                emergency,
                check,
                replacementFor);

            print("res");
            print(res);

            if (res) {
              setState(() {
                inRide = true;
                serviceTitle = 'Logout';
                isLoading = false;
                projectLocation['Lat'] =
                    widget.projectData['Project Location']['Lat'];
                projectLocation['Long'] =
                    widget.projectData['Project Location']['Long'];
              });
              if (emergency) {
                marker();
                _getMyLocation();
              }
              // _getMyLocation();
            } else {
              print("You are not in range");
//      utils.showMessageSnackBar(context, "You are not in range");
              utils.showMessageError(context, "You are not in range");
              setState(() {
                isLoading = false;
              });
            }
          }
          break;
        }
      case 'Logout':
        {
          Utils utils = new Utils();
          // await _getMyLocation();
          // double distance = locationService.getDifference(
          //     myLocation['lat'],
          //     myLocation['long'],
          //     projectLocation['Lat'],
          //     projectLocation['Long']);
          // print(distance);

          closingKm = await utils.showBottomDateSheet(context);
          print("closing");
          print(closingKm);
          if (closingKm != null && inRide == true) {
            setState(() {
              isLoading = true;
            });
            var res = await databaseService.logoutServiceWithLoop(
                projectLocation['Lat'],
                projectLocation['Long'],
                closingKm,
                widget.projectId,
                !widget.projectData["loop"]);

            print("res");
            print(widget.projectData["loop"]);
            print(res);
            if (res) {
              setState(() {
                inRide = true;
                isLoading = false;
              });
              //             Navigator.of(context).popUntil(ModalRoute.withName('/mainScreen'));
              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              utils.showMessageError(context, "You are not in range");
              setState(() {
                isLoading = false;
              });
            }
          }
        }
    }
  }

  _getMyLocation() async {
    print("getMyLocation");
    setState(() {
      isLoading = true;
    });
    var loc = await locationService.getMyLocation();
    print("Location ");
    print(loc.latitude);
    myLocation['lat'] = loc.latitude;
    myLocation['long'] = loc.longitude;
    print("collapse");
    collapse();
    print("poly");
    _getPolyline();
    // _goToPos(loc.latitude, loc.longitude);
  }

  _refreshData(BuildContext context) async {
    print("_refreshData");
    await _getMyLocation();
    print("debug");
    print(myLocation);
    print(projectLocation);
    double distance = locationService.getDifference(myLocation['lat'],
        myLocation['long'], projectLocation['Lat'], projectLocation['Long']);
    print(distance);
    if (emergency) {
      if (distance <= 50.0 || inRide) {
        if (serviceTitle == 'Go') {
          setState(() {
            serviceTitle = 'Login';
          });
        }
      } else {
        print("You are not in range");
//      utils.showMessageSnackBar(context, "You are not in range");
        utils.showMessageError(context, "You are not in range");
      }
    } else if (distance <= 50.0 || !widget.projectData["loop"]) {
      if (serviceTitle == 'Go') {
        setState(() {
          serviceTitle = 'Login';
        });
      } else {}
    } else {
      print("You are not in range");
//      utils.showMessageSnackBar(context, "You are not in range");
      utils.showMessageError(context, "You are not in range");
    }
  }

  void openTaxDialogBox(BuildContext context) {
    utils.showTaxDialogBox(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('SmartShip Logistics'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'Emergency') {
//                Navigator.pushNamed(context, EmergencyBreakdown.route);
//                Navigator.of(context)
//                    .popUntil(ModalRoute.withName('/mainScreen'));
                if (inRide) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EmergencyBreakdown(
                      projectId: widget.projectId,
                    );
                  }));
                } else {
                  utils.showSnackBar(_scaffoldKey, "First you have to login");
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Emergency',
                  child: Text('Emergency'),
                ),
              ];
            },
          ),
        ],
      ),
      body: LoadingWrapper(
        loading: isLoading,
        child: Container(
          child: Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: false,
                buildingsEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                zoomGesturesEnabled: true,
                myLocationEnabled: true,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: _onMapCreated,
                circles: circles,
                myLocationButtonEnabled: false,

                // onCameraMove: (CameraPosition cameraPosition) {
                //   selectedLoc = cameraPosition.target;
                // },
                markers: _markers,
              ),
              // Center(
              //     child: Container(
              //   height: 20.0,
              //   width: 20.0,
              //   decoration: BoxDecoration(
              //       color: Colors.blue,
              //       border: Border.all(color: Colors.white, width: 2.0),
              //       boxShadow: [
              //         BoxShadow(
              //             offset: Offset(5, 5),
              //             blurRadius: 10.0,
              //             color: Colors.blue.withOpacity(0.5)),
              //         BoxShadow(
              //             offset: Offset(-5, -5),
              //             blurRadius: 10.0,
              //             color: Colors.blue.withOpacity(0.5)),
              //         BoxShadow(
              //             offset: Offset(-5, 5),
              //             blurRadius: 10.0,
              //             color: Colors.blue.withOpacity(0.5)),
              //         BoxShadow(
              //             offset: Offset(5, -5),
              //             blurRadius: 10.0,
              //             color: Colors.blue.withOpacity(0.5))
              //       ],
              //       shape: BoxShape.circle),
              //   alignment: Alignment.center,
              // )),
              Positioned(
                bottom: 50.0,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    elevation: 10.0,
                    child: Text(
                      inRide ? 'Logout' : serviceTitle,
                      style: TextStyle(color: Colors.white),
                    ),
                    color: kThemeBlueColor,
                    onPressed: () async {
                      handleService();
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 50.0,
                right: 10.0,
                child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        boxShadow: KStandardBoxShadow,
                        color: Colors.white,
                        shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        _getMyLocation();
                      },
                      icon: Icon(
                        Icons.my_location,
                        color: kThemeBlueColor,
                        size: 30.0,
                      ),
                    )),
              ),
              Positioned(
                bottom: 110.0,
                right: 10.0,
                child: inRide
                    ? Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            boxShadow: KStandardBoxShadow,
                            color: Colors.white,
                            shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () {
                            openTaxDialogBox(context);
                          },
                          icon: Icon(
                            Icons.add,
                            color: kThemeBlueColor,
                            size: 30.0,
                          ),
                        ))
                    : Container(),
              ),
              Positioned(
                bottom: 50.0,
                left: 20.0,
                child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: KStandardBoxShadow),
                    child: IconButton(
                      onPressed: () async {
                        await _refreshData(context);
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: kThemeBlueColor,
                        size: 30.0,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
