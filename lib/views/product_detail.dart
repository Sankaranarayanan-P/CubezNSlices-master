import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/views/common_widgets/TextFormFieldComponent.dart';
import 'package:cubes_n_slice/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../constants/appConstants.dart';
import '../constants/assets.dart';
import '../domain/cartViewModel.dart';
import '../domain/productViewModel.dart';
import '../models/dto/cart.dart';
import '../models/dto/product.dart';
import 'common_widgets/CartIcon.dart';
import 'common_widgets/Search.dart';
import 'common_widgets/appBar.dart';
import 'common_widgets/item_key_points_view.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
  final ProductViewModel productViewModel = Get.find<ProductViewModel>();
  Product product = Get.arguments as Product;
  late final List<CachedNetworkImageProvider> multiImageProvider;
  bool hasCartItem = false;
  CartItem? cartProduct;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    () async {
      setState(() {
        isLoading = true;
      });
      print(Get.parameters['from_page']);
      context.loaderOverlay.show();
      product =
          (await productViewModel.getProductById(int.tryParse(product.id!)!)) ??
              Get.arguments;
      final cartItem = cartViewModel.productCartMap[product.id.toString()];

      if (cartItem != null && cartItem.id == product.id) {
        hasCartItem = true;
        cartProduct = cartItem;
        print("daf ${cartItem.specification!['cleaning']}");
      } else {
        hasCartItem = false;
        cartProduct = null;
      }
      setState(() {
        isLoading = false;
      });
      context.loaderOverlay.hide();
    }();
    multiImageProvider = [
      CachedNetworkImageProvider(product.imageUrl ?? ''),
      CachedNetworkImageProvider(product.imageUrl ?? ''),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget productDescription = Html(
      data: product.description ?? "",
    );
    return Scaffold(
      appBar: MyAppBar(
          title: const SearchOverlay(),
          leading: InkResponse(
              onTap: () => Get.back(), child: const BackButtonIcon()),
          actions: <Widget>[CartIcon()]),
      body: isLoading
          ? const SizedBox()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      InkResponse(
                        onTap: () => {
                          Get.to(
                            () => PhotoViewGallery.builder(
                              scrollPhysics: const BouncingScrollPhysics(),
                              builder: (BuildContext context, int index) {
                                return PhotoViewGalleryPageOptions(
                                  maxScale:
                                      PhotoViewComputedScale.covered * 1.1,
                                  minScale:
                                      PhotoViewComputedScale.contained * 0.8,
                                  imageProvider: multiImageProvider[index],
                                  filterQuality: FilterQuality.high,
                                  initialScale:
                                      PhotoViewComputedScale.contained * 0.8,
                                  heroAttributes: PhotoViewHeroAttributes(
                                      tag: product.id ?? "",
                                      transitionOnUserGestures: true),
                                );
                              },
                              itemCount: multiImageProvider.length,
                              pageController: PageController(initialPage: 0),
                              backgroundDecoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                          )
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              // border: Border(
                              // bottom: BorderSide(
                              // width: 4, color: Get.theme.primaryColor),
                              // left: BorderSide(
                              //     width: 4, color: Get.theme.primaryColor),
                              // right: BorderSide(
                              //     width: 4, color: Get.theme.primaryColor)
                              // ),
                              borderRadius: BorderRadius.circular(80)
                              // borderRadius: BorderRadius.vertical(
                              //     bottom: Radius.elliptical(
                              //         MediaQuery.of(context).size.width, 140.0))
                              ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Hero(
                              tag: product.id!,
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl ?? '',
                                // width: 140,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,

                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorWidget: (context, url, error) =>
                                    Image.asset(Assets.noImage),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.price != product.specialPrice)
                              Text(
                                product.price!,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            Text(
                              product.specialPrice!,
                              style: const TextStyle(
                                color: Color(0xffFF324B),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   "/${product.measurement ?? ""}",
                            //   style: const TextStyle(fontSize: 15),
                            // )

                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              product.productName ?? "????",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    int.parse(product.quantity!) == 0
                                        ? const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(FontAwesomeIcons.ban),
                                              SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  "Out of Stock",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    int.parse(product
                                                                .quantity!) <
                                                            5
                                                        ? Row(
                                                            children: [
                                                              Lottie.asset(
                                                                  Assets
                                                                      .announcementAnimation,
                                                                  width: 50),
                                                              const SizedBox(
                                                                  width: 8),
                                                              const Flexible(
                                                                child: Text(
                                                                  "Only few Quantity Left!",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                              ),

                                                            ],
                                                          )
                                                        : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image.asset(
                                                                  Assets
                                                                      .imagesFastDelivery,
                                                                  width: 50),
                                                              const SizedBox(
                                                                  width: 8),
                                                              const Flexible(
                                                                child: Text(
                                                                  "Ready to be delivered to your doorstep",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              !hasCartItem
                                                  ? ElevatedButton(
                                                      onPressed: () {
                                                        showBottomSheetProductChoosing();
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        textStyle: GoogleFonts
                                                            .firaSans(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                        shape:
                                                            const StadiumBorder(),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                      child: Text(
                                                        "Add to Cart",
                                                        style: GoogleFonts
                                                            .firaSans(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                    cartProduct != null
                                        ? Wrap(
                                            children: [
                                              const Text("Amount: "),
                                              if (cartProduct!.OfferPrice !=
                                                      null &&
                                                  cartProduct!.OfferPrice !=
                                                      "0" &&
                                                  cartProduct!.OfferPrice !=
                                                      cartProduct!.sellPrice)
                                                Text(
                                                  cartProduct!.currency! +
                                                      cartProduct!.sellPrice!,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              if (cartProduct!.OfferPrice !=
                                                      null &&
                                                  cartProduct!.OfferPrice !=
                                                      "0" &&
                                                  cartProduct!.OfferPrice !=
                                                      cartProduct!.sellPrice)
                                                const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  cartProduct!.currency! +
                                                      (cartProduct!.OfferPrice !=
                                                                  null &&
                                                              cartProduct!
                                                                      .OfferPrice !=
                                                                  "0"
                                                          ? cartProduct!
                                                              .OfferPrice!
                                                          : cartProduct!
                                                              .sellPrice!),
                                                  style: const TextStyle(
                                                    color: Color(
                                                        0xffFF324B), // Red for special price
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                    overflow: TextOverflow.ellipsis
                                                ),
                                              ),

                                              const Spacer(),


                                              InkWell(
                                                onTap: () async {
                                                  // if (int.parse(cartProduct!
                                                  //             .takenquantity ??
                                                  //         "1") >
                                                  //     1) {
                                                  //   setState(() {
                                                  //     int quantity = int.parse(
                                                  //         cartProduct!
                                                  //                 .takenquantity ??
                                                  //             "1");
                                                  //     quantity--;
                                                  //     cartProduct?.takenquantity =
                                                  //         quantity.toString();
                                                  //   });
                                                  try {
                                                    //     double basePrice =
                                                    //         double.tryParse(cartProduct!
                                                    //                 .sellPrice!) ??
                                                    //             0.0;
                                                    //     int quantity = int.tryParse(
                                                    //             cartProduct!
                                                    //                 .takenquantity!) ??
                                                    //         1;

                                                    //     double grandTotal =
                                                    //         basePrice * quantity;

                                                    //     if (cartProduct!
                                                    //             .specification !=
                                                    //         null) {
                                                    //       cartProduct!.specification!
                                                    //           .forEach((key, value) {
                                                    //         final selectedSpec = product
                                                    //             .specifications
                                                    //             ?.firstWhere(
                                                    //           (spec) =>
                                                    //               spec.specification ==
                                                    //               key,
                                                    //           orElse: () =>
                                                    //               Specification(),
                                                    //         );

                                                    //         if (selectedSpec != null) {
                                                    //           final selectedOption =
                                                    //               selectedSpec.options
                                                    //                   ?.firstWhere(
                                                    //             (option) =>
                                                    //                 option.option ==
                                                    //                 value,
                                                    //             orElse: () => Option(),
                                                    //           );

                                                    //           // Add the specification's additional price (if any) to grandTotal
                                                    //           if (selectedOption !=
                                                    //                   null &&
                                                    //               selectedOption
                                                    //                       .amount !=
                                                    //                   null) {
                                                    //             grandTotal += double.tryParse(
                                                    //                     selectedOption
                                                    //                         .amount!) ??
                                                    //                 0.0;
                                                    //           }
                                                    //         }
                                                    // });
                                                    // }
                                                    context.loaderOverlay
                                                        .show();
                                                    await cartViewModel
                                                        .removeFromCart(
                                                            cartProduct!);
                                                    setState(() {
                                                      // Refresh the cartProduct data
                                                      cartProduct = cartViewModel
                                                              .productCartMap[
                                                          product.id
                                                              .toString()];
                                                      hasCartItem =
                                                          cartProduct != null;
                                                    });
                                                    context.loaderOverlay
                                                        .hide();
                                                  } catch (e) {
                                                    context.loaderOverlay
                                                        .hide();
                                                    showSnackBarWithMessage({
                                                      "response": "failure",
                                                      "message":
                                                          "Something went wrong.Please try later"
                                                    });
                                                  }
                                                  // }
                                                },
                                                child: Image.asset(
                                                  Assets.imagesRemoveIcon,
                                                  width: 28,
                                                  height: 28,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                cartProduct?.takenquantity ??
                                                    "1",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              InkWell(
                                                onTap: (() async {
                                                  setState(() {
                                                    if (int.parse(product
                                                                    .quantity ??
                                                                "0") !=
                                                            0 &&
                                                        int.parse(product
                                                                    .quantity ??
                                                                "0") >=
                                                            int.parse(cartProduct!
                                                                    .takenquantity ??
                                                                "1")) {
                                                      int quantity = int.parse(
                                                          cartProduct!
                                                                  .takenquantity ??
                                                              "1");
                                                      quantity++;
                                                      cartProduct
                                                              ?.takenquantity =
                                                          quantity.toString();
                                                    }
                                                  });
                                                  try {
                                                    context.loaderOverlay
                                                        .show();
                                                    Map<String, dynamic>
                                                        response = {};
                                                    response = await cartViewModel
                                                        .addToCart(CartItem(
                                                            product: Product(
                                                              id: cartProduct!
                                                                  .id,
                                                              imageUrl:
                                                                  cartProduct!
                                                                      .imageUrl,
                                                              productName:
                                                                  cartProduct!
                                                                      .productName,
                                                              quantity:
                                                                  cartProduct!
                                                                      .quantity,
                                                              price:
                                                                  cartProduct!
                                                                      .price,
                                                              offerPercentage:
                                                                  cartProduct!
                                                                      .offerPercentage,
                                                              specialPrice:
                                                                  cartProduct!
                                                                      .OfferPrice,
                                                              weight:
                                                                  cartProduct!
                                                                      .weight,
                                                              description:
                                                                  cartProduct!
                                                                      .description,
                                                              specialFromDate:
                                                                  cartProduct!
                                                                      .specialFromDate,
                                                              specialToDate:
                                                                  cartProduct!
                                                                      .specialToDate,
                                                              currency:
                                                                  cartProduct!
                                                                      .currency,
                                                            ),
                                                            sellPrice: cartProduct!
                                                                .sellPrice,
                                                            OfferPrice: cartProduct!
                                                                .OfferPrice,
                                                            takenquantity:
                                                                (int.parse(cartProduct!.takenquantity!))
                                                                    .toString(),
                                                            chosenWeight: cartProduct!
                                                                .chosenWeight,
                                                            specification:
                                                                cartProduct!
                                                                    .specification,
                                                            productTotal: (cartProduct!.OfferPrice !=
                                                                        null &&
                                                                    cartProduct!.OfferPrice !=
                                                                        "0" &&
                                                                    cartProduct!.OfferPrice !=
                                                                        cartProduct!
                                                                            .sellPrice)
                                                                ? (double.parse(cartProduct!.OfferPrice!) *
                                                                        (int.parse(cartProduct!.takenquantity!)))
                                                                    .toStringAsFixed(2)
                                                                : (double.parse(cartProduct!.sellPrice!) * (int.parse(cartProduct!.takenquantity!))).toStringAsFixed(2),
                                                            AvailableitemQuantity: int.parse(cartProduct!.quantity!)));
                                                    context.loaderOverlay
                                                        .hide();
                                                    print(
                                                        "response is $response");
                                                    showSnackBarWithMessage(
                                                        response);
                                                    setState(() {
                                                      // Refresh the cartProduct data
                                                      cartProduct = cartViewModel
                                                              .productCartMap[
                                                          product.id
                                                              .toString()];
                                                      hasCartItem =
                                                          cartProduct != null;
                                                    });
                                                  } catch (e) {
                                                    context.loaderOverlay
                                                        .hide();
                                                    showSnackBarWithMessage({
                                                      "response": "failure",
                                                      "message":
                                                          "Something went wrong.Please try later"
                                                    });
                                                  }
                                                }),
                                                child: Image.asset(
                                                  Assets.imagesAddIcon,
                                                  width: 28,
                                                  height: 28,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            productDescription,
                            const SizedBox(
                              height: 14,
                            ),
                            product.specialities != null &&
                                    product.specialities!.isNotEmpty
                                ? Container(
                                    alignment: Alignment.topCenter,
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    // height:
                                    //     MediaQuery.of(context).size.height * 0.4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Our Specialities',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff23AA49),
                                            ),
                                          ),
                                        ),
                                        if (product.specialities!.length == 1)
                                          Center(
                                            // Center the GridView if there's only one item
                                            child: Container(
                                              margin: const EdgeInsets.all(10),
                                              width: 200,
                                              child: ItemKeyPointsView(
                                                imagePath: AppConstants
                                                        .siteUrl +
                                                    (product.specialities![0]
                                                            ['thumbnail'] ??
                                                        ''),
                                                title: product.specialities![0]
                                                        ['speciality_name'] ??
                                                    '',
                                                desc: product.specialities![0]
                                                        ['description'] ??
                                                    '',
                                              ),
                                            ),
                                          )
                                        else
                                          GridView.builder(
                                            padding: const EdgeInsets.all(8),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing:
                                                  8, // spacing between columns
                                              mainAxisSpacing: 8,
                                              // childAspectRatio: 3 / 2.5,
                                            ),
                                            itemCount:
                                                product.specialities!.length,
                                            itemBuilder: (context, index) {
                                              final speciality =
                                                  product.specialities![index];
                                              return ItemKeyPointsView(
                                                imagePath:
                                                    AppConstants.siteUrl +
                                                        speciality['thumbnail'],
                                                title: speciality[
                                                        'speciality_name'] ??
                                                    '',
                                                desc:
                                                    speciality['description'] ??
                                                        '',
                                              );
                                            },
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(), // Disable internal scrolling if needed
                                          ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))),
                  // _buildBottomBar()
                ]),
      floatingActionButton: !hasCartItem
          ? const SizedBox()
          : Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.09,
              child: FloatingActionButton(
                onPressed: () {
                  Get.to(() => HomeScreen(
                        initialIndex: 2,
                      ));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${cartProduct!.takenquantity} Item | ",
                              style: GoogleFonts.firaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              cartProduct!.currency! +
                                  cartProduct!.productTotal!,
                              style: GoogleFonts.firaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "View Cart",
                        style: GoogleFonts.firaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomBar() {
    final cartItem = cartViewModel.productCartMap[product.id.toString()];
    final hasCartItem = cartItem != null && cartItem.id == product.id;

    // return Stack(
    //   children: [
    //     Align(
    //       alignment: Alignment.bottomCenter,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           if (hasCartItem)
    //             Padding(
    //               padding: const EdgeInsets.only(right: 16),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   const Text(
    //                     "Total",
    //                     style: TextStyle(
    //                       fontSize: 18,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                   Text(
    //                     cartProduct!.currency! + cartProduct!.productTotal!,
    //                     style: const TextStyle(
    //                       color: Colors.red,
    //                       fontSize: 16,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           Expanded(
    //             child: CustomButton(
    //               text: "Buy Now".toUpperCase(),
    //               onPressed: () {
    //                 hasCartItem
    //                     ? Get.to(() => HomeScreen(initialIndex: 2))
    //                     : showBottomSheetProductChoosing();
    //               },
    //               backgroundColor: Theme.of(context).primaryColor,
    //               textColor: Colors.white,
    //               widthFactor: hasCartItem ? 1 : 0.6, // Adjust width
    //               padding: const EdgeInsets.symmetric(vertical: 16),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
    return FloatingActionButton(
      onPressed: () {},
    );
  }

  void showBottomSheetProductChoosing() {
    showModalBottomSheet(
        context: context,
        elevation: 3,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.70,
              maxChildSize: 0.70,
              minChildSize: 0.70,
              expand: false,
              builder: (context, scrollController) {
                return ProductSpecChooserSheet(product: product);
              });
        });
  }
}

class ProductSpecChooserSheet extends StatefulWidget {
  const ProductSpecChooserSheet({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductSpecChooserSheet> createState() =>
      _ProductSpecChooserSheetState();
}

class _ProductSpecChooserSheetState extends State<ProductSpecChooserSheet> {
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
  WeightWithPrice? selectedWeight;
  Map<String, String> selectedSpecifications = {};
  Map<String, Map<String, dynamic>> selectedSpecificationDetails = {};
  int quantity = 1;
  double grandTotalSpecial = 0;
  double grandTotalRegular = 0;
  TextEditingController messageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    if (grandTotalSpecial == 0) {
      grandTotalSpecial = double.tryParse(widget
                          .product.availableWeightsWithPrice!.first.price !=
                      widget.product.availableWeightsWithPrice!.first
                          .specialPrice &&
                  widget.product.availableWeightsWithPrice!.first
                          .specialPrice !=
                      "0"
              ? widget.product.availableWeightsWithPrice!.first.specialPrice!
              : widget.product.availableWeightsWithPrice!.first.price ?? "0") ??
          0.0;
      grandTotalRegular = double.tryParse(
              widget.product.availableWeightsWithPrice!.first.price ?? "0") ??
          0.0;
      setState(() {
        isLoading = false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isLoading
          ? const SizedBox()
          : Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: const Color(0xDAECECEC),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      widget.product.imageUrl!,
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                widget.product.productName ?? "",
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  width: 500,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 18),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Weight of the product"),
                                            const Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text(
                                                "Select one option only",
                                                style: TextStyle(
                                                  color: Color(0xDAA9A8A8),
                                                ),
                                              ),
                                            ),
                                            buildWeightRadioList(),
                                          ]))),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  width: 500,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 18),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                                "Choose your preferences"),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(
                                                "Required * ${widget.product.specifications!.length} available",
                                                style: const TextStyle(
                                                  color: Color(0xDAA9A8A8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildSpecificationsRadioList(),
                                          ]))),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  width: 500,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 18),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Add an Instruction"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              // height: 100,
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: TextFormFieldComponent(
                                                  height: 100,
                                                  labelText:
                                                      "Write your Instruction here...",
                                                  hintText:
                                                      "Write your Instruction here...",
                                                  minLines: 6,
                                                  maxlines: null,
                                                  maxLength: 200,
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  controller: messageController,
                                                  validation: (String? value) {
                                                    return null;
                                                  }),
                                            )
                                          ]))),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                  _recalculatePrice();
                                }
                              },
                              child: Image.asset(
                                Assets.imagesRemoveIcon,
                                width: 28,
                                height: 28,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            InkWell(
                              onTap: (() async {
                                setState(() {
                                  if (int.parse(
                                              widget.product.quantity ?? "0") !=
                                          0 &&
                                      int.parse(
                                              widget.product.quantity ?? "0") >=
                                          quantity) {
                                    quantity++;
                                  }
                                });
                                _recalculatePrice();
                              }),
                              child: Image.asset(
                                Assets.imagesAddIcon,
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () async {
                                print(
                                    "${selectedWeight!.value}${selectedWeight!.measureType}");
                                print("$selectedSpecifications");
                                print(grandTotalSpecial);
                                try {
                                  double baseRegularPrice =
                                      getBaseRegularPrice();
                                  double baseSpecialPrice =
                                      getBaseSpecialPrice();

                                  print(
                                      "Base Regular Price: $baseRegularPrice");
                                  print(
                                      "Base Special Price: $baseSpecialPrice");
                                  print(
                                      "total regular Price: $grandTotalRegular");
                                  print(
                                      "total speical price: $grandTotalSpecial");
                                  context.loaderOverlay.show();
                                  Map<String, dynamic> response = {};
                                  response = await cartViewModel.addToCart(CartItem(
                                      product: widget.product,
                                      sellPrice:
                                          baseRegularPrice.toStringAsFixed(1),
                                      OfferPrice:
                                          baseSpecialPrice.toStringAsFixed(1),
                                      takenquantity: quantity.toString(),
                                      chosenWeight:
                                          "${selectedWeight!.value}${selectedWeight!.measureType}",
                                      specification: selectedSpecifications,
                                      productTotal: grandTotalSpecial !=
                                                  grandTotalRegular &&
                                              grandTotalSpecial != 0
                                          ? grandTotalSpecial.toStringAsFixed(1)
                                          : grandTotalRegular
                                              .toStringAsFixed(1),
                                      instructions: messageController.text,
                                      AvailableitemQuantity:
                                          int.parse(widget.product.quantity!)));
                                  context.loaderOverlay.hide();

                                  print("response is  $response");
                                  Get.back();
                                  showSnackBarWithMessage(response);
                                  Get.to(() => HomeScreen(
                                        initialIndex: 2,
                                      ));
                                } catch (e) {
                                  context.loaderOverlay.hide();
                                  showSnackBarWithMessage({
                                    "response": "failure",
                                    "message":
                                        "Something went wrong.Please try later"
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(15),
                                textStyle: GoogleFonts.firaSans(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                                shape: const StadiumBorder(),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Text(grandTotalSpecial !=
                                                  grandTotalRegular &&
                                              grandTotalSpecial != 0
                                          ? (widget.product.currency ?? "₹") +
                                              grandTotalSpecial
                                                  .toStringAsFixed(1)
                                          : (widget.product.currency ?? "₹") +
                                              grandTotalRegular
                                                  .toStringAsFixed(1)),
                                    ],
                                  ),
                                  const Text("Add Item"),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildWeightRadioList() {
    if (widget.product.availableWeightsWithPrice == null ||
        widget.product.availableWeightsWithPrice!.isEmpty) {
      return const SizedBox();
    }
    if (selectedWeight == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedWeight = widget.product.availableWeightsWithPrice!.first;
        });
        _onWeightChanged(
            "${selectedWeight!.value} ${selectedWeight!.measureType}");
      });
    }

    return Column(
      children: widget.product.availableWeightsWithPrice!.map((weight) {
        String weightText = "${weight.value} ${weight.measureType}";
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(weightText),
              ),
              weight.price != weight.specialPrice
                  ? Text(
                      "${widget.product.currency}${weight.price}",
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough),
                    )
                  : const SizedBox(),
              const SizedBox(
                width: 10,
              ),
              Text(
                "${widget.product.currency}${weight.price != weight.specialPrice ? weight.specialPrice : weight.price}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Radio<WeightWithPrice>(
                value: weight,
                groupValue: selectedWeight,
                onChanged: (WeightWithPrice? value) {
                  setState(() {
                    selectedWeight = value;
                  });
                  _onWeightChanged("${value!.value} ${value.measureType}");
                },
                activeColor: Get.theme.primaryColor,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _onWeightChanged(String? value) {
    if (value != null) {
      final selectedOption =
          widget.product.availableWeightsWithPrice!.firstWhere(
        (e) => "${e.value} ${e.measureType}" == value,
        orElse: () => WeightWithPrice(),
      );

      setState(() {
        selectedWeight = selectedOption;
      });
      _recalculatePrice();
    }
  }

  Widget buildSpecificationsRadioList() {
    if (widget.product.specifications == null ||
        widget.product.specifications!.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final specification = widget.product.specifications![index];
        return buildSpecificationRadioGroup(specification, index);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemCount: widget.product.specifications!.length,
    );
  }

  Widget buildSpecificationRadioGroup(Specification specification, int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            specification.specification!.capitalize ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...specification.options?.map((option) {
                final isSelected =
                    selectedSpecifications[specification.specification]
                            ?.contains(option.option!) ??
                        false;
                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(option.option ?? ""),
                      ),
                      Row(
                        children: [
                          Text("${widget.product.currency}${option.amount}"),
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) => _onSpecificationChanged(
                                specification, option, value),
                            activeColor: Get.theme.primaryColor,
                          ),
                          // Radio<String>(
                          //   value: option.option ?? "",
                          //   groupValue: selectedSpecifications[
                          //       specification.specification],
                          //   onChanged: isDisabled
                          //       ? null
                          //       : (value) => _onSpecificationChanged(
                          //           specification, value),
                          //   activeColor: Get.theme.primaryColor,
                          // ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [],
        ],
      ),
    );
  }

  void _onSpecificationChanged(
      Specification specification, Option option, bool? value) {
    setState(() {
      if (value == true) {
        // Set the single selection
        selectedSpecifications[specification.specification!] = option.option!;

        // Update the details
        selectedSpecificationDetails[specification.specification!] = {
          'id': option.id ?? '',
          'option': option.option ?? "",
          'amount': option.amount ?? '',
        };
      } else {
        // Remove the selection entirely
        selectedSpecifications.remove(specification.specification!);
        selectedSpecificationDetails.remove(specification.specification!);
      }
    });

    print("selected spec $selectedSpecifications");
    _recalculatePrice();
  }

  void _recalculatePrice() {
    double baseRegularPrice =
        double.tryParse(selectedWeight?.price ?? '0') ?? 0.0;
    double baseSpecialPrice =
        double.tryParse(selectedWeight?.specialPrice ?? '0') ??
            baseRegularPrice;
    double additionalAmount = 0.0;

    selectedSpecificationDetails.forEach((key, value) {
      additionalAmount += double.tryParse(value['amount'] ?? '0') ?? 0.0;
    });
    setState(() {
      if (baseSpecialPrice != baseRegularPrice && baseSpecialPrice != 0) {
        grandTotalSpecial = (baseSpecialPrice + additionalAmount) * quantity;
        grandTotalRegular = (baseRegularPrice + additionalAmount) * quantity;
      } else {
        grandTotalSpecial = (baseRegularPrice + additionalAmount) * quantity;
        grandTotalRegular = (baseRegularPrice + additionalAmount) * quantity;
      }
    });
  }

  double getBaseRegularPrice() {
    double baseRegularPrice =
        double.tryParse(selectedWeight?.price ?? '0') ?? 0.0;
    double additionalAmount = 0.0;

    selectedSpecificationDetails.forEach((key, value) {
      additionalAmount += double.tryParse(value['amount'] ?? '0') ?? 0.0;
    });

    return baseRegularPrice + additionalAmount;
  }

  double getBaseSpecialPrice() {
    double baseSpecialPrice =
        double.tryParse(selectedWeight?.specialPrice ?? '0') ??
            (double.tryParse(selectedWeight?.price ?? '0') ?? 0.0);
    double additionalAmount = 0.0;

    selectedSpecificationDetails.forEach((key, value) {
      additionalAmount += double.tryParse(value['amount'] ?? '0') ?? 0.0;
    });

    return baseSpecialPrice + additionalAmount;
  }
}

void showSnackBarWithMessage(Map<String, dynamic> response) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (response['response'].toString().toLowerCase() == "success") {
      // rootScaffoldMessengerKey.currentState?.showSnackBar(
      //   const SnackBar(
      //     duration: Duration(seconds: 2),
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.only(bottom: 100.0),
      //     content: Text("Successfully Added to Cart"),
      //     backgroundColor: Colors.green,
      //     // action: SnackBarAction(
      //     //   label: "View Cart",
      //     //   onPressed: () {
      //     //     Get.to(() => HomeScreen(initialIndex: 2));
      //     //   },
      //     // ),
      //   ),
      // );
      showNotificationSnackBar(
          "Successfully Added to Cart", NotificationStatus.success);
    } else {
      print("hi i am in else");
      showNotificationSnackBar(response['message'], NotificationStatus.warning);
      // rootScaffoldMessengerKey.currentState?.showSnackBar(
      //   SnackBar(
      //     content: Text(response['message']),
      //     backgroundColor: Colors.orange,
      //   ),
      // );
    }
  });
}
