import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkErrorController extends GetxController {
  final _hasNetworkError = false.obs;

  bool get hasNetworkError => _hasNetworkError.value;

  var isConnected = false.obs; // Observable to track connection status

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenToNetworkChanges();
  }

  void _checkInitialConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      isConnected.value = false;
    } else {
      isConnected.value = true;
    }
  }

  void _listenToNetworkChanges() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.first == ConnectivityResult.none) {
        isConnected.value = false;
      } else {
        isConnected.value = true;
      }
    });
  }

  // Function to check the network before making an API request
  bool canMakeRequest() {
    return isConnected.value;
  }

  void setNetworkError(bool value) {
    print("Network Error: $value");
    _hasNetworkError.value = value;
  }
}
