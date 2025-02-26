import 'dart:async';

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as reactive;

import '../models/dto/cart.dart';
import '../models/shopingCart_repo_impl.dart';
import '../utils/myStates.dart';
import 'network_error_controller.dart'; // Import the network controller

class CartIconModel extends GetxController {
  CartRepository _cartRepository;
  NetworkErrorController networkErrorController =
  Get.find(); // Inject the network controller

  CartIconModel({required CartRepository cartRepositoryImpl})
      : _cartRepository = cartRepositoryImpl;

  final _cartController = reactive.BehaviorSubject<int>.seeded(0);
  final StreamController<int> _cartStreamController = StreamController<int>();
  Stream<int> get cartUpdates => _cartController.stream;
  final RxMap<String, CartItem> _productCartMap = <String, CartItem>{}.obs;
  Map<String, CartItem> get productCartMap => _productCartMap;
  final cartCount = RxInt(0);
  final Rx<MyState> _cartState = MyState().obs;
  MyState get cartState => _cartState.value;

  Timer? _cartUpdateTimer;

  @override
  void dispose() async {
    _cartController.close();
    _cartStreamController.close();
    _cartUpdateTimer?.cancel(); // Cancel the timer on dispose
    super.dispose();
  }

  @override
  void onClose() {
    _cartController.close();
    _cartStreamController.close();
    _cartUpdateTimer?.cancel(); // Cancel the timer on close
    super.onClose();
  }

  void _updateCartLength() {
    _cartController.value = _productCartMap.length;
    print("updating cart ${_cartController.value}");
  }

  Future<List<CartItem>> getCartItemList() async {
    try {
      final CartData cartData = await _cartRepository.getCartItemList();
      if (cartData.cart.isNotEmpty) {
        _productCartMap.assignAll({
          for (var cartItem in cartData.cart) cartItem.id.toString(): cartItem
        });
      } else {
        _productCartMap.assignAll({});
      }
      _updateCartLength();
      return cartData.cart;
    } catch (e) {
      print('Error fetching cart data: $e');
      _cartState.value = FailureState("Something went Wrong");
      return [];
    }
  }

  void _startCartUpdateTimer() {
    _cartUpdateTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
          if (networkErrorController.isConnected.value) {
            // Check if network is connected
            await getCartItemList(); // This updates the cartCount
            _cartStreamController
                .add(cartCount.value); // Send the updated count to the stream
          } else {
            timer.cancel(); // Cancel the timer if disconnected
          }
        });
  }

  @override
  void onInit() {
    () async {
      await getCartItemList();
      _startCartUpdateTimer();
      ever(networkErrorController.isConnected, (connected) {
        if (connected) {
          // Restart the timer when network is restored
          _startCartUpdateTimer();
        }
      });
    }();
    super.onInit();
  }
}