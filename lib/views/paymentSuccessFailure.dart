import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:cubes_n_slice/views/paymentProcessing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../constants/assets.dart';
import 'home.dart';

class PaymentSuccessFailure extends StatefulWidget {
  final bool isSuccess;
  final String failedReason;
  Map? transcationalDetails;
  Map<String, dynamic>? orderDetails;

  PaymentSuccessFailure(
      {super.key,
      this.isSuccess = false,
      this.failedReason = "",
      this.transcationalDetails,
      this.orderDetails});

  @override
  State<PaymentSuccessFailure> createState() => _PaymentSuccessFailureState();
}

class _PaymentSuccessFailureState extends State<PaymentSuccessFailure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
                widget.isSuccess
                    ? Assets.paymentSuccess
                    : Assets.paymentFailure,
                repeat: false),
            Text(
              "Order ${widget.isSuccess ? "Successful" : "Failed"}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.isSuccess
                    ? "Your Order was Successful.We will deliver your orders at the earliest."
                    : widget.failedReason,
                textAlign: TextAlign.center,
              ),
            ),
            !widget.isSuccess
                ? Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextButton(
                      child: const Text("Retry Again"),
                      onPressed: () {
                        // Get.offAndToNamed("/paymentmode");
                        Get.to(() => PaymentProcessing(
                            transcationalDetails: widget.transcationalDetails!,
                            orderDetails: widget.orderDetails!));
                      },
                    ),
                  )
                : SizedBox(),
            widget.isSuccess
                ? Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: CustomButton(
                      widthFactor: 0.7,
                      text: "Go to My Orders",
                      onPressed: () {
                        Get.offUntil(
                            GetPageRoute(
                                page: () => HomeScreen(
                                      initialIndex: 3,
                                    )),
                            (route) => false);
                      },
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
