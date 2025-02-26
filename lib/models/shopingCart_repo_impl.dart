import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/models/source/local/cart_local_storage.dart';
import 'package:cubes_n_slice/models/source/remote/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dto/cart.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalStorage _cartLocalStorage;
  final Api _api;

  CartRepositoryImpl({
    required Api api,
    required CartLocalStorage cartLocalStorage,
  })  : _api = api,
        _cartLocalStorage = cartLocalStorage;

  @override
  CartItem? getCartItemById({required BigInt productId}) {
    final cachedCartItem =
        _cartLocalStorage.loadCartItem(cartItemId: productId);
    return cachedCartItem!;
  }

  @override
  Future<Map<String, dynamic>> insertCartItem(CartItem cartItem) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    print(cartItem.id);
    return await _api.addToCart(cartItem: cartItem, token: token);
    // _cartLocalStorage.saveCartItem(cartItem: cartItem);
  }

  @override
  Future<CartData> getCartItemList() async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    print("going to cart api");
    final cartData = await _api.getCart(token: token);
    // final cachedCartItemList = _cartLocalStorage.loadCartItemList();
    return cartData;
  }

  @override
  Future<bool> removeCartItem(
      {required CartItem cartItem, bool removeAll = false}) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    await _api.removeCart(
        productId: cartItem.id!,
        quantity: cartItem.AvailableitemQuantity.toString(),
        removeAll: removeAll,
        token: token);
    return _cartLocalStorage.removeCartItem(cartItem: cartItem);
  }

  @override
  Future<CartItem> updateCartItem(CartItem cartItem) {
    throw UnimplementedError();
  }

  @override
  Future<bool> saveCartItemList(List<CartItem> cartItemList) {
    return _cartLocalStorage.saveCartItemList(cartItemList);
  }

  @override
  Future<String> applyCoupon(String coupon) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.applyCoupon(token: token, coupon: coupon);
  }

  @override
  Future<List<Map>> getPaymentMethods() async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.getPaymentMethods(token: token);
  }

  @override
  Future<Map> createOrder(
      {required String paymentMethod,
      required Map<String, dynamic> orderData}) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return _api.createOrder(
      paymentMethod: paymentMethod,
      token: token,
      orderData: orderData,
    );
  }

  @override
  Future<bool> updatePaymentStatus(
      {required String orderId,
      required String status,
      String paymentId = ""}) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.updatePaymentStatus(
        token: token, orderId: orderId, status: status, paymentId: paymentId);
  }

  @override
  Future<Map> getProductFinalPrice(
      {required String productId,
      required String choosenWeight,
      required Map specifications}) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.getProductFinalPrice(
        token: token,
        productId: productId,
        choosenWeight: choosenWeight,
        specifications: specifications);
  }

  @override
  Future<List<Coupon>> getCoupons() async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.getCoupons(token: token);
  }

  @override
  Future<Map<String, dynamic>> getCancellationNoteAndPlatformFee() async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.getCancellationNoteAndPlatformFee(token: token);
  }

  @override
  Future<List<Address>> getAllAddress(
      {bool is_shipping = false, bool is_billing = false}) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.getAllAddress(
        token: token, is_shipping: is_shipping, is_billing: is_billing);
  }

  @override
  Future<Map> checkCoupon(String coupon) async {
    final sharedPref = await SharedPreferences.getInstance();
    String token = sharedPref.getString("userToken") ?? "";
    return await _api.checkCoupon(token: token, coupon: coupon);
  }
}

abstract class CartRepository {
  Future<Map<String, dynamic>> insertCartItem(CartItem cartItem);

  Future<CartItem> updateCartItem(CartItem cartItem);

  Future<bool> removeCartItem(
      {required CartItem cartItem, bool removeAll = false});

  CartItem? getCartItemById({required BigInt productId});

  Future<CartData> getCartItemList();

  Future<bool> saveCartItemList(List<CartItem> cartItemList);

  Future<String> applyCoupon(String coupon);

  Future<Map> checkCoupon(String coupon);

  Future<List<Map<dynamic, dynamic>>> getPaymentMethods();

  Future<Map> createOrder(
      {required String paymentMethod, required Map<String, dynamic> orderData});

  Future<bool> updatePaymentStatus(
      {required String orderId,
      required String status,
      required String paymentId});

  Future<Map> getProductFinalPrice(
      {required String productId,
      required String choosenWeight,
      required Map specifications});

  Future<List<Coupon>> getCoupons();

  Future<Map<String, dynamic>> getCancellationNoteAndPlatformFee();

  Future<List<Address>> getAllAddress(
      {bool is_shipping = false, bool is_billing = false});
}
