import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateController extends GetxController {
  final Rxn<AppUpdateInfo> _updateInfo = Rxn<AppUpdateInfo>();

  bool _isChecking = false;


  Future<void> checkAppUpdate() async {

    if(kDebugMode){return;}

    if (_isChecking) return;

    _isChecking = true;
    final appInfo = await InAppUpdate.checkForUpdate().whenComplete(() {
      _isChecking = false;
    });
    _updateInfo.value = appInfo;

    if (appInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.performImmediateUpdate();
    }
  }
}