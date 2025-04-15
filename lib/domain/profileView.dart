import 'dart:async';

import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/models/user_repo_Impl.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/myStates.dart';

class ProfileViewModel extends GetxController {
  UserRepository _userRepository;

  ProfileViewModel({required UserRepository userRepositoryImpl})
      : _userRepository = userRepositoryImpl;

  final Rx<MyState> _userState = MyState().obs;

  MyState get userState => _userState.value;

  RxList<Address> addresses = <Address>[].obs;

  RxString firstName = ''.obs;
  RxString middleName = ''.obs;
  RxString lastName = ''.obs;
  RxString emailAddress = ''.obs;
  RxString gender = ''.obs;

  Future<User?> getUserProfile() async {
    try {
      User user = await _userRepository.getUserProfile();
      firstName.value = user.firstName ?? '';
      middleName.value = user.middleName ?? '';
      lastName.value = user.lastName ?? '';
      emailAddress.value = user.emailAddress ?? '';
      gender.value = user.gender ?? '';
      _userState.value = LoadedState(user);
      return user;
    } catch (e) {
      print("AN ERROR OCCURRED WHILE GETTING PROFILE $e");
      _userState.value = FailureState('An error occurred');
      return null;
    }
    return null;
  }

  Future<bool> updateProfile(
      {required String firstName,
      String middleName = "",
      required String lastName,
      required String gender,
      required String emailAddress}) async {
    try {
      User user = User(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        emailAddress: emailAddress,
        gender: gender,
      );
      bool updated = await _userRepository.updateUserProfile(user: user);
      if (updated) {
        return true;
      }
    } catch (e) {
      print("Error when submitting profile $e");
      throw Exception("Something went wrong while updating");
    }
    return false;
  }

  Future<Map<String, dynamic>> getAddressFromPincode(String pincode) async {

    return await _userRepository.getAddressFromPincode(pincode: pincode);
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
    return _userRepository.saveAddress(
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
        isDefaultBilling: isDefaultBilling);
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
    return _userRepository.updateAddress(
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
        isDefaultBilling: isDefaultBilling);
  }

  Future<List<Address>> getAllAddress() async {
    try {
      List<Address> result = await _userRepository.getAllAddress();
      addresses.value = result;
      return result;
    } catch (e) {
      print("Error getting addresses: $e");
      return [];
    }
  }

  Future<bool> updateAddressShipping({required String addressId}) async {
    return await _userRepository.updateAddressShipping(addressId: addressId);
  }

  Future<bool> updateAddressBilling({required String addressId}) async {
    return await _userRepository.updateAddressBilling(addressId: addressId);
  }

  void logoutUser() async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    shared.clear();
    showNotificationSnackBar(
        "Session Expired.Please login again", NotificationStatus.warning);
    Get.offAllNamed("/welcome");
  }

  Future<void> checkAppVersion() async {
    String? appVersion = await _userRepository.getAppVersion();
    if (appVersion != null) {
      final SharedPreferences shared = await SharedPreferences.getInstance();
      await shared.setString("appVersion", appVersion);
    }
  }

  @override
  void onInit() async {
    await getUserProfile();
    await getAllAddress();
    super.onInit();
  }

  @override
  void onClose() {
    _userState.close();
    super.onClose();
  }
}
