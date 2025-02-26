import 'package:cubes_n_slice/models/dto/my_orders.dart';
import 'package:cubes_n_slice/models/source/remote/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OrderRepository {
  Future<List<Order>> getAllOrders();

  Future<Order?> getOrderById({required String orderId});

  Future<String?>? cancelOrder(
      {required String orderId, required String cancelReason});
}

class OrderRepositoryImpl implements OrderRepository {
  final Api _api;

  OrderRepositoryImpl({
    required Api api,
  }) : _api = api;

  @override
  Future<List<Order>> getAllOrders() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken");
    return await _api.getAllOrders(token: token!);
  }

  @override
  Future<String?>? cancelOrder(
      {required String orderId, required String cancelReason}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken");
    return _api.cancelOrder(
        token: token!, orderId: orderId, reason: cancelReason);
  }

  @override
  Future<Order?> getOrderById({required String orderId}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken");
    return _api.getOrderById(token: token!, orderId: orderId);
  }
}
