import 'package:cubes_n_slice/models/dto/my_orders.dart';
import 'package:get/get.dart';

import '../models/OrderRepositoryImpl.dart';

class OrderViewModel extends GetxController {
  final OrderRepository _orderRepository;

  OrderViewModel({required OrderRepository orderRepositoryImpl})
      : _orderRepository = orderRepositoryImpl;

  Future<List<Order>> getAllOrders() {
    return _orderRepository.getAllOrders();
  }

  Future<String?>? cancelOrder(
      {required String orderId, required String cancelReason}) {
    return _orderRepository.cancelOrder(
        orderId: orderId, cancelReason: cancelReason);
  }

  Future<Order?> getOrderById({required String orderId}) async {
    return await _orderRepository.getOrderById(orderId: orderId);
  }
}
