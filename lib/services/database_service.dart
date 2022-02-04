import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import '../Utils/smart.dart';
import '../services/location_service.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static SharedPreferences prefs;

  Future<List> getMyService() async {
    var db = Firestore.instance;
    print("Get my service");
//    var auth = FirebaseAuth.instance;
//    var user = await auth.currentUser;
//    var myPhone = await user.phoneNumber;

    var myPhone = prefs.getString('myNumber');
    print("MyNumber $myPhone");
    var vehicleId = await db.collection('registeredNumber').doc(myPhone).get();
    var id = vehicleId.data()['vehicleId'];
    var vehicleData = await db.collection('vehicleData').doc(id).get();
    if (vehicleData.data()['enable'] == false) {
      return null;
    }
    if (vehicleData.data()['projectId'] != null) {
      var projectData = await db
          .collection('projectData')
          .doc(vehicleData.data()['projectId'])
          .get();
      return [
        projectData.data(),
        vehicleData.data(),
        projectData.id,
        vehicleData.id
      ];
    } else {
      return null;
    }
  }

  Future<bool> startService(
      projectLat,
      projectLang,
      String startKM,
      String projectId,
      bool isEmergency,
      bool check,
      String replacementFor) async {
    prefs = await SharedPreferences.getInstance();
    LocationService locationService = new LocationService();
    bool isNear = await locationService.verifyDistance(projectLat, projectLang);
    if (isNear || check) {
      try {
        Uuid uuid = new Uuid();
        String tripId = uuid.v1();
        var db = FirebaseFirestore.instance;
        var myPhone = prefs.getString('myNumber');
        var vehicleId =
            await db.collection('registeredNumber').doc(myPhone).get();
        var id = vehicleId.data()['vehicleId'];
        var date = DateTime.now();
        String tripDate = '${date.year}:${date.month}:${date.day}';
        await db
            .collection('vehicleData')
            .doc(id)
            .update({'InRide': true, 'tripId': tripId, 'tripDate': tripDate});
        await db
            .collection('TripData')
            // .doc(tripDate)
            // .collection('data')
            .doc(tripId)
            .set({
          'startKM': startKM,
          'vehicleId': id,
          'projectId': projectId,
          'startTime': DateTime.now(),
          'Toll tax': 0,
          'Parking tax': 0,
          'Other tax': 0,
          'Lorry receipt no': 0,
          'endTime': null,
          'Gate pass no': 0,
          'ReplacementFor': replacementFor
        });
        await db.collection('Dates').doc(tripDate).set({'date': tripDate});
        //  await db.collection('TripData').doc(tripDate).set({'1': 1});
        prefs.setString('tripId', tripId);
        prefs.setString('tripDate', tripDate);
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> logoutServiceWithLoop(projectLat, projectLang, String stopKM,
      String projectId, bool choice) async {
    LocationService locationService = new LocationService();
    bool isNear = await locationService.verifyDistance(projectLat, projectLang);
    if (isNear || choice) {
      try {
        //  Position myPos = await locationService.getMyLocation();
        var db = FirebaseFirestore.instance;
        var myPhone = prefs.getString('myNumber');
        var vehicleId =
            await db.collection('registeredNumber').doc(myPhone).get();
        var id = vehicleId.data()['vehicleId'];
        String tripId = prefs.getString('tripId');
        // String tripDate = Smart.prefs.getString('tripDate');
        var date = DateTime.now();
        String tripDate = '${date.year}:${date.month}:${date.day}';
        await db.collection('vehicleData').doc(id).update(
            {'InRide': false, 'emergency': false, "ReplacementFor": null});

        await db
            .collection('TripData')
            // .doc(tripDate)
            // .collection('data')
            .doc(tripId)
            .update({'endKM': stopKM, 'endTime': date});
        await db.collection('Dates').doc(tripDate).set({'date': tripDate});
        prefs.setString('tripId', null);
        prefs.setString('tripDate', null);
        // DateFormat.yMMMd().format(tripList.elementAt(index));
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> logoutServiceWithoutLoop(projectLat, projectLang) async {
    if (true) {
      try {
        var db = FirebaseFirestore.instance;
        var myPhone = prefs.getString('myNumber');
        var vehicleId =
            await db.collection('registeredNumber').doc(myPhone).get();
        var id = vehicleId.data()['vehicleId'];
        await db.collection('vehicleData').doc(id).update({'InRide': false});
        return true;
      } catch (e) {
        return false;
      }
    }
  }

//  Future<String> writeStartData(proejectId,data)async{
//    var uuid = Uuid();
//    String id = uuid.v1();
//    var db = FirebaseFirestore.instance;
//    await db.collection('tripData').doc(id).set(data);
//    return id;
//  }
//
//  Future<String> writeEndData(projectId,data)async{
//    var uuid = Uuid();
//    String id = uuid.v1();
//    var db = FirebaseFirestore.instance;
////    await db.collection('tripData').doc(projectId).collection();
//    return id;
//  }

  Future<bool> emergencyBreakdown(
      String projectId, String breakDownKm, String reason) async {
    print(prefs.getString('tripId'));
    print(prefs.getString('tripDate'));
    String vehicleId = prefs.getString('vehicleId');
    var db = FirebaseFirestore.instance;
    LocationService locationService = new LocationService();
    Position myPos = await locationService.getMyLocation();
    var date = DateTime.now();
    String tripDate = '${date.year}:${date.month}:${date.day}';
    await db.collection('emergency').add({
      'vehicleId': vehicleId,
      'projectId': projectId,
      'breakDownLat': myPos.latitude,
      'breakDownLong': myPos.longitude,
      'tripDate': prefs.get('tripDate'),
      'replacement': vehicleId,
      'active': true,
      'reason': reason
    });
    await db.collection('Dates').doc(tripDate).set({'date': tripDate});
    await db
        .collection('vehicleData')
        .doc(prefs.getString('vehicleId'))
        .update({'InRide': false, 'breakdown': true});
    await db
        .collection('TripData')
        // .doc(Smart.prefs.getString('tripDate'))
        // .collection('data')
        .doc(prefs.getString('tripId'))
        .update({
      'endKM': breakDownKm,
      'endTime': DateTime.now(),
      'replacement': prefs.getString('vehicleNo')
    });
    // await db.collection('projectData').doc(projectId).update({
    //   'vehicles': FieldValue.arrayRemove([vehicleId])
    // });
    return true;
  }

  Future<int> userLogin(String number) async {
    prefs = await SharedPreferences.getInstance();
    var db = FirebaseFirestore.instance;
    var userData = await db.collection('registeredNumber').doc(number).get();

    if (userData.data() != null) {
      var vehicleData = await db
          .collection('vehicleData')
          .doc(userData.data()['vehicleId'])
          .get();
      if (vehicleData.data()['breakdown']) {
        return 2;
      }
      if (vehicleData.data()['InRide'] == true) {
        prefs.setString('tripDate', vehicleData.data()['tripDate']);
      }
      prefs.setString('myNumber', number);
      prefs.setString('vehicleId', userData.data()['vehicleId']);
      prefs.setString('vehicleNo', vehicleData.data()['Vehicle no']);
      return 0;
    } else {
      return 1;
    }
  }

  Future<void> submitTax(String taxName, String amount) async {
    String tripId = prefs.getString('tripId');
    String tripDate = prefs.getString('tripDate');
    var db = FirebaseFirestore.instance;
    await db
        .collection('TripData')
        // .doc(tripDate)
        // .collection('data')
        .doc(tripId)
        .update({taxName: FieldValue.increment(int.parse(amount))});
    return;
  }
}
