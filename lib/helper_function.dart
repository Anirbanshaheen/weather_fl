import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getFormattedData (num date, String pattern) {
  return DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(date.toInt() * 1000)); // 1 Sec = 1000 milliSecond
}

Future<bool> setTempStatus(bool status) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.setBool('status', status);
}

Future<bool> getTempStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('status') ?? false;
}

Future<Position> determinePosition() async {
  //bool serviceEnabled;
  LocationPermission permission;
  //var permissionStatus = await Permission.location.request();

  // Test if location services are enabled.

  /*if (permissionStatus == PermissionStatus.granted) {

  } else if (permissionStatus == PermissionStatus.denied) {

  }*/

  //serviceEnabled = await Geolocator.isLocationServiceEnabled();
  /*if (!serviceEnabled) {

    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }*/

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<bool> isConnectedToInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
}