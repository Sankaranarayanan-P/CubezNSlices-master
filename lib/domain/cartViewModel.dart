import 'dart:async';

import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as reactive;

import '../models/dto/cart.dart';
import '../models/shopingCart_repo_impl.dart';
import '../utils/myStates.dart';

class ShoppingCartViewModel extends GetxController {
  CartRepository _cartRepository;
  ShoppingCartViewModel({required CartRepository cartRepositoryImpl})
      : _cartRepository = cartRepositoryImpl;

  final _cartController = reactive.BehaviorSubject<int>.seeded(0);
  final StreamController<int> _cartStreamController = StreamController<int>();
  Stream<int> get cartUpdates => _cartController.stream;
  final RxMap<String, CartItem> _productCartMap = <String, CartItem>{}.obs;
  Map<String, CartItem> get productCartMap => _productCartMap;

  final Rx<MyState> _cartState = MyState().obs;
  MyState get cartState => _cartState.value;

  final grandTotal = RxString('');
  final baseAmount = RxString('');
  final disCountPrice = RxString('');
  final deliveryCharge = RxString('');
  final coupon = RxString('');
  final cartCount = RxInt(0);
  final outOfStock = RxBool(false);
  final coupons = RxList<Coupon>();
  final cancellationNote = RxString('');
  final platformFee = RxString('');
  final shippingAddress = RxMap<String, Address>();

  @override
  void dispose() async {
    _cartController.close();
    super.dispose();
  }

  @override
  void onClose() {
    _cartController.close();
    super.onClose();
  }

  void _updateCartLength() {
    _cartController.value = _productCartMap.length;
    print("updating cart ${_cartController.value}");
  }

  Future<Map<String, dynamic>> addToCart(CartItem cartItem) async {
    print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++...");
    print(cartItem.AvailableitemQuantity);
    print(cartItem.quantity);
    Map<String, dynamic> response = {};
    try {
      // print(_productCartMap.values);
      // if (_productCartMap.values.contains(cartItem)) {
      if (cartItem.AvailableitemQuantity < int.parse(cartItem.quantity!)) {
        int quantity = int.parse(cartItem.quantity!);
        quantity += 1;
        cartItem.quantity = quantity.toString();
        print(cartItem.AvailableitemQuantity);
        response = await _cartRepository.insertCartItem(cartItem);
        // Get.snackbar("Added to Cart", "");
      } else {
        response = await _cartRepository.insertCartItem(cartItem);
      }
      if (response['response'].toString().toLowerCase() == "success") {
        try {
          _productCartMap.update(cartItem.id!, (value) => cartItem);
        } catch (e) {
          _productCartMap.putIfAbsent(cartItem.id.toString(), () => cartItem);
        }
        _updateCartLength();
      }
      // } else {
      //   _productCartMap.putIfAbsent(cartItem.id.toString(), () => cartItem);
      //   await _cartRepository.insertCartItem(cartItem);
      //   _updateCartLength();
      // }

      await getCartItemList();
    } catch (e) {
      print('Error adding to data in viewModel: $e');
    }
    return response;
  }

  Future<void> removeFromCart(CartItem cartItem,
      {bool removeAll = false}) async {
    try {
      if (removeAll == false &&
          _productCartMap.values.contains(cartItem) &&
          cartItem.AvailableitemQuantity > 1) {
        print("hello i am in if condition");
        int quantity = int.parse(cartItem.takenquantity!);
        cartItem.takenquantity = (quantity - 1).toString();

        _productCartMap.update(cartItem.id.toString(), (value) => cartItem);
        _updateCartLength();
      } else {
        print("hello i am in else condition");
        final updatedMap = Map<String, CartItem>.from(_productCartMap)
          ..removeWhere((key, value) => value == cartItem);
        print(updatedMap);
        _productCartMap.assignAll(updatedMap);
        _updateCartLength();
      }
      await _cartRepository.removeCartItem(
          cartItem: cartItem, removeAll: removeAll);
      await getCartItemList();
      _updateCartLength();
    } catch (e) {
      print('Error removing cartItem in viewModel: $e');
    }
  }

  Future<List<CartItem>> getCartItemList() async {
    try {
      _cartState.value = LoadingState();
      final CartData cartData = await _cartRepository.getCartItemList();

      if (cartData.cart.isNotEmpty) {
        _productCartMap.assignAll({
          for (var cartItem in cartData.cart) cartItem.id.toString(): cartItem
        });

        for (var carItem in cartData.cart) {
          coupon.value = carItem.coupon ?? "";
        }
        grandTotal.value = cartData.grandTotal;
        cartCount.value = cartData.cart.length;
        disCountPrice.value = cartData.discount;
        deliveryCharge.value = cartData.deliveryCharge;
        outOfStock.value = cartData.outOfStock == "YES";
        baseAmount.value = cartData.baseAmount;

        _cartState.value = LoadedState(cartData.cart);
      } else {
        _productCartMap.assignAll({});
        grandTotal.value = "₹0";
        cartCount.value = 0;
        disCountPrice.value = "₹0";
        deliveryCharge.value = "₹0";
        outOfStock.value = false;
        baseAmount.value = "₹0";
        coupon.value = "";
        _cartState.value = LoadedState([]);
      }
      _updateCartLength();
      return cartData.cart;
    } catch (e) {
      print('Error fetching cart data: $e');
      _cartState.value = FailureState("Something went Wrong");
      return [];
    }
  }

  // Future<List<CartItem>> getCartItemList() async {
  //   try {
  //     _cartState.value = LoadingState();
  //     final CartData cartData = await _cartRepository.getCartItemList();
  //
  //     if (cartData.cart.isNotEmpty) {
  //       // Update the productCartMap
  //       productCartMap.assignAll(
  //         {
  //           for (var cartItem in cartData.cart) cartItem.id.toString(): cartItem
  //         },
  //       );
  //
  //       // Update other cart information
  //       grandTotal.value = cartData.grandTotal;
  //       cartCount.value = cartData.cart.length;
  //       disCountPrice.value = cartData.discount;
  //       deliveryCharge.value = cartData.deliveryCharge;
  //       outOfStock.value = cartData.outOfStock == "YES" ? true : false;
  //       _cartState.value = LoadedState(cartData.cart);
  //       return cartData.cart;
  //     } else {
  //       _cartState.value = LoadedState(cartData.cart);
  //       productCartMap.clear();
  //     }
  //     _updateCartLength();
  //     return [];
  //   } catch (e) {
  //     print('Error fetching cart data: $e');
  //     _cartState.value = FailureState("Something went Wrong");
  //     return [];
  //   }
  // }

  Future<String> applyCoupon(String coupon) async {
    return await _cartRepository.applyCoupon(coupon);
  }

  Future<List<Map<dynamic, dynamic>>> getPaymentMethods() async {
    return await _cartRepository.getPaymentMethods();
  }

  Future<Map> checkCoupon(String coupon) async {
    return await _cartRepository.checkCoupon(coupon);
  }

  Future<Map> createOrder(
      {required String paymentMethod,
      required Map<String, dynamic> orderData}) async {
    return await _cartRepository.createOrder(
      paymentMethod: paymentMethod,
      orderData: orderData,
    );
  }

  Future<bool> updateOrderPayment(
      {required String orderId,
      required String status,
      String paymentId = ""}) async {
    return await _cartRepository.updatePaymentStatus(
        orderId: orderId, status: status, paymentId: paymentId);
  }

  Future<void> persistCartItems() async {
    try {
      await _cartRepository.saveCartItemList(_productCartMap.values.toList());
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  Future<List<Coupon>> getCoupons() async {
    List<Coupon> couponList = await _cartRepository.getCoupons();
    coupons.value = couponList;
    return couponList;
  }

  Future<Map<String, dynamic>> getCancellationNoteAndPlatformFee() async {
    Map<String, dynamic> noteAndFee =
        await _cartRepository.getCancellationNoteAndPlatformFee();
    cancellationNote.value = noteAndFee['cancellation_note'] ?? "";
    platformFee.value = noteAndFee['platform_fee'] ?? "";
    return noteAndFee;
  }

  Future<List<Address>> getAllAddress(
      {bool is_shipping = false, bool is_billing = false}) async {
    List<Address> addressList = await _cartRepository.getAllAddress(
        is_shipping: is_shipping, is_billing: is_billing);
    shippingAddress.value = {
      for (var address in addressList) address.addressId.toString(): address
    };
    return addressList;
  }

  Future<Map> getProductFinalPrice(
      {required String productId,
      required String choosenWeight,
      required Map specifications}) async {
    return _cartRepository.getProductFinalPrice(
        productId: productId,
        choosenWeight: choosenWeight,
        specifications: specifications);
  }

  @override
  void onInit() {
    () async {
      await getCartItemList();
    }();
    super.onInit();
  }
}
