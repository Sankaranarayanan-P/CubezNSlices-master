import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/models/source/local/user_local_storage.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:dio/dio.dart' as diopackage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pinput/pinput.dart';

import 'home.dart';

class OtpPage extends StatefulWidget {
  final Map data;
  const OtpPage({super.key, required this.data});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpcontroller = TextEditingController();
  final focusNode = FocusNode();

  bool showError = false;
  bool verificationSuccess = false;

  @override
  void dispose() {
    otpcontroller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<bool> validateOtp() async {
    var dio = diopackage.Dio();
    context.loaderOverlay.show();
    try {
      diopackage.Response response =
          await dio.post("${AppConstants.BASE_URL}checkOtp",
              data: diopackage.FormData.fromMap({
                "contact_number": widget.data['contact_number'],
                "customer_id": widget.data['customer_id'],
                "otp": otpcontroller.text
              }));
      if (response.statusCode == 200) {
        var result = response.data;
        showNotificationSnackBar(result['message'], NotificationStatus.success);
        var res =
            await UserLocalStorage.saveUserSession(result['data']['token']);
        if (res == true) {
          return true;
        }
      }
    } on diopackage.DioException catch (error) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const length = 4;
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: MediaQuery.of(context).size.width * 0.18,
      height: MediaQuery.of(context).size.height * 0.1,
      textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1, bottom: 30),
              child: const Row(
                children: [
                  Text(
                    "Enter OTP",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            AppConstants.isDebugMode
                ? Text(
                    "The OTP is ${widget.data['otp']}(Shown for test mode only)")
                : SizedBox(),
            Container(
              alignment: Alignment.center,
              // height: MediaQuery.of(context).size.height * 0.2,
              child: Pinput(
                length: length,
                controller: otpcontroller,
                focusNode: focusNode,
                autofocus: true,
                onClipboardFound: (pin) {
                  setState(() {
                    otpcontroller.text = pin;
                  });
                },
                validator: (pin) {
                  if (pin == widget.data['otp'].toString()) return null;
                  setState(() {
                    verificationSuccess = false;
                  });
                  showNotificationSnackBar(
                      "Invalid Otp", NotificationStatus.failure);
                  return "Invalid Otp";
                },
                keyboardType: TextInputType.number,
                errorTextStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red),
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) {
                  print(pin);
                  setState(() {
                    showError = pin != widget.data['otp'].toString();
                    verificationSuccess = true;
                  });
                },
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: borderColor),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    color: errorColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: Text(
                      "RESEND OTP",
                      style: GoogleFonts.firaSans(),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.11,
            ),
            Expanded(
              flex: 1,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            if (verificationSuccess) {
                              var response = await validateOtp();
                              if (response == true) {
                                Get.offAll(() => HomeScreen());
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w500),
                            shape: const StadiumBorder(),
                            backgroundColor: Get.theme.primaryColor,
                          ),
                          child: Text(
                            "SUBMIT",
                            style: GoogleFonts.firaSans(
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
