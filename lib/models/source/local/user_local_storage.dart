import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dto/User.dart';

class UserLocalStorage {
  static Future<bool> saveUserSession(String token) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setBool("isLoggedIn", true);
    var res = await sharedPref.setString("userToken", token);
    return res;
  }

  static Future<String?> getUserSession() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString("userToken");
  }
}

abstract class UserLocalStorageAbstract {
  Future<User?> getUserProfile();

  Future<void> saveUserProfile(User user);
}

class UserLocalStorageImpl implements UserLocalStorageAbstract {
  final SharedPreferences _sharedPref;

  UserLocalStorageImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPref = sharedPreferences;

  @override
  Future<User?> getUserProfile() async {
    var rawJSON = _sharedPref.getString("user");
    if (rawJSON == null) {
      return null;
    }
    User user = User.fromRawJson(rawJSON);
    return user;
  }

  @override
  Future<void> saveUserProfile(User user) async {
    await _sharedPref.setString("user", jsonEncode(user.toMap()));
  }
}
