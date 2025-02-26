import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/utils/NotificationHandler.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/utils/helper.dart';
import 'package:cubes_n_slice/views/OtpViewPage.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../constants/assets.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // final UserRepositoryImpl _userRepositoryImpl = UserRepositoryImpl();
  // final _phoneNumberHintPlugin = PhoneNumberHint();
  final _formKey = GlobalKey<FormState>();

  TextEditingController phoneController = TextEditingController();
  Future loginUser({required String phoneNumber}) async {
    var dio = Dio();
    try {
      if (context.loaderOverlay.visible) {
        context.loaderOverlay.hide();
      }
      context.loaderOverlay.show();
      Response response;
      response = await dio.post("${AppConstants.BASE_URL}signin",
          data: FormData.fromMap({
            "contact_number": phoneNumber,
            "device_token": await NotificationHandler.getToken()
          }));
      if (response.statusCode == 200) {
        var result = response.data;
        print(result);
        if (result['message'] == "SUCCESSFULLY SUBMITTED") {
          var data = result['data'];
          context.loaderOverlay.hide();
          showNotificationSnackBar(
              "Otp is ${data['otp']}", NotificationStatus.success,
              location: ToastGravity.TOP);
          print("Otp is ${data['otp']}");
          Get.to(() => OtpPage(data: data));
        }
      }
      // User user = User(phoneNumber: result['contact_number']);
      // return user;
    } on DioException catch (e) {
      if (e.response != null) {
        showNotificationSnackBar(e.response?.data, NotificationStatus.warning);
        print(e.response?.data);
        print(e.response?.headers);
        print(e.response?.requestOptions);
      } else {
        showNotificationSnackBar(
            "Something went wrong ${e.message}", NotificationStatus.warning);
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
      context.loaderOverlay.hide();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getPhoneNumber() async {
    String result = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // result = await _phoneNumberHintPlugin.requestHint() ?? '';
    } on PlatformException {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    if (result.startsWith("+91")) {
      // Remove the first two characters ("91")
      result = result.substring(2);
    }
    setState(() {
      phoneController.text = result;
    });
  }

  @override
  void initState() {
    initDependencies();
    () async {
      // await getPhoneNumber();
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    context.loaderOverlay.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const FittedBox(
                              fit: BoxFit.contain,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome to",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: MediaQuery.of(context).size.width * 0.22,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  Assets.imagesAppIcon,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (String? value) {
                            // Ensure value is not null and exactly 10 digits
                            if (value == null || value.isEmpty) {
                              return "Please Provide a Mobile Number";
                            } else if (value.length != 10) {
                              return 'Please provide a valid Mobile Number';
                            } else if (!RegExp(r'^[6-9]\d{9}$')
                                .hasMatch(value)) {
                              return 'Please provide a valid Mobile Number';
                            }
                            return null;
                          },
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10)
                          ],
                          maxLength: 10,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          controller: phoneController,
                          decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            errorStyle: GoogleFonts.firaSans(),
                            constraints:
                                BoxConstraints.loose(const Size.fromHeight(80)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Enter your Mobile Number",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Get.theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            prefix: Text(
                              "+91",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.phone_android),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "We will send you a verification code",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Get.theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CustomButton(
                          text: "Continue",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginUser(phoneNumber: phoneController.text);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  "By clicking on 'Continue' you are agreeing to our ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Get.theme.colorScheme.primary,
                                fontSize: 12,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: "terms of use",
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.toNamed("/policyPage", parameters: {
                                          "url":
                                              "${AppConstants.siteUrl}page/termsandconditions/",
                                          "title": "Terms And Condition"
                                        });
                                      }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
