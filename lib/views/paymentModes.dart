import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:cubes_n_slice/views/paymentProcessing.dart';
import 'package:cubes_n_slice/views/paymentSuccessFailure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../constants/assets.dart';
import '../domain/cartViewModel.dart';
import 'common_widgets/CustomButton.dart';

class PaymentModes extends StatefulWidget {
  Map<String, dynamic> orderDetails;
  PaymentModes({super.key, required this.orderDetails});

  @override
  State<PaymentModes> createState() => _PaymentModesState();
}

class _PaymentModesState extends State<PaymentModes> {
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
  List<Map<dynamic, dynamic>> paymentMethods = [];
  bool isOnlinePaymentAvailable = true;
  bool isCODAvailable = true;

  @override
  void initState() {
    () async {
      context.loaderOverlay.show();
      paymentMethods = await cartViewModel.getPaymentMethods();
      print(paymentMethods);
      setState(() {
        // Check availability based on the fetched data
        isOnlinePaymentAvailable = paymentMethods.any((method) =>
            method['mode'].any((m) => m['name'] == 'ONLINE_PAYMENT'));
        isCODAvailable = paymentMethods.any((method) =>
            method['mode'].any((m) => m['name'] == 'CASH_ON_DELIVERY'));
        print(isOnlinePaymentAvailable);
      });
      context.loaderOverlay.hide();
    }();
    super.initState();
  }

  String selectedValue = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: Text(
          "Payment Mode",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Image.asset(
                  Assets.paymentMethods,
                  height: MediaQuery.of(context).size.height * 0.4,
                  fit: BoxFit.contain,
                ),
                const Text(
                  "Choose a Payment Method",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                ListTile(
                  leading: Radio<String>(
                    value: "ONLINE_PAYMENT",
                    groupValue: selectedValue,
                    onChanged: isOnlinePaymentAvailable
                        ? (String? value) {
                            setState(() {
                              selectedValue = value ?? "ONLINE_PAYMENT";
                            });
                          }
                        : null,
                  ),
                  title: Text(
                    "Online Payment",
                    style: TextStyle(
                        fontSize: 18,
                        color: isOnlinePaymentAvailable
                            ? Colors.black
                            : Colors.grey),
                  ),
                  subtitle: !isOnlinePaymentAvailable
                      ? const Text(
                          "Currently Unavailable",
                          style: TextStyle(color: Colors.grey),
                        )
                      : const SizedBox(),
                ),
                ListTile(
                  leading: Radio<String>(
                    value: "CASH_ON_DELIVERY",
                    groupValue: selectedValue,
                    onChanged: isCODAvailable
                        ? (String? value) {
                            setState(() {
                              selectedValue = value ?? "CASH_ON_DELIVERY";
                            });
                          }
                        : null,
                  ),
                  title: Text(
                    "Cash On Delivery",
                    style: TextStyle(
                        fontSize: 18,
                        color: isCODAvailable ? Colors.black : Colors.grey),
                  ),
                  subtitle: !isCODAvailable
                      ? const Text(
                          "Currently Unavailable",
                          style: TextStyle(color: Colors.grey),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: "Proceed to Pay",
              onPressed: () async {
                if (selectedValue != "") {
                  print(selectedValue);
                  context.loaderOverlay.show();
                  Map response = await cartViewModel.createOrder(
                      paymentMethod: selectedValue,
                      orderData: widget.orderDetails);
                  print("Order Response $response");
                  context.loaderOverlay.hide();
                  if (response.isNotEmpty) {
                    if (selectedValue == "CASH_ON_DELIVERY" &&
                        response['status'] == true) {
                      Get.off(() => PaymentSuccessFailure(
                            isSuccess: true,
                          ));
                    } else if (selectedValue == "CASH_ON_DELIVERY" &&
                        response['status'] == false) {
                      Get.off(() => PaymentSuccessFailure(
                            isSuccess: false,
                          ));
                    } else {
                      Get.to(() => PaymentProcessing(
                          transcationalDetails: response,
                          orderDetails: widget.orderDetails));
                    }
                  } else {
                    showNotificationSnackBar(
                        "Something went wrong", NotificationStatus.failure);
                  }
                } else {
                  showNotificationSnackBar("Please Choose a Payment Method",
                      NotificationStatus.failure);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
