import 'package:cubes_n_slice/domain/profileView.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/utils/myStates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/appConstants.dart';
import '../constants/assets.dart';
import 'common_widgets/profileList.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  // static final Email email = Email(
  PackageInfo? packageInfo;
  @override
  void initState() {
    super.initState();
    () async {
      context.loaderOverlay.show();
      await profileViewModel.getUserProfile();
      _getThemeStatus();
      packageInfo = await PackageInfo.fromPlatform();
      setState(() {});
      context.loaderOverlay.hide();
    }();
  }

  final RxBool _isLightTheme = false.obs;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  _saveThemeStatus() async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', _isLightTheme.value);
  }

  _getThemeStatus() async {
    var _isLight = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('theme') ?? true;
    }).obs;
    _isLightTheme.value = (await _isLight.value)!;
    Get.changeThemeMode(_isLightTheme.value ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (profileViewModel.userState is LoadingState) {
          return const SizedBox();
        } else if (profileViewModel.userState is LoadedState) {
          User user = (profileViewModel.userState as LoadedState).data;
          print("user profile loaded");
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius:
                                        50, // You can adjust the radius as needed
                                    child: Text(
                                      user.firstName?.isNotEmpty ?? false
                                          ? user.firstName?.substring(0, 1) ??
                                              'CS'
                                          : "CS",
                                      style: TextStyle(
                                          fontSize:
                                              24), // Adjust the font size as needed
                                    ),
                                  ),
                                ],
                              )

                              // Positioned(
                              //   bottom: 0,
                              //   right: 0,
                              //   child: Container(
                              //     width: 35,
                              //     height: 35,
                              //     decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(100),
                              //         color: Get.theme.primaryColor),
                              //     child: const Icon(
                              //       Icons.camera_alt_rounded,
                              //       color: Colors.white,
                              //       size: 20,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user.firstName == "" ? "Guest" : user.firstName!,
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text("Login Id: ${user.phoneNumber}",
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 0.1,
                  ),
                  const SizedBox(height: 10),

                  /// -- MENU
                  ProfileMenuWidget(
                      title: "My Profile",
                      icon: Icons.account_circle,
                      onPress: () {
                        Get.toNamed("/profileupdate");
                      }),
                  ProfileMenuWidget(
                      title: "My Address",
                      icon: Icons.location_on_outlined,
                      onPress: () {
                        Get.toNamed("/addresspage");
                      }),
                  ProfileMenuWidget(
                      title: "My Orders",
                      icon: Icons.shopping_bag_outlined,
                      onPress: () {
                        Get.toNamed("/ordersPage");
                      }),
                  const Divider(
                    thickness: 0.1,
                  ),
                  const SizedBox(height: 10),
                  ProfileMenuWidget(
                      title: "Terms & Conditions",
                      icon: FontAwesomeIcons.clipboardList,
                      endIcon: false,
                      onPress: () {
                        Get.toNamed("/policyPage", parameters: {
                          "url":
                              "${AppConstants.siteUrl}page/termsandconditions/",
                          "title": "Terms And Condition"
                        });
                      }),
                  const SizedBox(height: 10),
                  ProfileMenuWidget(
                      title: "Privacy Policy",
                      icon: FontAwesomeIcons.shieldHalved,
                      endIcon: false,
                      onPress: () {
                        Get.toNamed("/policyPage", parameters: {
                          "url": "${AppConstants.siteUrl}page/privacypolicy",
                          "title": "Privacy Policy"
                        });
                      }),
                  ProfileMenuWidget(
                      title: "Shipment and Delivery Policy",
                      icon: FontAwesomeIcons.truck,
                      endIcon: false,
                      onPress: () {
                        Get.toNamed("/policyPage", parameters: {
                          "url":
                              "${AppConstants.siteUrl}page/shipmentdeliverypolicy",
                          "title": "Shipment and Delivery Policy"
                        });
                      }),
                  ProfileMenuWidget(
                      title: "Refund Policy",
                      icon: FontAwesomeIcons.receipt,
                      endIcon: false,
                      onPress: () {
                        Get.toNamed("/policyPage", parameters: {
                          "url": "${AppConstants.siteUrl}page/refundpolicy",
                          "title": "Refund Policy"
                        });
                      }),
                  ProfileMenuWidget(
                      title: "Delivery Locations",
                      icon: Icons.location_city_outlined,
                      onPress: () {
                        Get.toNamed("/deliveryLocations");
                      }),
                  ProfileMenuWidget(
                      title: "About us",

                      icon: Icons.question_mark_outlined,
                      endIcon: false,
                      onPress: () {
                        Get.toNamed("/policyPage", parameters: {
                          "url": "${AppConstants.siteUrl}page/aboutus",
                          "title": "About Us"
                        });
                      }),
                  ProfileMenuWidget(
                      title: "Log Out",
                      icon: Icons.logout_outlined,
                      endIcon: false,
                      onPress: () {
                        logout();
                      }),
                  Text("App Version ${packageInfo?.version ?? ""}")
                ],
              ),
            ),
          );
        } else if (profileViewModel.userState is FailureState) {
          final errorMessage =
              (profileViewModel.userState as FailureState).errorMessage;
          return Center(
            child: Column(
              children: [
                Image.asset(
                  Assets.imagesEmptyList,
                  scale: 4,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(errorMessage),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () => {profileViewModel.getUserProfile()},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    shape: const StadiumBorder(),
                    backgroundColor: Get.theme.primaryColor,
                  ),
                  child: const Text(
                    "Refresh",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      }),
    );
  }

  void logout() {
    showCupertinoDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('Please Confirm'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              // The "Yes" button
              CupertinoDialogAction(
                onPressed: () async {
                  final SharedPreferences shared =
                      await SharedPreferences.getInstance();
                  shared.clear();
                  Get.offAllNamed("/welcome");
                },
                isDefaultAction: true,
                isDestructiveAction: true,
                child: const Text('Yes'),
              ),
              // The "No" button
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                isDefaultAction: false,
                isDestructiveAction: false,
                child: const Text('No'),
              )
            ],
          );
        });
  }
}
