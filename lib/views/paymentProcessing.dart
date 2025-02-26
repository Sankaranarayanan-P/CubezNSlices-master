import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/views/paymentSuccessFailure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../domain/cartViewModel.dart';

class PaymentProcessing extends StatefulWidget {
  final Map transcationalDetails;
  Map<String, dynamic> orderDetails;

  PaymentProcessing(
      {super.key,
      required this.transcationalDetails,
      required this.orderDetails});

  @override
  State<PaymentProcessing> createState() => _PaymentProcessingState();
}

class _PaymentProcessingState extends State<PaymentProcessing> {
  final Razorpay _razorpay = Razorpay();
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();

  @override
  void initState() {
    context.loaderOverlay.show();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
    initializePayment();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success ${response.data}");
    if (response.data!.isNotEmpty) {
      bool res = await cartViewModel.updateOrderPayment(
          orderId: widget.transcationalDetails['order_id'].toString(),
          status: "success",
          paymentId: response.data?['razorpay_payment_id']);
      if (res) {
        Get.off(() => PaymentSuccessFailure(
              isSuccess: true,
            ));
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    print("Payment Failure ${response.message}");
    bool res = await cartViewModel.updateOrderPayment(
      orderId: widget.transcationalDetails['order_id'].toString(),
      status: "failure",
    );
    if (res) {
      Get.off(() => PaymentSuccessFailure(
            isSuccess: false,
            failedReason: response.message ?? "Something went Wrong",
            transcationalDetails: widget.transcationalDetails,
            orderDetails: widget.orderDetails,
          ));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Payment Wallet ${response.walletName}");
  }

  Future<void> initializePayment() async {
    var options = {
      'key': AppConstants.isDebugMode
          ? AppConstants.razorPayTestKey
          : AppConstants.razorPayLiveKey,
      'amount': widget.orderDetails['grandTotal'] * 100,
      //should pass in paise.
      'name': AppConstants.companyName,
      'order_id': '${widget.transcationalDetails['razorpayOrderId']}',
      // Generate order_id using Orders API
      'description': 'Finest meats, chicken and fish',
      'timeout': 600,
      "image":
          "${AppConstants.siteUrl}assets/dist/img/general/login_logo_3.JPEG",
      "theme": {"color": "#0054b5"},
      "send_sms_hash": true,
      "retry": {"enabled": true, "max_count": 2},
      "currency": widget.transcationalDetails['currency'],
      'prefill': {
        'contact': widget.transcationalDetails['phone'],
        'email': widget.transcationalDetails['email']
      }
    };
    context.loaderOverlay.hide();
    _razorpay.open(options);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              "Processing Payment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
