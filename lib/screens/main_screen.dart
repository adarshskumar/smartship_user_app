import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Utils/utils.dart';
import '../components/custom_loadingBAR.dart';
import '../components/loading_warpper.dart';
import '../constant/constant.dart';
import '../screens/map_screen.dart';
import '../services/database_service.dart';

class MainScreen extends StatefulWidget {
  static String route = '/mainScreen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<Map<String, dynamic>> myProject;
  bool isLoading = false;
  DatabaseService databaseService = new DatabaseService();
  Utils utils = new Utils();

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
//    myProject = await databaseService.getMyService();
//    print(myProject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Project"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder<List<dynamic>>(
          future: databaseService.getMyService(),
          builder: (context, snapshot) {
            print("Test");
            print(snapshot.data);
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                print(snapshot.data);
                return Center(
                  child: GestureDetector(
                    onTap: () async {
                      var permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                      }
//                      Navigator.push(context,MaterialPageRoute(builder: (context){
//                        return MapScreen(vehicleData: snapshot.data[1],
//                        projectData: snapshot.data[0],);
//                      }),);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: RouteSettings(name: MapScreen.route),
                          builder: (context) => MapScreen(
                            vehicleData: snapshot.data[1],
                            projectData: snapshot.data[0],
                            projectId: snapshot.data[2],
                            vehicleId: snapshot.data[3],
                          ),
                        ),
                      );
//                      Navigator.pushNamed(context,MapScreen.route,arguments: MapScreen(
//                        vehicleData: snapshot.data[1],
//                        projectData: snapshot.data[0],
//                      ));
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: 200.0,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              boxShadow: KStandardBoxShadow,
                              color: Colors.white),
                          alignment: Alignment.center,
                          child: Text(
                            snapshot.data[0]['Business unit'],
                            style: KCardHeadingTextStyle,
                          ),
                        ),
                        Positioned(
                            left: 0,
                            top: 0,
                            child: snapshot.data[1]['emergency']
                                ? Container(
                                    color: Colors.red,
                                    padding: EdgeInsets.all(5.0),
                                    margin: EdgeInsets.all(10.0),
                                    child: Text(
                                      'Emergency',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Container()),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 170.0,
                  margin: EdgeInsets.all(20.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.blueGrey.shade100,
                        offset: Offset(10, 10),
                        blurRadius: 10.0)
                  ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No project assigned',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 25.0),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'No project has been assigned to your vehicle , Please contact the admin.',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.5)),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          padding: EdgeInsets.all(3.0),
                          color: Colors.white,
                          child: Text(
                            'Retry',
                            style: TextStyle(color: kThemeBlueColor),
                          ),
                          onPressed: () {
                            setState(() {});
                          },
                        ),
                      )
                    ],
                  ),
                );
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
