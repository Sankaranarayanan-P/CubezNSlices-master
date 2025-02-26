import 'package:cubes_n_slice/utils/myStates.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../constants/assets.dart';
import '../domain/profileView.dart';
import '../models/dto/User.dart';
import '../utils/SnackBarNotification.dart';
import 'common_widgets/CustomButton.dart';
import 'common_widgets/TextFormFieldComponent.dart';
import 'common_widgets/dropDownComponent.dart';
import 'home.dart';

class ProfileUpdate extends StatefulWidget {
  const ProfileUpdate({super.key});

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  final _formKey = GlobalKey<FormState>();
  String selectedGender = "";
  bool isInitialized = false;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    () async {
      context.loaderOverlay.show();
      await profileViewModel.getUserProfile();
      if (profileViewModel.userState is LoadedState) {
        User user = (profileViewModel.userState as LoadedState).data;
        firstNameController.text = user.firstName ?? "";
        middleNameController.text = user.middleName ?? "";
        lastNameController.text = user.lastName ?? "";
        emailAddressController.text = user.emailAddress ?? "";
        selectedGender = user.gender ?? "";
        print(selectedGender);
        setState(() {});
      }
      context.loaderOverlay.hide();
    }();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: BackButton(
          onPressed: () {
            Get.to(() => HomeScreen(
                  initialIndex: 4,
                ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesProfileUpdate,
                height: 300,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "My Profile",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormFieldComponent(
                  padding: 20,
                  labelText: "First Name",
                  keyboardType: TextInputType.name,
                  hintText: "your First Name..",
                  controller: firstNameController,
                  validation: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please fill out first Name";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  padding: 20,
                  labelText: "Middle Name",
                  keyboardType: TextInputType.name,
                  hintText: "your Middle Name..",
                  controller: middleNameController,
                  validation: (String? value) {
                    return null;
                  }),
              TextFormFieldComponent(
                  padding: 20,
                  labelText: "Last Name",
                  keyboardType: TextInputType.name,
                  hintText: "your Last Name..",
                  controller: lastNameController,
                  validation: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please fill out last Name";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  padding: 20,
                  labelText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  hintText: "your Email Address..",
                  controller: emailAddressController,
                  validation: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please provide a email address";
                    }
                    return value.isValidEmail() ? null : "Check your email";
                  }),
              DropdownFieldComponent(
                padding: 20,
                items: const ["MALE", "FEMALE", "OTHER"],
                value: selectedGender,
                hintText: "Select your gender..",
                labelText: "Gender",
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                validation: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a gender";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                    text: "Update",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print(selectedGender);
                        bool response = await profileViewModel.updateProfile(
                            firstName: firstNameController.text,
                            middleName: middleNameController.text,
                            lastName: lastNameController.text,
                            gender: selectedGender,
                            emailAddress: emailAddressController.text);
                        if (response) {
                          print("Updated Success");
                          Get.offUntil(
                              GetPageRoute(
                                  page: () => HomeScreen(
                                        initialIndex: 4,
                                      )),
                              (route) => false);
                          showNotificationSnackBar(
                              "Profile Updated Successfully",
                              NotificationStatus.success);
                        } else {
                          showNotificationSnackBar("Something went wrong",
                              NotificationStatus.failure);
                        }
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Email validation extension
extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
