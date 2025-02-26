import 'dart:convert';
import 'dart:developer';

import 'package:cubes_n_slice/domain/network_error_controller.dart';
import 'package:cubes_n_slice/domain/profileView.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/models/dto/cart.dart';
import 'package:cubes_n_slice/models/dto/categorie.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

import '../../dto/my_orders.dart';
import '../../dto/product.dart';

abstract class Api {
  //interface is depend on your api endpoints, your needs...etc
  Api(String appBaseUrl);

  Future<List<Banners>> loadBanners();

  Future<User> getUserProfile({required String token});

  Future<bool> updateProfile({required User user, required String token});

  Future<List<Product>> loadFeaturedProducts(String featureType);

  Future<List<Categorie>> getAllCategory();

  Future<List<SubCategorie>> getAllSubCategoryWithProducts(String categoryId);

  Future<List<Product>> searchProducts(String query);

  Future<Map<String, dynamic>> addToCart(
      {required CartItem cartItem, required String token});

  Future<CartData> getCart({required String token});

  Future<void> removeCart(
      {required String productId,
      required String quantity,
      required bool removeAll,
      required String token});

  Future<Map<String, dynamic>> getAddressFromApiUsingPincode(
      {required String token, required String pincode});

  Future<bool> saveAddressToAPI(
      {required String firstName,
      required String lastName,
      required String contactNumber,
      required String emailAddress,
      required String streetAddress,
      required String landMark,
      required String postalCode,
      required String city,
      required String state,
      required String country,
      required bool isDefaultBilling,
      required bool isDefaultShipping,
      required String token});

  Future<List<Address>> getAllAddress(
      {required String token,
      bool is_shipping = false,
      bool is_billing = false});

  Future<bool> updateAddressToAPI(
      {required String addressId,
      required String firstName,
      required String lastName,
      required String contactNumber,
      required String emailAddress,
      required String streetAddress,
      required String landMark,
      required String postalCode,
      required String city,
      required String state,
      required String country,
      required bool isDefaultBilling,
      required bool isDefaultShipping,
      required String token});

  Future<Product> getProductById(int id);

  Future<bool> updateAddressShipping(
      {required String addressId, required String token});

  Future<bool> updateAddressBilling(
      {required String addressId, required String token});

  Future<List<Coupon>> getCoupons({required String token});

  Future<String> applyCoupon({required String token, required String coupon});

  Future<Map> checkCoupon({required String token, required String coupon});

  Future<List<Map<dynamic, dynamic>>> getPaymentMethods(
      {required String token});

  Future<Map<dynamic, dynamic>> createOrder(
      {required String paymentMethod,
      required String token,
      required Map<String, dynamic> orderData});

  Future<bool> updatePaymentStatus(
      {required String token,
      required String orderId,
      required String status,
      required String paymentId});

  Future<List<Order>> getAllOrders({required String token});

  Future<Order?> getOrderById({required String token, required String orderId});

  Future<Map> getProductFinalPrice(
      {required String token,
      required String productId,
      required String choosenWeight,
      required Map specifications});

  Future<Map<String, dynamic>> getCancellationNoteAndPlatformFee(
      {required String token});

  Future<String?>? getAppVersion();

  Future<String?>? cancelOrder(
      {required String token, required String orderId, required String reason});
}

//Implemntaion depend on your api documentaion
class ApiImpl implements Api {
  final Dio dio;
  final String appBaseUrl;

  ApiImpl(this.appBaseUrl) : dio = Dio(BaseOptions(baseUrl: appBaseUrl));

  @override
  Future<List<Banners>> loadBanners() async {
    try {
      Response response;
      response = await dio.post("${appBaseUrl}banners");
      if (response.statusCode == 500 || response.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      }
      List<Banners> bannerList = [];
      // Assuming 'results' is a list in the response
      final results = response.data['data'] as List;

      // Assuming 'results' contains a single item
      if (results.isNotEmpty) {
        bannerList.clear();
        for (var element in results) {
          var banner = Banners(
              imgPath: element['banner_path'],
              linkedID: element['link_id'],
              linkedCategoryProductName: element['name'],
              linkedTo: element['link_to'],
              categoryIds: element['category_ids'],
              bannerType: element['banner_type']);
          bannerList.add(banner);
        }
        return bannerList;
      } else {
        return bannerList;
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);
        throw Exception(e.response?.data);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<User> getUserProfile({required String token}) async {
    try {
      Response response;
      response = await dio.post("${appBaseUrl}profile",
          data: FormData.fromMap({"token": token}));
      if (response.statusCode == 200) {
        final results = response.data['data'];

        return User(
          phoneNumber: results['contact_number'],
          emailAddress: results['email'],
          firstName: results['first_name'],
          middleName: results['middle_name'],
          lastName: results['last_name'],
          gender: results['gender'],
        );
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);
        throw Exception(e.response?.data);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<bool> updateProfile(
      {required User user, required String token}) async {
    FormData data;

    data = FormData.fromMap({
      'first_name': user.firstName,
      'middle_name': user.middleName == "" ? "" : user.middleName,
      'last_name': user.lastName,
      'email': user.emailAddress,
      'gender': user.gender,
      'token': token
    });

    print(data.fields);
    try {
      Response response;
      response = await dio.post("${appBaseUrl}updateProfile", data: data);
      print("response from api ${response.data['message']}");
      if (response.statusCode == 200) {
        return true;
      } else {
        print("error in api page ${response.data['message']}");
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);
        throw Exception(e.response?.data);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<List<Product>> loadFeaturedProducts(String featureType) async {
    try {
      List<Product> products = [];
      Response response;
      response = await dio.post("${appBaseUrl}featuredProduct");
      print("res${response.data['data']}");
      if (response.statusCode == 200) {
        for (var item in response.data['data']) {
          if (item['feature'].toString().toLowerCase().trim() ==
              featureType.toString().toLowerCase().trim()) {
            List<Product> productList = (item['products'] as List)
                .map((e) => Product.fromMap(e))
                .toList();
            products.addAll(productList);
          }
        }
      }
      print("api return $products");
      return products;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }

    return [];
  }

  @override
  Future<List<Categorie>> getAllCategory() async {
    try {
      List<Categorie> categorylist = [];
      Response response;
      response = await dio.post("${appBaseUrl}category");
      print("rescat${response.data['data']}");
      if (response.statusCode == 200) {
        categorylist = (response.data['data'] as List)
            .map((e) => Categorie.fromMap(e))
            .toList();
      }
      print("api return $categorylist");
      return categorylist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<List<SubCategorie>> getAllSubCategoryWithProducts(
      String categoryId) async {
    try {
      List<SubCategorie> subcategorylist = [];
      Response response;
      response = await dio.post("${appBaseUrl}subCategory/$categoryId");
      print("rescat${response.data['data']}");
      if (response.statusCode == 200) {
        subcategorylist = (response.data['data'] as List)
            .map((e) => SubCategorie.fromMap(e))
            .toList();
      }
      print("api return $subcategorylist");
      return subcategorylist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      List<Product> productlist = [];
      Response response;
      response = await dio.post("$appBaseUrl/searchProduct",
          data:
              FormData.fromMap({"limit": "10", "offset": "0", "term": query}));
      print("rescat${response.data['data']}");
      if (response.statusCode == 200) {
        productlist = (response.data['data']['data'] as List)
            .map((e) => Product.fromMap(e))
            .toList();
      }
      print("api return $productlist");
      return productlist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> addToCart(
      {required CartItem cartItem, required String token}) async {
    try {
      print("in add to cart adding api");
      Response response;
      Map<String, dynamic> formData = {
        "token": token,
        "action": "add",
        "quantity": cartItem.takenquantity,
        "product_id": cartItem.id,
        "specifications": jsonEncode(cartItem.specification),
        "weight": cartItem.chosenWeight,
        "productTotal": cartItem.productTotal,
        "productAmount": cartItem.sellPrice,
        "productOfferAmount": cartItem.OfferPrice,
        "instructions": cartItem.instructions ?? "",
      };
      log(formData.toString());

      response = await dio.post("$appBaseUrl/addToCart",
          data: FormData.fromMap(formData));
      print("added to cart on api");
      if (response.statusCode == 202 &&
          response.data['message'].toString().isNotEmpty) {
        return {"response": "Warning", "message": response.data['message']};
      } else if (response.statusCode == 200) {
        return {"response": "Success"};
      } else {
        return {"response": "failure"};
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) {
          return {"response": "failure"};
        }
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
      return {"response": "failure"};
    }
  }

  @override
  Future<CartData> getCart({required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/addToCart",
          data: FormData.fromMap({
            "token": token,
          }));
      if (response.statusCode == 200 && response.data['data'].isNotEmpty) {
        final cartData = CartData.fromMap(response.data['data']);
        print("api cart data ${cartData.cartCount}");
        return cartData;
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) {
          return CartData(
              cart: [],
              grandTotal: "0",
              discount: "0",
              deliveryCharge: "0",
              grandQuantity: "0",
              cartCount: "0",
              outOfStock: "NO",
              baseAmount: "0");
        }
        ;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return CartData(
        cart: [],
        grandTotal: "0",
        discount: "0",
        deliveryCharge: "0",
        grandQuantity: "0",
        cartCount: "0",
        outOfStock: "NO",
        baseAmount: "0");
  }

  @override
  Future<void> removeCart(
      {required String productId,
      required String quantity,
      required bool removeAll,
      required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/addToCart",
          data: FormData.fromMap({
            "token": token,
            "action": removeAll ? "delete" : "remove",
            "quantity": "1",
            "product_id": productId
          }));
      if (response.statusCode == 200) {
        print("removed from cart on api");
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getAddressFromApiUsingPincode(
      {required String token, required String pincode}) async {

    try {
      Response response;
      response = await dio.post("$appBaseUrl/deliveryLocations",
          data: FormData.fromMap({
            "token": token,
            "pincode": pincode,
          }));
      var resdata = response.data['data'];
      if (response.statusCode == 200) {
        Map<String, dynamic> data = {
          "city": resdata['district'],
          "state": resdata['state'],
          "country": resdata['country']
        };
        print("inside api.................!!!!!!!!");
        print(data);
        return data;
      }
      return {};
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return {};
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return {};
  }

  @override
  Future<bool> saveAddressToAPI(
      {required String firstName,
      required String lastName,
      required String contactNumber,
      required String emailAddress,
      required String streetAddress,
      required String landMark,
      required String postalCode,
      required String city,
      required String state,
      required String country,
      required bool isDefaultBilling,
      required bool isDefaultShipping,
      required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/addAddress",
          data: FormData.fromMap({
            "token": token,
            "first_name": firstName,
            "last_name": lastName,
            "contact_number": contactNumber,
            "email": emailAddress,
            "street_address": streetAddress,
            "landmark": landMark,
            "city": city,
            "state": state,
            "country": country,
            "postal_code": postalCode,
            "default_shipping": isDefaultShipping ? 1 : 0,
            "default_billing": isDefaultBilling ? 1 : 0,
          }));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return false;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return false;
  }

  @override
  Future<bool> updateAddressToAPI(
      {required String addressId,
      required String firstName,
      required String lastName,
      required String contactNumber,
      required String emailAddress,
      required String streetAddress,
      required String landMark,
      required String postalCode,
      required String city,
      required String state,
      required String country,
      required bool isDefaultBilling,
      required bool isDefaultShipping,
      required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/updateAddress",
          data: FormData.fromMap({
            "address_id": addressId,
            "token": token,
            "first_name": firstName,
            "last_name": lastName,
            "contact_number": contactNumber,
            "email": emailAddress,
            "street_address": streetAddress,
            "landmark": landMark,
            "city": city,
            "state": state,
            "country": country,
            "postal_code": postalCode,
            "default_shipping": isDefaultShipping ? 1 : 0,
            "default_billing": isDefaultBilling ? 1 : 0,
          }));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return false;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return false;
  }

  @override
  Future<List<Address>> getAllAddress(
      {required String token,
      bool is_shipping = false,
      bool is_billing = false}) async {
    try {
      List<Address> addresslist = [];
      Response response;
      response = await dio.post("${appBaseUrl}address",
          data: FormData.fromMap({
            "token": token,
            "is_shipping": is_shipping,
            "is_billing": is_billing
          }));
      print("rescat${response.data['data']}");
      if (response.statusCode == 200) {
        addresslist = (response.data['data'] as List)
            .map((e) => Address.fromMap(e))
            .toList();
      }
      print("api return $addresslist");
      return addresslist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      Product product = Product();
      Response response;
      response = await dio.post("$appBaseUrl/productDetails",
          data: FormData.fromMap({"product": id}));
      print("rescat${response.data['data']}");
      if (response.statusCode == 200) {
        product = Product.fromMap(response.data['data']);
      }
      print("api return ${response.data['data']}");
      return product;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return Product();
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return Product();
  }

  @override
  Future<bool> updateAddressBilling(
      {required String addressId, required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/updateAddress",
          data: FormData.fromMap({
            "address_id": addressId,
            "token": token,
            "default_billing": 1,
          }));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return false;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return false;
  }

  @override
  Future<bool> updateAddressShipping(
      {required String addressId, required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/updateAddress",
          data: FormData.fromMap({
            "address_id": addressId,
            "token": token,
            "default_shipping": 1,
          }));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return false;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return false;
  }

  @override
  Future<String> applyCoupon(
      {required String token, required String coupon}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/applyCoupon",
          data: FormData.fromMap({
            "token": token,
            "coupon": coupon,
          }));
      if (response.statusCode == 200) {
        return response.data['message'];
      }
      return "";
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return "";
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return "";
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getPaymentMethods(
      {required String token}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/paymentMethods",
          data: FormData.fromMap({
            "token": token,
          }));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<Map<String, dynamic>> paymentMethods =
            data.map((item) => item as Map<String, dynamic>).toList();

        return paymentMethods;
      }
      return [];
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<Map> createOrder(
      {required String paymentMethod,
      required String token,
      required Map<String, dynamic> orderData}) async {
    try {
      Response response;
      Map<String, dynamic> data = {
        "token": token,
        "mode_of_payment": paymentMethod,
        ...orderData
      };
      print("order data");
      log(data.toString());
      response =
          await dio.post("$appBaseUrl/order", data: FormData.fromMap(data));
      log(response.data.toString());
      if (response.statusCode == 200) {
        if (paymentMethod == "CASH_ON_DELIVERY") {
          return {'status': true};
        }
        final Map transcationDetails =
            response.data['data']['transaction_details'];
        return transcationDetails;
      }
      return {};
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        log(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return {};
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return {};
  }

  @override
  Future<bool> updatePaymentStatus(
      {required String token,
      required String orderId,
      required String status,
      String paymentId = ""}) async {
    try {
      Response response;
      Map<String, dynamic> data = {
        "token": token,
        "orderId": orderId,
        "statusCode": status,
      };
      if (paymentId != "") {
        data["paymentId"] = paymentId;
      }
      response =
          await dio.post("$appBaseUrl/payment", data: FormData.fromMap(data));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return false;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return false;
  }

  @override
  Future<List<Order>> getAllOrders({required String token}) async {
    try {
      List<Order> orderlist = [];
      Response response;
      response = await dio.post("$appBaseUrl/myOrders",
          data: FormData.fromMap({"token": token}));
      print("rescat ${response.data['data']}");
      if (response.statusCode == 200) {
        orderlist = (response.data['data'] as List)
            .map((e) => Order.fromMap(e))
            .toList();
      }
      print("api return ${response.data['data']}");
      return orderlist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<Map> getProductFinalPrice(
      {required String token,
      required String productId,
      required String choosenWeight,
      required Map specifications}) async {
    try {
      Map productPriceList = {};
      Response response;
      response = await dio.post("$appBaseUrl/getProductPrice",
          data: FormData.fromMap({
            "token": token,
            "productId": productId,
            "Weight": choosenWeight,
            "specifications": jsonEncode(specifications)
          }));
      print("rescat ${response.data['data']}");
      if (response.statusCode == 200) {
        productPriceList = response.data['data'] as Map;
      }
      print("api return ${response.data['data']}");
      return productPriceList;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return {};
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return {};
  }

  @override
  Future<List<Coupon>> getCoupons({required String token}) async {
    try {
      List<Coupon> couponlist = [];
      Response response;
      response = await dio.post("$appBaseUrl/getAvailableCoupons",
          data: FormData.fromMap({"token": token}));
      print("res coupon ${response.data['data']}");
      if (response.statusCode == 200) {
        couponlist = (response.data['data'] as List)
            .map((e) => Coupon.fromJson(e))
            .toList();
      }
      print("api return ${response.data['data']}");
      return couponlist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getCancellationNoteAndPlatformFee(
      {required String token}) async {
    try {
      Map<String, dynamic> cancellationNoteAndPlatformFee = {};
      Response response;
      response = await dio.post("$appBaseUrl/getCancelRequestNote",
          data: FormData.fromMap({
            "token": token,
          }));
      print("rescat ${response.data['data']}");
      if (response.statusCode == 200) {
        cancellationNoteAndPlatformFee = response.data['data'];
      }
      print("api return ${response.data['data']}");
      return cancellationNoteAndPlatformFee;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return {};
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return {};
  }

  @override
  Future<Map> checkCoupon(
      {required String token, required String coupon}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/checkCoupon",
          data: FormData.fromMap({
            "token": token,
            "coupon": coupon,
          }));
      print(response.data);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data['data'];

        // Check if there's an error message in the response data
        if (responseData.containsKey('error')) {
          print("Error: ${responseData['error']}");
          return {"error": responseData['error']};
        } else {
          return responseData;
        }
      }
      return {};
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) {
          return {"error": "Coupon not found."};
        }
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return {};
  }

  @override
  Future<String?>? getAppVersion() async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/getAppVersion");
      print(response.data);
      if (response.statusCode == 200) {
        print(response.data['data']['version']);
        return response.data['data']['version'];
        // Check if there's an error message in the response data
      }
      return null;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) {
          return null;
        }
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return null;
  }

  @override
  Future<List<Categorie>> getAllDeliveryLocations() async {
    try {
      List<Categorie> deliveryLocationlist = [];
      Response response;
      response = await dio.post("${appBaseUrl}getAvailableDeliveryLocations");
      print("delivery locations${response.data['data']}");
      if (response.statusCode == 200) {
        deliveryLocationlist = (response.data['data'] as List)
            .map((e) => Categorie.fromMap(e))
            .toList();
      }
      print("api return $deliveryLocationlist");
      return deliveryLocationlist;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return [];
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return [];
  }



  @override
  Future<String?> cancelOrder(
      {required String token,
      required String orderId,
      required String reason}) async {
    try {
      Response response;
      response = await dio.post("$appBaseUrl/cancelOrder",
          data: FormData.fromMap(
              {"token": token, "order": orderId, "reason": reason}));
      print(response.data);
      if (response.statusCode == 200) {
        return "success";
      } else if (response.statusCode == 202) {
        return response.data['message'];
      }
      return null;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) {
          return null;
        }
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return null;
  }

  @override
  Future<Order?> getOrderById(
      {required String token, required String orderId}) async {
    try {
      Order? order;
      Response response;
      response = await dio.post("$appBaseUrl/orderDetails",
          data: FormData.fromMap({"token": token, "orderId": orderId}));
      print("rescat ${response.data['data']}");
      if (response.statusCode == 200) {
        order = Order.fromMap(response.data['data'] as Map<String, dynamic>);
      }
      print("api return ${response.data['data']}");
      return order;
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response!.statusCode == 500 || e.response!.statusCode == 509) {
        getx.Get.find<NetworkErrorController>().setNetworkError(true);
      } else if (e.response!.statusCode == 401 &&
          e.response!.data['message'] == "INVALID AUTH") {
        getx.Get.find<ProfileViewModel>().logoutUser();
      }
      if (e.response != null) {
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);

        //  API responds with 404 when reached the end
        if (e.response?.statusCode == 404) return null;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }
    return null;
  }


}

class Banners {
  String? imgPath;
  String? linkedTo;
  String? linkedID;
  String? linkedCategoryProductName;
  String? categoryIds;
  String? bannerType;

  Banners(
      {required this.imgPath,
      required this.linkedID,
      this.categoryIds,
      required this.linkedCategoryProductName,
      required this.linkedTo,
      required this.bannerType});

  factory Banners.fromRawJson(String str) => Banners.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  factory Banners.fromMap(Map<String, dynamic> json) {
    return Banners(
        imgPath: json['imgPath'],
        linkedID: json['linkedID'],
        linkedCategoryProductName: json['linkedCategoryProductName'],
        linkedTo: json['linkedTo'],
        categoryIds: json['categoryIds'] ?? "",
        bannerType: json['banner_type']);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imgPath'] = imgPath;
    data['linkedID'] = linkedID;
    data['linkedCategoryProductName'] = linkedCategoryProductName;
    data['linkedTo'] = linkedTo;
    data['categoryIds'] = categoryIds;
    data['bannerType'] = bannerType;
    return data;
  }
}
