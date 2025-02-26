import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/domain/OrderController.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/models/dto/my_orders.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/views/common_widgets/CartIcon.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:cubes_n_slice/views/common_widgets/TextFormFieldComponent.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:cubes_n_slice/views/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../constants/assets.dart';

String _formatDeliveryDate(String? timestamp) {
  if (timestamp == null || timestamp.isEmpty) return "Unknown date";

  // Parse the string to an int
  final int? parsedTimestamp = int.tryParse(timestamp);
  if (parsedTimestamp == null) return "Invalid date";

  // Convert the UNIX timestamp to a DateTime object
  final date = DateTime.fromMillisecondsSinceEpoch(parsedTimestamp * 1000);

  // Format the DateTime object to the desired readable string
  return DateFormat('dd MMMM, yyyy hh:mm:ss a').format(date);
}

class OrderDetailPage extends StatefulWidget {
  Order? orderDetail;

  OrderDetailPage({super.key, this.orderDetail});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Color getColor(String currentStatus) {
    List<String> orderFlow = [
      "ORDERED",
      "ACCEPTED",
      "PROCESSING",
      "SHIPPED",
      "DELIVERED",
      "CANCELLED"
    ];
    int currentIndex = orderFlow.indexOf(widget.orderDetail!.orderStatus!);
    int statusIndex = orderFlow.indexOf(currentStatus);

    if (statusIndex < currentIndex) {
      return const Color(0xFF27AA69); // Green for completed
    } else if (statusIndex == currentIndex) {
      return const Color(0xFF27AA69); // Green for current step
    } else {
      return const Color(0xFFDADADA); // Grey for future steps
    }
  }

  String shipmentNote = "";
  Timer? deliveryTimer;
  String? invoicePdfPath = "";
  bool isLoading = false;

  @override
  void initState() {
    print(widget.orderDetail!.pdfPath!);
    () async {
      setState(() {
        isLoading = true;
      });
      if (widget.orderDetail!.orderStatus == "SHIPPED") {
        getDeliveryTime();
        deliveryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          getDeliveryTime();
        });
      }

      File file = await createFileOfPdfUrl(widget.orderDetail!.pdfPath!);
      print("path is ${file.path}");
      setState(() {
        invoicePdfPath = file.path;
      });
      print("pdf path $invoicePdfPath");
      setState(() {
        isLoading = false;
      });
    }();

    super.initState();
  }

  @override
  void dispose() {
    if (deliveryTimer != null) {
      deliveryTimer!.cancel();
    }
    super.dispose();
  }

  void getDeliveryTime() {
    String? estimated_date = widget.orderDetail!.estimatedDate;
    String? estimated_time = widget.orderDetail!.estimatedTime;
    DateTime? estimated_date_formatted =
        DateFormat("yyyy-MM-dd").parse(estimated_date!);
    DateTime currentDate =
        DateFormat("yyyy-MM-dd").parse(DateTime.now().toIso8601String());

    if (estimated_date_formatted.isAtSameMomentAs(currentDate) &&
        estimated_time != null) {
      DateTime now = DateTime.now();
      DateTime deliveryTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(estimated_time.split(":")[0]), // Hours
        int.parse(estimated_time.split(":")[1]), // Minutes
        int.parse(estimated_time.split(":")[2]), // Seconds
      );
      Duration difference = deliveryTime.difference(now);
      if (difference.isNegative) {
        print("Delivery time has passed.");
        shipmentNote = "";
      } else {
        int hours = difference.inHours;
        int minutes = difference.inMinutes % 60;

        // Show the remaining time
        if (hours > 0) {
          shipmentNote = "Delivery within $hours hours";
          print("Delivery within $hours hours");
        } else if (minutes > 0) {
          shipmentNote = "Delivery within $minutes minutes";
          print("Delivery within $minutes minutes");
        } else {
          shipmentNote = "Delivering Soon";
          print("Delivery very soon!");
        }
      }
      setState(() {});
    }
  }

  Future<File> createFileOfPdfUrl(String pdfURL) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url = pdfURL;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");
      if (await file.exists()) {
        print("File already exists. Deleting the old file.");
        await file.delete(); // Delete the existing file
      }

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  final OrderViewModel orderViewModel = Get.find<OrderViewModel>();
  bool hasCancelled = false;

  Future<void> onBottomSheetClosed(bool isCancelled,
      {String orderId = ""}) async {
    context.loaderOverlay.show();
    Order? order = await orderViewModel.getOrderById(orderId: orderId);
    if (order != null) {
      widget.orderDetail = order;
      hasCancelled = true;
      setState(() {});
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    Address? address = widget.orderDetail!.deliveryAddress;
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: MyAppBar(
              leading: BackButton(
                onPressed: () {
                  Get.off(
                      () => HomeScreen(
                            initialIndex: 3,
                          ),
                      arguments: {"hasCancelled": hasCancelled});
                },
              ),
              title: Text(
                "Order Details".toUpperCase(),
                style: GoogleFonts.firaSans(fontWeight: FontWeight.bold),
              ),
              actions: [CartIcon()],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                Assets.imagesAppIcon,
                                width: 60,
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order ID: #${widget.orderDetail!.orderId}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      "Ordered on ${widget.orderDetail!.dateOfPurchase}",
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 7,
                      ),
                      const Text(
                        "Track your Order",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      TimelineTile(
                        alignment: TimelineAlign.manual,
                        lineXY: 0.1,
                        isFirst: true,
                        isLast: widget.orderDetail!.orderStatus == "ORDERED",
                        indicatorStyle: IndicatorStyle(
                          width: 20,
                          color: getColor("ORDERED"),
                          padding: const EdgeInsets.all(6),
                        ),
                        endChild: const _RightChild(
                          title: 'Order Confirmed',
                          message: 'We have received your order.',
                        ),
                        beforeLineStyle: LineStyle(
                          color: getColor("ORDERED"),
                        ),
                      ),
                      widget.orderDetail!.orderStatus != "CANCELLED"
                          ? Column(
                              children: [
                                TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.1,
                                  isFirst: false,
                                  isLast: widget.orderDetail!.orderStatus ==
                                      "ACCEPTED",
                                  indicatorStyle: IndicatorStyle(
                                    width: 20,
                                    color: getColor("ACCEPTED"),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  endChild: _RightChild(
                                    disabled: widget.orderDetail!.orderStatus !=
                                        "ACCEPTED",
                                    title: 'Order Placed',
                                    message: 'Your order has been confirmed.',
                                  ),
                                  beforeLineStyle: LineStyle(
                                    color: getColor("ACCEPTED"),
                                  ),
                                ),
                                TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.1,
                                  isFirst: false,
                                  isLast: widget.orderDetail!.orderStatus ==
                                      "PROCESSING",
                                  indicatorStyle: IndicatorStyle(
                                    width: 20,
                                    color: getColor("PROCESSING"),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  endChild: _RightChild(
                                    disabled: widget.orderDetail!.orderStatus !=
                                        "PROCESSING",
                                    title: 'Order Processed',
                                    message: widget.orderDetail!.orderStatus !=
                                            "PROCESSING"
                                        ? ""
                                        : 'We are preparing your order.',
                                  ),
                                  beforeLineStyle: LineStyle(
                                    color: getColor("PROCESSING"),
                                  ),
                                  afterLineStyle: LineStyle(
                                    color: getColor("PROCESSING"),
                                  ),
                                ),
                                TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.1,
                                  isLast: widget.orderDetail!.orderStatus ==
                                      "SHIPPED",
                                  indicatorStyle: IndicatorStyle(
                                    width: 20,
                                    color: getColor("SHIPPED"),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  endChild: _RightChild(
                                    disabled: widget.orderDetail!.orderStatus ==
                                            "SHIPPED"
                                        ? false
                                        : true,
                                    title: 'Order Shipped',
                                    message: widget.orderDetail!.orderStatus !=
                                            "SHIPPED"
                                        ? ""
                                        : shipmentNote,
                                  ),
                                  beforeLineStyle: LineStyle(
                                    color: getColor("SHIPPED"),
                                  ),
                                ),
                                TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.1,
                                  isLast: true,
                                  indicatorStyle: IndicatorStyle(
                                    width: 20,
                                    color: getColor("DELIVERED"),// Gray for others
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  endChild: _RightChild(
                                    disabled: widget.orderDetail!.orderStatus != "DELIVERED",
                                    title: 'Order Delivered',
                                    message: widget.orderDetail!.orderStatus != "DELIVERED"
                                        ? ""
                                        : 'Your order has been delivered on ${_formatDeliveryDate(widget.orderDetail!.deliveryDate)}',
                                  ),
                                  beforeLineStyle: LineStyle(
                                    color: getColor("DELIVERED"),
                                  ),
                                ),
                              ],
                            )
                          : TimelineTile(
                              alignment: TimelineAlign.manual,
                              lineXY: 0.1,
                              isFirst: false,
                              isLast: true,
                              indicatorStyle: const IndicatorStyle(
                                width: 20,
                                color: Colors.red,
                                padding: EdgeInsets.all(6),
                              ),
                              endChild: _RightChild(
                                title: 'Order Cancelled',
                                message:
                                    'Your order has been Cancelled on ${widget.orderDetail!.cancelDate}.',
                              ),
                              beforeLineStyle: const LineStyle(
                                color: Colors.red,
                              ),
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(10),
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
                            'Deliver Address:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.8),
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => PDFScreen(
                          path: invoicePdfPath,
                        ));
                  },
                  title: const Text("Download Invoice"),
                  trailing: const Icon(Icons.keyboard_double_arrow_right),
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.8),
                ),
                if (widget.orderDetail!.cancelRequest != "0")
                  ListTile(
                    onTap: () => CancellationBottomSheet.show(
                        onSheetClose: onBottomSheetClosed,
                        context: context,
                        orderId: widget.orderDetail!.orderId!),
                    title: const Text("Cancel Order"),
                    trailing: const Icon(Icons.keyboard_double_arrow_right),
                  ),
                if (widget.orderDetail!.cancelRequest != "0")
                  Divider(
                    color: Colors.grey.withOpacity(0.8),
                  ),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Ordered Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 3,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.black.withOpacity(0.5)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.orderDetail!.items!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  OrderItem item =
                                      widget.orderDetail!.items![index];
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: Text(
                                                item.productName!.capitalize ??
                                                    "",
                                                overflow: TextOverflow.clip,
                                              )),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: Text(
                                                  "Qty: ${item.orderQuantity}")),
                                          Text("₹ ${item.orderPrice}")
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  );
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Mode",
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.7)),
                                    ),
                                    Text(
                                      widget.orderDetail!.payment!
                                                  .modeOfPayment ==
                                              "ONLINE_PAYMENT"
                                          ? "ONLINE"
                                          : "CASH",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Order Status",
                                      style: TextStyle(
                                          color: Colors.black.withOpacity(0.7)),
                                    ),
                                    Text(
                                      widget.orderDetail!.orderStatus!,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color:
                                              widget.orderDetail!.orderStatus !=
                                                      "CANCELLED"
                                                  ? Colors.lightGreen
                                                  : Colors.red,
                                          fontWeight: FontWeight.w800),
                                    )
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Amount"),
                                Text("₹ ${widget.orderDetail!.baseAmount}")
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (widget.orderDetail!.deliveryCharge != null &&
                                widget.orderDetail!.deliveryCharge != "0")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Delivery Fee"),
                                  Text(
                                      "₹ ${widget.orderDetail!.deliveryCharge}")
                                ],
                              ),
                            if (widget.orderDetail!.deliveryCharge != null &&
                                widget.orderDetail!.deliveryCharge != "0")
                              const SizedBox(
                                height: 10,
                              ),
                            if (widget.orderDetail!.deliveryTip != null &&
                                widget.orderDetail!.deliveryTip != "0")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tip"),
                                  Text(
                                      "₹ ${widget.orderDetail!.deliveryTip ?? 0}")
                                ],
                              ),
                            if (widget.orderDetail!.deliveryTip != null &&
                                widget.orderDetail!.deliveryTip != "0")
                              const SizedBox(
                                height: 10,
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Platform Fee"),
                                Text(
                                    "₹ ${widget.orderDetail!.platformFee ?? 0}")
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (widget.orderDetail!.discount != null &&
                                widget.orderDetail!.discount != "0.00")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Discount${(widget.orderDetail!.coupon != "" && widget.orderDetail!.coupon != "null") ? "(${widget.orderDetail!.coupon})" : ""}"),
                                  Text("₹ ${widget.orderDetail!.discount}")
                                ],
                              ),
                            if (widget.orderDetail!.discount != null &&
                                widget.orderDetail!.discount != "0.00")
                              const SizedBox(
                                height: 10,
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Grand Total",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  "₹ ${widget.orderDetail!.amount}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          );
  }
}

class _RightChild extends StatelessWidget {
  const _RightChild({
    Key? key,
    required this.title,
    required this.message,
    this.disabled = false,
  }) : super(key: key);

  final String title;
  final String message;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: disabled ? Colors.black.withOpacity(.7) : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  message,
                  style: TextStyle(
                    color:
                        disabled ? Colors.black.withOpacity(.7) : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String? path;

  PDFScreen({Key? key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    print("file path is ${widget.path}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Invoice"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final result = await Share.shareXFiles([XFile(widget.path!)]);

              if (result.status == ShareResultStatus.dismissed) {
                showNotificationSnackBar(
                    "Invoice Shared Successfully", NotificationStatus.success);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }
}

class CancellationBottomSheet {
  static void show(
      {required Function(bool isCancelled, {String orderId}) onSheetClose,
      required BuildContext context,
      required String orderId}) {
    final selectedReason = ''.obs;
    final customReasonController = TextEditingController();
    final OrderViewModel orderViewModel = Get.find<OrderViewModel>();
    final List<String> cancellationReasons = [
      'Wrong meat cut selected',
      'Delivery time is too long',
      'Found better prices elsewhere',
      'Changed my mind about the quantity',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return PopScope(
          onPopInvoked: (didPop) async {
            onSheetClose(false);
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.99,
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
                    // Drag handle
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

                    // Header
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
                          onPressed: () {
                            onSheetClose(false);
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    // Warning message
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
                              'Please let us know why you\'re canceling your order.',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cancellation reasons
                    Obx(() => Column(
                          children: cancellationReasons.map((reason) {
                            return Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.grey[400],
                              ),
                              child: RadioListTile<String>(
                                title: Text(
                                  reason,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                value: reason,
                                groupValue: selectedReason.value,
                                onChanged: (value) =>
                                    selectedReason.value = value!,
                                activeColor: Get.theme.primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),
                        )),

                    // Custom reason text field
                    Obx(() {
                      if (selectedReason.value == 'Other') {
                        return Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: TextFormFieldComponent(
                                maxLength: 200,
                                labelText: "Cancellation Reason",
                                maxlines: 5,
                                minLines: 5,
                                height: 120,
                                hintText: "Cancellation Reason",
                                controller: customReasonController,
                                validation: (String? value) {
                                  if (selectedReason.value == 'Other' &&
                                      (value == null || value == "")) {
                                    return "Please enter a valid cancellation reason.";
                                  }
                                  return null;
                                }));
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Confirm Cancellation",
                      onPressed: () async {
                        if (selectedReason.value == "") {
                          showNotificationSnackBar(
                              "Choose a reason", NotificationStatus.warning);
                        } else {
                          String finalReason = selectedReason.value == 'Other'
                              ? customReasonController.text
                              : selectedReason.value;
                          // Handle cancellation logic here
                          print('Order canceled. Reason: $finalReason');
                          print("orderId is $orderId");
                          context.loaderOverlay.show();
                          String? response = await orderViewModel.cancelOrder(
                              orderId: orderId, cancelReason: finalReason);
                          context.loaderOverlay.hide();
                          if (response == null) {
                            showNotificationSnackBar(
                                "Something went wrong.Contact us through whatsapp to cancel or please try later",
                                NotificationStatus.warning);
                          } else if (response == "success") {
                            onSheetClose(true, orderId: orderId);
                          } else {
                            showNotificationSnackBar(
                                response, NotificationStatus.warning);
                          }
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: Colors.red,
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        onSheetClose(false);
                        Navigator.pop(context);
                      },
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
        );
      },
    ).then((_) => onSheetClose(false));
  }
}
