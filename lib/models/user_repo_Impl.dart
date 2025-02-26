import 'package:cubes_n_slice/models/source/local/user_local_storage.dart';
import 'package:cubes_n_slice/models/source/remote/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dto/User.dart';

abstract class UserRepository {
  Future<User> authenticateUser({required phoneNumber});

  Future<User> getUserProfile();

  Future<bool> updateUserProfile({required User user});

  Future<Map<String, dynamic>> getAddressFromPincode({required String pincode});

  Future<bool> saveAddress(
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
      required bool isDefaultShipping,
      required bool isDefaultBilling});

  Future<bool> updateAddress(
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
      required bool isDefaultShipping,
      required bool isDefaultBilling});

  Future<bool> updateAddressShipping({required String addressId});

  Future<bool> updateAddressBilling({required String addressId});

  Future<List<Address>> getAllAddress();

  Future<String?>? getAppVersion();
}

class UserRepositoryImpl implements UserRepository {
  final Api _api;
  final UserLocalStorageImpl _localStorage;

  UserRepositoryImpl({
    required Api api,
    required UserLocalStorageImpl localStorage,
  })  : _api = api,
        _localStorage = localStorage;

  @override
  Future<User> authenticateUser({required phoneNumber}) async {
    User user = User();
    try {
      print("user");
      // user = await _apiImpl.loginUser(phoneNumber: phoneNumber);
      return user;
    } catch (error) {
      return user;
    }
  }

  @override
  Future<User> getUserProfile() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken");
    print("token is $token");
    User? user;
    try {
      user = await _localStorage.getUserProfile();
      if (user == null || user.lastName!.isEmpty) {
        print("user is empty going to get from api");
        user = await _api.getUserProfile(token: token!);
        _localStorage.saveUserProfile(user);
      }
      print("user is ${user.lastName}");
    } catch (e) {
      user = await _api.getUserProfile(token: token!);
      _localStorage.saveUserProfile(user);
    }
    return user;
  }

  @override
  Future<bool> updateUserProfile({required User user}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken");
    bool isUpdated = await _api.updateProfile(user: user, token: token!);
    return isUpdated;
  }

  @override
  Future<Map<String, dynamic>> getAddressFromPincode(
      {required String pincode}) async {

    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken") ?? "";
    return await _api.getAddressFromApiUsingPincode(
        token: token, pincode: pincode);
  }

  Future<bool> saveAddress(
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
      required bool isDefaultShipping,
      required bool isDefaultBilling}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken") ?? "";
    return await _api.saveAddressToAPI(
        firstName: firstName,
        lastName: lastName,
        contactNumber: contactNumber,
        emailAddress: emailAddress,
        streetAddress: streetAddress,
        landMark: landMark,
        postalCode: postalCode,
        city: city,
        state: state,
        country: country,
        isDefaultShipping: isDefaultShipping,
        isDefaultBilling: isDefaultBilling,
        token: token);
  }

  Future<bool> updateAddress(
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
      required bool isDefaultShipping,
      required bool isDefaultBilling}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken") ?? "";
    return await _api.updateAddressToAPI(
        addressId: addressId,
        firstName: firstName,
        lastName: lastName,
        contactNumber: contactNumber,
        emailAddress: emailAddress,
        streetAddress: streetAddress,
        landMark: landMark,
        postalCode: postalCode,
        city: city,
        state: state,
        country: country,
        isDefaultShipping: isDefaultShipping,
        isDefaultBilling: isDefaultBilling,
        token: token);
  }

  @override
  Future<List<Address>> getAllAddress() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken") ?? "";
    return await _api.getAllAddress(token: token);
  }

  @override
  Future<bool> updateAddressBilling({required String addressId}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken") ?? "";
    return await _api.updateAddressBilling(addressId: addressId, token: token);
  }

  @override
  Future<bool> updateAddressShipping({required String addressId}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var token = sharedPref.getString("userToken") ?? "";
    return await _api.updateAddressShipping(addressId: addressId, token: token);
  }

  @override
  Future<String?>? getAppVersion() async {
    return await _api.getAppVersion();
  }
}
