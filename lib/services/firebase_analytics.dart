import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:platform_device_id/platform_device_id.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static void getUser() {
    PlatformDeviceId.getDeviceId
        .then((value) => analytics.setUserId(id: value));
  }

  static void getDeviceInfo() {
    PlatformDeviceId.deviceInfoPlugin.androidInfo.then((value) {
      analytics.logEvent(name: "device_and_os_information", parameters: {
        "androidId": value.androidId,
        "board": value.board,
        "bootloader": value.bootloader,
        "brand": value.brand,
        "device": value.device,
        "display": value.display,
        "hardware": value.hardware,
        "host": value.host,
        "id": value.id,
        "manufacturer": value.manufacturer,
        "model": value.model,
        "product": value.product,
        "tags": value.tags,
        "type": value.type,
        "isPhysicalDevice": value.isPhysicalDevice.toString(),
        "version": value.version.release,
      });
    });
  }
}
