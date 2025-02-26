import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/models/dto/cart.dart';
import 'package:cubes_n_slice/views/common_widgets/TextFormFieldComponent.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:cubes_n_slice/views/paymentProcessing.dart';
import 'package:cubes_n_slice/views/paymentSuccessFailure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/assets.dart';
import '../domain/cartViewModel.dart';
import '../utils/SnackBarNotification.dart';
import '../utils/myStates.dart';
import 'common_widgets/CustomButton.dart';
import 'common_widgets/SlideToPayCustom.dart';
import 'common_widgets/cart_item.dart';

class orderSummary extends StatefulWidget {
  const orderSummary({super.key});

  @override
  State<orderSummary> createState() => _orderSummaryState();
}

class _orderSummaryState extends State<orderSummary>
    with TickerProviderStateMixin {
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
  final _formKey = GlobalKey<FormState>();
  Set<String> selectedInstructions = {};
  String? appliedCoupon;
  double appliedCouponAmount = 0;
  String? selectedTip;
  TextEditingController otherTipController = TextEditingController();
  TextEditingController customInstructionController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  double CouponAmountSaved = 0;
  double baseOrderAmount = 0;
  double baseDeliveryFee = 0;
  double platformFee = 0;
  double gstCharges = 0;
  double selectedTipAmount = 0;
  double grandTotal = 0;
  double actualGrandTotal = 0;
  bool isLoading = true;
  String couponError = "";
  bool isCouponSuccess = false;
  AnimationController? _lottiesuccesscontroller;
  String? _selectedPaymentMethod;
  List<Map<dynamic, dynamic>> paymentMethods = [];
  bool isOnlinePaymentAvailable = true;
  bool isCODAvailable = true;
  final GlobalKey<SlideActionState> _orderkey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _lottiesuccesscontroller = AnimationController(vsync: this);
    () async {
      // context.loaderOverlay.show();
      await cartViewModel.getCancellationNoteAndPlatformFee();
      await cartViewModel.getCartItemList();
      await cartViewModel.getCoupons();
      await cartViewModel.getAllAddress(is_shipping: true);
      paymentMethods = await cartViewModel.getPaymentMethods();
      calculateTotalPrice();
      setState(() {
        // Check availability based on the fetched data
        isOnlinePaymentAvailable = paymentMethods.any((method) =>
            method['mode'].any((m) => m['name'] == 'ONLINE_PAYMENT'));
        isCODAvailable = paymentMethods.any((method) =>
            method['mode'].any((m) => m['name'] == 'CASH_ON_DELIVERY'));
        isLoading = false;
      });
      // context.loaderOverlay.hide();
    }();
  }

  void calculateTotalPrice() {
    grandTotal = double.parse(
        cartViewModel.grandTotal.value.replaceAll(RegExp(r'[^\d.]'), ''));
    baseOrderAmount = double.parse(
        cartViewModel.baseAmount.value.replaceAll(RegExp(r'[^\d.]'), ''));
    baseDeliveryFee = double.parse(
        cartViewModel.deliveryCharge.value.replaceAll(RegExp(r'[^\d.]'), ''));
    platformFee = double.parse(
        cartViewModel.platformFee.value.replaceAll(RegExp(r'[^\d.]'), ''));
    // Calculate GST charges based on the cart items
    gstCharges = cartViewModel.productCartMap.values.fold(0.0, (sum, item) {
      // Get CGST and SGST rates from the item
      double cgstRate = double.tryParse(item.taxCgst ?? '0') ?? 0;
      double sgstRate = double.tryParse(item.taxSgst ?? '0') ?? 0;

      // Calculate tax amount based on the rates only
      double taxAmount = (cgstRate + sgstRate) / 100;
      int quantity = int.tryParse(item.takenquantity ?? '0') ?? 0;

      return sum + (taxAmount * quantity);
    });
    gstCharges = gstCharges.toPrecision(2); // Round to 2 decimal places
    //calculating grandTotal
    grandTotal = baseOrderAmount + baseDeliveryFee + platformFee + gstCharges;
    if (CouponAmountSaved != 0) {
      grandTotal += CouponAmountSaved;
    }
    actualGrandTotal = grandTotal;
    print("actual price is  $actualGrandTotal");
    setState(() {});
  }

  void _showCouponBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: CouponBottomSheet(
            // formKey: _formKey,
            coupons: cartViewModel.coupons,
            onCouponSelected: (String coupon, double discountedAmount) {
              setState(() {
                couponController.text = coupon;
                CouponAmountSaved = discountedAmount;
                grandTotal = grandTotal - CouponAmountSaved;
                grandTotal = grandTotal.toPrecision(2);
              });
              Navigator.pop(context);
              isCouponSuccess = true;
              setState(() {});
            },
            onApply: (String coupon) {
              // Navigator.pop(context);
              // setState(() {
              //   _applyCoupon(coupon);
              // });
            },
          ),
        );
      },
    );
  }

  Color sliderbackgroundColor = Get.theme.primaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          "Review Order".toUpperCase(),
          style:
              GoogleFonts.firaSans(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? _buildShimmerEffect()
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Obx(() {
                          if (!mounted) {
                            return const SizedBox();
                          }
                          if (cartViewModel.cartState is LoadingState) {
                            return const SizedBox();
                          } else if (cartViewModel.cartState is LoadedState) {
                            final cartItemList =
                                cartViewModel.productCartMap.values.toList();
                            return ListView(
                              children: [
                                ListView.separated(
                                  // scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) {
                                    return const Divider(
                                      color: Color(0xffF1F1F5),
                                    );
                                  },
                                  itemCount:
                                      cartViewModel.productCartMap.length,
                                  itemBuilder: (context, index) {
                                    print(
                                        "coupon is${cartViewModel.coupon.value}");
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      child: CartItemWidget(
                                        item: cartItemList[index],
                                        isOrderSummary: true,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildDeliveryInfo(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Offers & Benefits',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                _buildApplyCoupon(),
                                const SizedBox(height: 16),
                                _buildTipSection(),
                                const SizedBox(height: 16),
                                _buildDeliveryInstructions(),
                                const SizedBox(height: 16),
                                _buildBillDetails(),
                                const SizedBox(height: 16),
                                _paymentSelection(),
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SlideAction(
                                        key: _orderkey,
                                        onSubmit: () async {
                                          // Future.delayed(
                                          //   const Duration(seconds: 1),
                                          //   () =>
                                          //       _orderkey.currentState!.reset(),
                                          // );
                                          // return null;
                                          if (_selectedPaymentMethod == null ||
                                              _selectedPaymentMethod == "") {
                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () => _orderkey.currentState!
                                                  .reset(),
                                            );
                                            await Get.defaultDialog(
                                                title:
                                                    "Payment Confirmation Needed!",
                                                titlePadding:
                                                    const EdgeInsets.all(10),
                                                titleStyle:
                                                    GoogleFonts.firaSans(
                                                        fontSize: 16),
                                                barrierDismissible: false,
                                                middleText:
                                                    "Please Choose a Payment Type",
                                                middleTextStyle:
                                                    GoogleFonts.firaSans(
                                                  fontSize: 14,
                                                ),
                                                confirm: CustomButton(
                                                    text: "Ok",
                                                    onPressed: () {
                                                      Get.back();
                                                    }));
                                            return null;
                                          } else {
                                            context.loaderOverlay.show();
                                            Map<String, dynamic> orderDetails =
                                                {
                                              'baseOrderAmount':
                                                  baseOrderAmount,
                                              'baseDeliveryFee':
                                                  baseDeliveryFee,
                                              'platformFee': platformFee,
                                              'gstCharges': gstCharges,
                                              'grandTotal': grandTotal,
                                              'actualGrandTotal':
                                                  actualGrandTotal,
                                              'couponApplied':
                                                  couponController.text,
                                              'couponAmountSaved':
                                                  CouponAmountSaved,
                                              'selectedTip': selectedTip,
                                              'selectedTipAmount':
                                                  selectedTipAmount,
                                              'deliveryInstructions':
                                                  selectedInstructions
                                                      .toList()
                                                      .toString(),
                                              'customInstruction':
                                                  customInstructionController
                                                              .text.isEmpty ||
                                                          customInstructionController
                                                                  .text ==
                                                              ""
                                                      ? null
                                                      : customInstructionController
                                                          .text,
                                              'cartItems': cartViewModel
                                                  .productCartMap.values
                                                  .toList(),
                                            };
                                            Map response =
                                                await cartViewModel.createOrder(
                                                    paymentMethod:
                                                        _selectedPaymentMethod!,
                                                    orderData: orderDetails);
                                            print("Order Response $response");
                                            context.loaderOverlay.hide();
                                            if (response.isNotEmpty) {
                                              if (_selectedPaymentMethod ==
                                                      "CASH_ON_DELIVERY" &&
                                                  response['status'] == true) {
                                                Get.off(
                                                    () => PaymentSuccessFailure(
                                                          isSuccess: true,
                                                        ));
                                              } else if (_selectedPaymentMethod ==
                                                      "CASH_ON_DELIVERY" &&
                                                  response['status'] == false) {
                                                Get.off(
                                                    () => PaymentSuccessFailure(
                                                          isSuccess: false,
                                                        ));
                                              } else {
                                                Get.to(() => PaymentProcessing(
                                                    transcationalDetails:
                                                        response,
                                                    orderDetails:
                                                        orderDetails));
                                              }
                                            } else {
                                              showNotificationSnackBar(
                                                  "Something went wrong",
                                                  NotificationStatus.failure);
                                            }
                                          }
                                        },
                                        alignment: Alignment.center,
                                        sliderButtonIcon: const Icon(
                                          Icons.keyboard_double_arrow_right,
                                        ),
                                        innerColor: Colors.white,
                                        outerColor: sliderbackgroundColor,
                                        sliderButtonIconPadding: 20,
                                        text: _selectedPaymentMethod == "CASH_ON_DELIVERY"
                                            ? "               Slide to Place Order | ₹${grandTotal.round()}"
                                            : "        Slide to Pay | ₹${grandTotal.round()}",
                                        textStyle: GoogleFonts.firaSans(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        onProgressChanged: (progress) {
                                          if (progress > 0.5) {
                                            setState(() {
                                              sliderbackgroundColor =
                                                  Colors.green;
                                            });
                                          } else {
                                            setState(() {
                                              sliderbackgroundColor =
                                                  Get.theme.primaryColor;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                    // SliderButton(
                                    //   highlightedColor: Colors.grey,
                                    //   backgroundColor: Get.theme.primaryColor,
                                    //   baseColor: Colors.white,
                                    //   buttonSize: 50,
                                    //   width: MediaQuery.of(context).size.width *
                                    //       0.8,
                                    //   action: () async {
                                    //     print("do the payment");
                                    //     return false;
                                    //   },
                                    //   label: const Text(
                                    //     "Slide to Pay",
                                    //     style: TextStyle(
                                    //         color: Color(0xff4a4a4a),
                                    //         fontWeight: FontWeight.w500,
                                    //         fontSize: 17),
                                    //   ),
                                    //   icon: Icon(
                                    //       Icons.keyboard_double_arrow_right),
                                    //   alignLabel: Alignment.center,
                                    //   dismissThresholds: 0.8,
                                    //   vibrationFlag: true,
                                    //   disable: _selectedPaymentMethod == "" ||
                                    //           _selectedPaymentMethod == null
                                    //       ? true
                                    //       : false,
                                    // ),
                                    // CustomButton(
                                    //   text: 'Place Order',
                                    //   onPressed: () {
                                    //     // Create a map with all the order details
                                    //     Map<String, dynamic> orderDetails = {
                                    //       'baseOrderAmount': baseOrderAmount,
                                    //       'baseDeliveryFee': baseDeliveryFee,
                                    //       'platformFee': platformFee,
                                    //       'gstCharges': gstCharges,
                                    //       'grandTotal': grandTotal,
                                    //       'actualGrandTotal': actualGrandTotal,
                                    //       'couponApplied':
                                    //           couponController.text ?? null,
                                    //       'couponAmountSaved':
                                    //           CouponAmountSaved,
                                    //       'selectedTip': selectedTip,
                                    //       'selectedTipAmount':
                                    //           selectedTipAmount,
                                    //       'deliveryInstructions':
                                    //           selectedInstructions.toList(),
                                    //       'customInstruction':
                                    //           customInstructionController
                                    //                       .text.isEmpty ||
                                    //                   customInstructionController
                                    //                           .text ==
                                    //                       ""
                                    //               ? null
                                    //               : customInstructionController
                                    //                   .text,
                                    //       'cartItems': cartViewModel
                                    //           .productCartMap.values
                                    //           .toList(),
                                    //     };
                                    //     log('Order Details: $orderDetails');
                                    //     Get.to(() => PaymentModes(
                                    //         orderDetails: orderDetails));
                                    //     // Get.toNamed("/paymentmode");
                                    //   },
                                    // ),
                                    //CENTER RIGHT -- Emit left
                                  ],
                                )
                              ],
                            );
                          } else {
                            final errorMessage =
                                (cartViewModel.cartState as FailureState)
                                    .errorMessage;
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
                                    onPressed: () =>
                                        {cartViewModel.getCartItemList()},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      shape: const StadiumBorder(),
                                      backgroundColor: Get.theme.primaryColor,
                                    ),
                                    child: const Text(
                                      "Refresh",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                  ],
                ),
                if (isCouponSuccess)
                  Align(
                    alignment: Alignment.center,
                    child: Lottie.asset(
                      Assets.confettiJSON,
                      controller: _lottiesuccesscontroller,
                      repeat: false,
                      onLoaded: (composition) {
                        _lottiesuccesscontroller
                          ?..duration = composition.duration
                          ..forward().whenComplete(() {
                            setState(() {
                              isCouponSuccess = false;
                            });
                          });
                      },
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, __, ___) {
                        return const SizedBox();
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView(
      children: [
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
        const SizedBox(height: 16),
        _buildShimmerPlaceholder(),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 100.0,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBillDetails() {
    print("selected tip is $selectedTip");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBillRow('Item Total', '₹$baseOrderAmount'),
          couponController.text.isNotEmpty
              ? _buildBillRow('Coupon Applied(${couponController.text})',
                  "- ₹$CouponAmountSaved")
              : const SizedBox(),
          _buildBillRow(
            'Delivery Partner Fee',
            cartViewModel.deliveryCharge.value,
          ),
          _buildBillRow(
              'Delivery Tip',
              selectedTip == "" || selectedTip == null
                  ? 'Add tip'
                  : selectedTip! == "Other"
                      ? "₹ ${otherTipController.text.isEmpty ? 0 : otherTipController.text}"
                      : selectedTip!,
              valueColor: selectedTip == "" || selectedTip == null
                  ? Get.theme.primaryColor
                  : Colors.black),
          _buildBillRow('Platform fee', '₹$platformFee'),
          _buildBillRow('GST Charges', '₹$gstCharges'),
          const Divider(height: 24),
          _buildBillRow('To Pay', '₹$grandTotal',
              valueFontWeight: FontWeight.bold,
              valueColor: Colors.black,
              labelFontWeight: FontWeight.bold,
              labelFontSize: 16,
              valueFontSize: 16),
          const SizedBox(height: 16),
          Text(
            'Review your order and address details to avoid cancellations',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          // _buildCancellationNote(),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value,
      {String? subtitle,
      Color valueColor = Colors.black,
      FontWeight valueFontWeight = FontWeight.normal,
      FontWeight labelFontWeight = FontWeight.normal,
      double labelFontSize = 12,
      TextDecoration valueTextDecoration = TextDecoration.none,
      double valueFontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,

                style: TextStyle(
                    fontSize: labelFontSize, fontWeight: labelFontWeight),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: valueFontSize, color: Colors.grey[600]),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
                color: valueColor,
                fontSize: valueFontSize,
                fontWeight: valueFontWeight),
          ),
        ],
      ),
    );
  }

  Widget _paymentSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentOption(
              title: 'Online Payment',
              value: 'ONLINE_PAYMENT',
              isAvailable: isOnlinePaymentAvailable,
              subtitle: "Pay using your UPI/Cards.No Hidden Charges."),
          _buildPaymentOption(
              title: 'Cash on Delivery',
              value: 'CASH_ON_DELIVERY',
              subtitle: 'We request you to tender exact change',
              isAvailable: isCODAvailable),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String title,
      String? subtitle,
      required String value,
      required bool isAvailable}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        onTap: isAvailable
            ? () {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              }
            : null,
        title: Text(
          title,
          style: GoogleFonts.firaSans(
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? isAvailable
                ? Text(
                    subtitle,
                    style: GoogleFonts.firaSans(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                : Text(
                    "Currently Not Available",
                    style: GoogleFonts.firaSans(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
            : null,
        trailing: Radio<String>(
          value: value,
          groupValue: _selectedPaymentMethod,
          activeColor: Get.theme.primaryColor,
          onChanged: isAvailable
              ? (String? selectedValue) {
                  setState(() {
                    _selectedPaymentMethod = selectedValue;
                  });
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildCancellationNote() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cartViewModel.cancellationNote.value,
            style: TextStyle(fontSize: 12, color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Avoid cancellation.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Get.toNamed("/policyPage", parameters: {
                "url": "${AppConstants.siteUrl}page/refundpolicy",
                "title": "Refund Policy"
              });
            },
            child: Text(
              'READ CANCELLATION POLICY',
              style: TextStyle(
                fontSize: 12,
                color: Get.theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    Address? address = cartViewModel.shippingAddress.value.values.firstOrNull;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deliver to:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // TextButton(
              //   onPressed: () {
              //     // Add functionality to change address
              //   },
              //   child: Text(
              //     'Change',
              //     style: GoogleFonts.firaSans(color: Get.theme.primaryColor),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${address?.firstName} ${address?.lastName}, ${address?.postalCode}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "${address?.streetAddress}, ${address?.landmark}\n${address?.city}, ${address?.state}, ${address?.country}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildApplyCoupon() {
    print("coupon controller is ${couponController.text}");
    return GestureDetector(
        onTap: couponController.text.isNotEmpty ? null : _showCouponBottomSheet,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: couponController.text.isNotEmpty
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🎉🥳Coupon Applied: ${couponController.text} 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.green.shade700),
                        onPressed: () {
                          couponController.clear();
                          CouponAmountSaved = 0;
                          grandTotal = actualGrandTotal -
                              CouponAmountSaved +
                              selectedTipAmount;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Apply Coupon', style: TextStyle(fontSize: 16)),
                    Icon(Icons.chevron_right),
                  ],
                ),
        ));
  }

  Widget _buildTipSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Say thanks with a Tip!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              'Day & night, our delivery partners are working hard to deliver your order. Thank them with a tip.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTipButton('₹20'),
              _buildTipButton('₹30', isSelected: true),
              _buildTipButton('₹50'),
              _buildTipButton('Other'),
            ],
          ),
          if (selectedTip == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextField(
                controller: otherTipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter tip amount',
                  prefixText: '₹',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  setState(() {
                    grandTotal += double.parse(otherTipController.text
                        .replaceAll(RegExp(r'[^\d.]'), ''));
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipButton(String text, {bool isSelected = false}) {
    bool isSelected = selectedTip == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedTip = null;
            otherTipController.clear();
            selectedTipAmount = 0;
          } else {
            selectedTip = text;
            if (text != 'Other') {
              otherTipController.clear();
              selectedTipAmount =
                  double.parse(text.replaceAll(RegExp(r'[^\d.]'), ''));
            } else {
              selectedTipAmount = 0;
            }
          }
          // Calculate the new grand total
          grandTotal = actualGrandTotal - CouponAmountSaved + selectedTipAmount;
          grandTotal = grandTotal.toPrecision(2);
        });
      },
      //   setState(() {
      //      double previousTip = selectedTipAmount;
      //     if (isSelected) {
      //       selectedTip = null;
      //       otherTipController.clear();
      //       selectedTipAmount = 0;
      //       // calculateTotalPrice();
      //     } else {
      //       selectedTip = text;

      //       if (text != 'Other') {
      //         otherTipController.clear();
      //         grandTotal = grandTotal +
      //             double.parse(selectedTip!.replaceAll(RegExp(r'[^\d.]'), ''));
      //       } else {
      //         print("in selected else $selectedTip");
      //       }
      //     }
      //     grandTotal = grandTotal.toPrecision(2);
      //   });
      // },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Get.theme.primaryColor : Colors.white,
          border:
              Border.all(color: isSelected ? Colors.white : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Instructions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Row for horizontally scrollable instructions
            SizedBox(
              // height: 150,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildInstructionItem(
                      Icons.notifications_off_outlined,
                      'Avoid ringing bell',
                    ),
                    _buildInstructionItem(
                      Icons.door_front_door_outlined,
                      'Leave at the door',
                    ),
                    _buildInstructionItem(
                      Icons.delivery_dining,
                      'Custom Instruction',
                    ),
                  ],
                ),
              ),
            ),

            // Check if 'Custom Instruction' is selected and display TextFormField accordingly
            if (selectedInstructions.contains('Custom Instruction'))
              Container(
                height: 150,
                padding: const EdgeInsets.only(top: 16.0, right: 16),
                child: TextFormField(
                  controller: customInstructionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter custom instruction',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: null,
                  maxLength: 200,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    print("selected instruction $selectedInstructions");
    bool isSelected = selectedInstructions.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (text == 'Custom Instruction') {
            if (isSelected) {
              selectedInstructions.clear();
            } else {
              selectedInstructions = {'Custom Instruction'};
            }
          } else {
            if (selectedInstructions.contains('Custom Instruction')) {
              selectedInstructions.clear();
            }
            if (isSelected) {
              selectedInstructions.remove(text);
            } else {
              selectedInstructions.add(text);
            }
          }
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.23,
        height: MediaQuery.of(context).size.height * 0.15,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0E8) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 24,
                    color: isSelected ? Get.theme.primaryColor : Colors.black),
                const SizedBox(height: 4),
                Text(
                  text.capitalize!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Get.theme.primaryColor : Colors.black,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child:
                    Icon(Icons.close, size: 16, color: Get.theme.primaryColor),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    otherTipController.dispose();
    super.dispose();
  }
}

class CouponBottomSheet extends StatefulWidget {
  final Function(String, double) onCouponSelected;

  final Function(String) onApply;
  final List<Coupon> coupons;

  CouponBottomSheet({
    super.key,
    // required this.formKey,
    required this.onCouponSelected,
    required this.onApply,
    required this.coupons,
  });

  @override
  _CouponBottomSheetState createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _couponController = TextEditingController();

  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();

  late final List<Coupon> coupons;

  String couponError = "";

  @override
  void initState() {
    super.initState();
    coupons = widget.coupons;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() async {
    setState(() {
      couponError = "";
    });
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      context.loaderOverlay.show();
      print(_couponController.text);
      Map responseData =
          await cartViewModel.checkCoupon(_couponController.text);
      print(responseData);
      // Check if there's an error message in the response
      if (responseData.isEmpty) {
        setState(() {
          couponError = "Not Available";
        });
        formKey.currentState!.validate();
        context.loaderOverlay.hide();
      } else if (responseData.containsKey("error")) {
        setState(() {
          couponError = responseData["error"];
        });
        print(responseData["data"]);
        formKey.currentState!.validate();
        context.loaderOverlay.hide();
      } else {
        // Extract coupon data on successful response
        Map couponData = responseData;
        double discountAmount = 0.0;

        // Calculate discount amount based on the coupon type
        if (couponData["discount_type"] == "PERCENTAGE") {
          discountAmount = (double.parse(cartViewModel.baseAmount.value
                      .replaceAll(RegExp(r'[^\d.]'), '')) *
                  double.parse(couponData["discount_percentage"])) /
              100;
          if (discountAmount > double.parse(couponData["maximum_amount"])) {
            discountAmount = double.parse(couponData["maximum_amount"]);
          }
        } else if (couponData["discount_type"] == "AMOUNT") {
          discountAmount = double.parse(couponData["discount_amount"]);
        }
        double baseAmount = double.parse(
            cartViewModel.baseAmount.value.replaceAll(RegExp(r'[^\d.]'), ''));
        double difference =
            double.parse(couponData['minimum_amount']) - baseAmount;

        if (double.parse(couponData['minimum_amount']) >
            double.parse(cartViewModel.baseAmount.value
                .replaceAll(RegExp(r'[^\d.]'), ''))) {
          setState(() {
            couponError = "Add ₹${difference.ceil()} more to avail";
          });
          showNotificationSnackBar("Add ₹${difference.ceil()} more to avail",
              NotificationStatus.warning);
          context.loaderOverlay.hide();
        } else {
          context.loaderOverlay.hide();
          widget.onCouponSelected(_couponController.text, discountAmount);
        }
      }
    } else {
      print("form invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("coupons: ${coupons.map((c) => c.toJson()).toList()}");
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coupons Just for you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Form(
            key: formKey,
            child: TextFormFieldComponent(
              controller: _couponController,
              suffixIcon: TextButton(
                onPressed: _applyCoupon,
                child: const Text("Apply"),
              ),
              validation: (value) {
                if (value == null || value.isEmpty) {
                  return "Please type a coupon";
                }
                if (couponError != "") {
                  return couponError;
                }
                return null;
              },
            ),
            // child: TextFormField(
            //   controller: _couponController,
            //   decoration: InputDecoration(
            //     hintText: 'Type coupon code here',
            //     suffixIcon: TextButton(
            //       onPressed: _applyCoupon,
            //       child: const Text('APPLY'),
            //     ),
            //     border: const OutlineInputBorder(),
            //   ),
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return "Please type a coupon";
            //     }
            //     if (widget.couponError != "") {
            //       return widget.couponError;
            //     }
            //     return null;
            //   },
            // ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AVAILABLE COUPONS',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    // height: ,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final coupon = coupons[index];
                        String discount = "";
                        String description = "";
                        double discountAmount = 0.0;
                        bool isAvailable = false;
                        if (coupon.discountType == "PERCENTAGE") {
                          discount =
                              "${coupon.discountPercentage}% OFF upto ₹${coupon.maximumAmount}";
                          description =
                              "Save ₹${coupon.maximumAmount} on order above ₹${coupon.minimumAmount}";
                        } else if (coupon.discountType == "AMOUNT") {
                          discount = "Flat ₹${coupon.discountAmount} OFF";
                          description =
                              "Save FLAT ₹${coupon.discountAmount} on order above ₹${coupon.minimumAmount}";
                        }
                        if (coupon.minimumAmount <=
                            double.parse(cartViewModel.baseAmount.value
                                .replaceAll(RegExp(r'[^\d.]'), ''))) {
                          isAvailable = true;
                        }
                        print("isAvailable: $isAvailable");
                        if (isAvailable) {
                          if (coupon.discountType == "PERCENTAGE") {
                            discountAmount = (double.parse(cartViewModel
                                        .baseAmount.value
                                        .replaceAll(RegExp(r'[^\d.]'), '')) *
                                    coupon.discountPercentage) /
                                100;
                            if (discountAmount > coupon.maximumAmount) {
                              discountAmount = coupon.maximumAmount;
                            }
                          } else if (coupon.discountType == "AMOUNT") {
                            discountAmount = coupon.discountAmount;
                          }

                          print("discounted prices $discountAmount");
                          return _CouponItem(
                            discount: discount,
                            description: description,
                            code: coupon.couponName,
                            isAvailable: true,
                            onTap: () => widget.onCouponSelected(
                                coupon.couponName, discountAmount),
                          );
                        } else {
                          double baseAmount = double.parse(cartViewModel
                              .baseAmount.value
                              .replaceAll(RegExp(r'[^\d.]'), ''));
                          double difference = coupon.minimumAmount - baseAmount;
                          return _CouponItem(
                            discount: discount,
                            description:
                                "Add ₹${difference.ceil()} more to avail",
                            code: coupon.couponName,
                            isAvailable: false,
                            onTap:
                                () {}, // Disabled tap for unavailable coupons
                          );
                        }
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 8);
                      },
                      itemCount: coupons.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponItem extends StatelessWidget {
  final String discount;
  final String description;
  final String code;
  final VoidCallback onTap;
  final bool isAvailable;

  const _CouponItem({
    required this.discount,
    required this.description,
    required this.code,
    required this.onTap,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                discount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
                fontSize: 12, color: isAvailable ? Colors.grey : Colors.red),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isAvailable ? onTap : null,
            child: Text(
              'TAP TO APPLY',
              style: TextStyle(
                  color: isAvailable ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
