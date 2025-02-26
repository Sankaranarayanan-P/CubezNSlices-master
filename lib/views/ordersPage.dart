import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/constants/assets.dart';
import 'package:cubes_n_slice/domain/OrderController.dart';
import 'package:cubes_n_slice/views/common_widgets/CartIcon.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:cubes_n_slice/views/orderDetailpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';

import '../models/dto/my_orders.dart';

class OrdersPage extends StatefulWidget {
  final bool hasCancelledOrder;
  const OrdersPage({super.key, this.hasCancelledOrder = false});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderViewModel orderViewModel = Get.find<OrderViewModel>();
  List<Order> orders = [];
  bool isLoading = false;
  @override
  void initState() {
    () async {
      await _loadOrders();
    }();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("get arguments ${Get.arguments}");
      if (widget.hasCancelledOrder ||
          (Get.arguments != null &&
              Get.arguments is Map &&
              Get.arguments["hasCancelled"] == true)) {
        _loadOrders();
      }
    });
    super.initState();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });
    context.loaderOverlay.show();
    orders.clear();
    orders = await orderViewModel.getAllOrders();
    setState(() {
      isLoading = false;
    });
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white.withOpacity(0.9),
      appBar: MyAppBar(
        title: Text(
          'MY ORDERS',
          style: GoogleFonts.firaSans(fontWeight: FontWeight.bold),
        ),
        leading: Get.currentRoute == "/HomeScreen" ? const SizedBox() : null,
        actions: [CartIcon()],
      ),
      body: isLoading
          ? const SizedBox()
          : orders.isNotEmpty
              ? ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    Order order = orders[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: const EdgeInsets.all(8),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            Assets.imagesAppIcon,
                                            width: 80,
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Order #${order.orderId}",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                child: Text(
                                                  "Ordered on ${order.dateOfPurchase}",
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Total Items"),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      "${order.items?.length} Items")
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                // order.orderStatus == "CANCELLED"
                                //     ? Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.center,
                                //         children: [
                                //           Container(
                                //             width: 200,
                                //             padding: const EdgeInsets.all(8),
                                //             decoration: BoxDecoration(
                                //                 color: Colors.red,
                                //                 borderRadius:
                                //                     BorderRadius.circular(20),
                                //                 border: Border.all(
                                //                     color: Colors.black)),
                                //             child: const Text(
                                //               "Cancelled",
                                //               textAlign: TextAlign.center,
                                //               style: TextStyle(
                                //                   color: Colors.white),
                                //             ),
                                //           ),
                                //         ],
                                //       )
                                //     : const SizedBox(),
                                const Divider(),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Items",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(12),
                                            backgroundColor:
                                                Get.theme.primaryColor,
                                            foregroundColor: Colors.white),
                                        onPressed: () {
                                          Get.to(() => OrderDetailPage(
                                              orderDetail: orders[index]));
                                        },
                                        child: Row(
                                          children: [
                                            order.orderStatus != "CANCELLED" &&
                                                    order.orderStatus !=
                                                        "DELIVERED"
                                                ? Text(
                                                    "Track Order",
                                                    style:
                                                        GoogleFonts.firaSans(),
                                                  )
                                                : const Text("View Details"),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Icon(order.orderStatus !=
                                                        "CANCELLED" &&
                                                    order.orderStatus !=
                                                        "DELIVERED"
                                                ? Icons.delivery_dining_outlined
                                                : Icons.chevron_right_outlined),
                                          ],
                                        ))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                      ),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: order.items!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            OrderItem item =
                                                order.items![index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    child: CachedNetworkImage(
                                                      imageUrl: item.image!,
                                                      width: 70,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Text(
                                                          item.productName!)),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                      child: Text(
                                                          "Qty:${item.orderQuantity}")),
                                                  Text("₹ ${item.orderPrice}")
                                                ],
                                              ),
                                            );
                                          }),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  thickness: .5,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Amount"),
                                    Row(
                                      children: [
                                        const Text(
                                          "+",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("₹ ${order.baseAmount}"),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (order.deliveryCharge != null &&
                                    order.deliveryCharge != "0.00")
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Delivery Fee"),
                                      Row(
                                        children: [
                                          const Text(
                                            "+",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 18),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("₹ ${order.deliveryCharge}"),
                                        ],
                                      )
                                    ],
                                  ),
                                if (order.deliveryCharge != null &&
                                    order.deliveryCharge != "0.00")
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (order.deliveryTip != null &&
                                    order.deliveryTip != "0")
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Tip"),
                                      Row(
                                        children: [
                                          const Text(
                                            "+",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 18),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("₹ ${order.deliveryTip ?? 0}"),
                                        ],
                                      )
                                    ],
                                  ),
                                if (order.deliveryTip != null &&
                                    order.deliveryTip != "0")
                                  const SizedBox(
                                    height: 10,
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Platform Fee"),
                                    Row(
                                      children: [
                                        const Text(
                                          "+",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("₹ ${order.platformFee ?? 0}"),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (order.discount != null &&
                                    order.discount != "0.00")
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Discount${(order.coupon != "" && order.coupon != "null") ? "(${order.coupon})" : ""}"),
                                      Row(
                                        children: [
                                          const Text(
                                            "-",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("₹ ${order.discount}"),
                                        ],
                                      )
                                    ],
                                  ),
                                if (order.discount != null &&
                                    order.discount != "0.00")
                                  const SizedBox(
                                    height: 10,
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Grand Total",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "₹ ${order.amount}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                order.orderStatus == "CANCELLED"
                                    ? Card(
                                        child: Container(
                                          // height: 45,
                                          color: Colors.red[200],
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10,
                                                left: 6,
                                                bottom: 3,
                                                top: 3),
                                            child: Row(
                                              children: [
                                                const Spacer(),
                                                Column(
                                                  children: [
                                                    const Text(
                                                      "This order was cancelled",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    order.cancelNote == null ||
                                                            order.cancelNote ==
                                                                "" ||
                                                            order.cancelNote ==
                                                                " "
                                                        ? const SizedBox()
                                                        : Text(
                                                            "Reason : ${order.cancelNote}",
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                  ],
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    children: [
                      LottieBuilder.asset(
                        Assets.noData,
                        repeat: false,
                      ),
                      Text(
                        "No Orders Available",
                        style: GoogleFonts.firaSans(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      CustomButton(
                          text: "Shop Now",
                          onPressed: () => Get.toNamed("/vegetables",
                                  arguments: {
                                    "feature_type": "Top Selling Products"
                                  }),
                          widthFactor: .5)
                    ],
                  ),
                ),
    );
  }
}

class CancellationController extends GetxController {
  final selectedReason = RxString('');
  final customReason = RxString('');
  final TextEditingController customReasonController = TextEditingController();

  final List<String> cancellationReasons = [
    'Wrong meat cut selected',
    'Delivery time is too long',
    'Found better prices elsewhere',
    'Changed my mind about the quantity',
    'Other'
  ];

  @override
  void onClose() {
    customReasonController.dispose();
    super.onClose();
  }

  void setReason(String reason) {
    selectedReason.value = reason;
  }

  void setCustomReason(String reason) {
    customReason.value = reason;
  }

  void confirmCancellation() {
    String finalReason = selectedReason.value == 'Other'
        ? customReason.value
        : selectedReason.value;
    // Handle your cancellation logic here
    print('Order canceled. Reason: $finalReason');
    Get.back();
  }
}

class CancellationBottomSheet {
  static void show() {
    final CancellationController controller = Get.put(CancellationController());

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cancel Order',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please let us know why you\'re canceling your meat order.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => Column(
                      children: controller.cancellationReasons.map((reason) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(reason),
                          leading: Radio<String>(
                            value: reason,
                            groupValue: controller.selectedReason.value,
                            onChanged: (value) => controller.setReason(value!),
                            activeColor: Colors.red,
                          ),
                        );
                      }).toList(),
                    )),
                Obx(() {
                  if (controller.selectedReason.value == 'Other') {
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: controller.customReasonController,
                        onChanged: controller.setCustomReason,
                        decoration: const InputDecoration(
                          hintText: 'Please explain your reason...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.confirmCancellation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Cancellation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text(
                    'Keep Order',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }
}
