import 'package:geolocator/geolocator.dart';
import 'package:great_circle_distance2/great_circle_distance2.dart';

class LocationService {
  Future<Position> getMyLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   return Future.error('Location services are disabled.');
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.deniedForever) {
    //   return Future.error(
    //       'Location permissions are permantly denied, we cannot request permissions.');
    // }

    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission != LocationPermission.whileInUse &&
    //       permission != LocationPermission.always) {
    //     return Future.error(
    //         'Location permissions are denied (actual value: $permission).');
    //   }
    // }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  double getDifference(lat1, long1, lat2, long2) {
    print(lat1);
    print(long1);
    double distance = GreatCircleDistance.fromDegrees(
            latitude1: lat1,
            latitude2: lat2,
            longitude1: long1,
            longitude2: long2)
        .vincentyDistance();

    return distance;
  }

  Future<bool> verifyDistance(lat, long) async {
    var myPos = await getMyLocation();
    double diff = getDifference(myPos.latitude, myPos.longitude, lat, long);
    if (diff <= 50.0) {
      return true;
    } else {
      return false;
    }
  }
}
