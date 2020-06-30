import 'dart:isolate';
import 'dart:ui';

import 'package:geo_attendance_system/src/ui/constants/geofence_controls.dart';
import 'package:geo_attendance_system/src/ui/constants/strings.dart';
import 'package:geofencing/geofencing.dart';


class GeoFenceClass {
  static ReceivePort port = ReceivePort();
  static final GeoFenceClass _singleton = GeoFenceClass._internal();
  static var isolateSpawn ;
  static String geofenceState = 'Unknown';

  GeoFenceClass._internal();

  factory GeoFenceClass() {
    return _singleton;
  }

  static Future<void> startListening(double latitude, double longitude,
      [double radius = radius_geofence]) async {
    isolateSpawn =
        IsolateNameServer.registerPortWithName(port.sendPort, geofence_port_name);
    print(isolateSpawn);

    port.listen((dynamic data) {
      GeoFenceClass.geofenceState = data;
      print('Event: $data');
    });

    print(GeoFenceClass.geofenceState);

    await GeofencingManager.registerGeofence(
        GeofenceRegion(fence_id, latitude, longitude, radius, triggers,
            androidSettings: androidSettings),
        callback);


  }

  static void callback(List<String> ids, Location l, GeofenceEvent e) async {
    print('Fences: $ids Location $l Event: $e');
    final SendPort send =
        IsolateNameServer.lookupPortByName(geofence_port_name);
    send?.send(e.toString());
  }

  static void closePort() {
    port.close();
  }
}
