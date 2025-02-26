import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/views/common_widgets/Search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../constants/assets.dart';
import '../domain/cartViewModel.dart';
import '../domain/productViewModel.dart';
import '../models/dto/cart.dart';
import '../models/dto/product.dart';
import 'common_widgets/CartIcon.dart';
import 'common_widgets/ProductCustomizationWidget.dart';
import 'common_widgets/appBar.dart';
import 'common_widgets/item_key_points_view.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int itemCount = 0;
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
  final ProductViewModel productViewModel = Get.find<ProductViewModel>();
  Product product = Get.arguments;
  late final List<CachedNetworkImageProvider> multiImageProvider;
  Map<String, String> selectedSpecifications = {};
  Map<String, Map<String, String>> selectedSpecificationDetails = {};
  RegExp numextractregex = RegExp(r'\d+(\.\d+)?');
  // String? selectedWeighDropdown;
  late final String originalPrice;
  late final String originalSpecialPrice;
  int choosenquantity = 1;
  WeightWithPrice? selectedWeight;
  double grandTotal = 0;
  double regularPrice = 0;
  @override
  void initState() {
    super.initState();
    () async {
      print(Get.parameters['from_page']);
      // if (Get.parameters['from_page'] != null) {
      context.loaderOverlay.show();
      product =
          (await productViewModel.getProductById(int.tryParse(product.id!)!)) ??
              Get.arguments;
      originalPrice = product.price ?? '0';
      originalSpecialPrice = product.specialPrice ?? '0.00';
      final cartItem = cartViewModel.productCartMap[product.id.toString()];
      if (cartItem != null && cartItem.id == product.id) {
        grandTotal = (double.tryParse(cartItem.sellPrice!) ?? 0) *
            (double.tryParse(cartItem.takenquantity!) ?? 0);
        selectedWeight = product.availableWeightsWithPrice?.firstWhere(
            (e) => "${e.value} ${e.measureType}" == cartItem.chosenWeight,
            orElse: () => WeightWithPrice());
        print("daf ${cartItem.specification!['cleaning']}");

        selectedSpecificationDetails = Map.fromEntries(
          cartItem.specification!.entries.map((entry) {
            selectedSpecifications[entry.key] = entry.value;
            final specification = product.specifications?.firstWhere(
              (spec) => spec.specification == entry.key,
              orElse: () => Specification(),
            );

            if (specification == null) {
              print('No specification found for ${entry.key}');
              return MapEntry(entry.key, {
                'id': '',
                'option': '',
                'amount': '',
              });
            }

            final selectedOption = specification.options?.firstWhere(
              (option) =>
                  option.option?.trim().toLowerCase() ==
                  entry.value?.trim().toLowerCase(),
              orElse: () => Option(),
            );

            if (selectedOption == null) {
              print(
                  'No option found for ${entry.value} in specification ${entry.key}');
            }

            return MapEntry(
              entry.key,
              {
                'id': selectedOption?.id ?? '',
                'option': selectedOption?.option.toString().toLowerCase() ?? '',
                'amount': selectedOption?.amount ?? '',
              },
            );
          }),
        );

        // Optionally: Print out the values to debug
        selectedSpecifications.forEach((key, value) {
          print("Specification: $key, Value: $value");
        });
        selectedSpecificationDetails.forEach((key, details) {
          print("Specification: $key, Details: $details");
        });
      }
      setState(() {});
      context.loaderOverlay.hide();
      // }
    }();
    multiImageProvider = [
      CachedNetworkImageProvider(product.imageUrl ?? ''),
      CachedNetworkImageProvider(product.imageUrl ?? ''),
    ];
  }

  @override
  dispose() {
    super.dispose();
  }

  double currentRegularPrice = 0;
  double currentSpecialPrice = 0;
  void _updateGrandTotal(
      double regularPrice,
      double specialPrice,
      WeightWithPrice? selectWeight,
      Map<String, String> selectSpecification,
      int takenQuantity) {
    setState(() {
      grandTotal = specialPrice;
      currentRegularPrice = regularPrice;
      currentSpecialPrice = specialPrice;
      selectedWeight = selectWeight;
      selectedSpecifications = selectSpecification;
      choosenquantity = takenQuantity;
    });
    print(grandTotal);
  }

  bool hasCartItem = false;
  @override
  Widget build(BuildContext context) {
    Widget productDescription = Html(
      data: product.description ?? "",
    );
    final cartItem = cartViewModel.productCartMap[product.id.toString()];
    if (cartItem != null && cartItem.id == product.id) {
      hasCartItem = true;
    } else {
      hasCartItem = false;
    }
    print(product.specialities);
    return Scaffold(
      appBar: MyAppBar(
          title: const SearchOverlay(),
          leading: InkResponse(
              onTap: () => Get.back(), child: const BackButtonIcon()),
          actions: <Widget>[CartIcon()]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
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
                              maxScale: PhotoViewComputedScale.covered * 1.1,
                              minScale: PhotoViewComputedScale.contained * 0.8,
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.elliptical(
                                  MediaQuery.of(context).size.width, 140.0))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Hero(
                          tag: product.id!,
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl ?? '',
                            width: 140,
                            height: 180,
                            filterQuality: FilterQuality.high,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              product.offerPercentage != "0" &&
                                      product.specialPrice != "0.00" &&
                                      product.specialPrice != null &&
                                      product.specialPrice != ""
                                  ? (product.currency ?? "") +
                                      product.specialPrice!
                                  : (product.currency ?? "") + product.price!,
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
                          ],
                        ),
                        const SizedBox(
                          height: 14,
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
                        Text(
                          "Quantity Available : ${product.quantity}",
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        // product.availableWeightsWithPrice != null &&
                        //         product.availableWeightsWithPrice!.isNotEmpty
                        //     ? DropdownFieldComponent(
                        //         disableDropdown:
                        //             hasCartItem || selectedWeight != null,
                        //         key: Key(
                        //             'dropdown_${selectedWeight?.value ?? 'initial'}_${selectedWeight?.measureType ?? 'initial'}'),
                        //         needOptionInModal: true,
                        //         items: product.availableWeightsWithPrice
                        //                 ?.map((e) =>
                        //                     "${e.value} ${e.measureType}")
                        //                 .toList() ??
                        //             [],
                        //         labelText: "Choose a Weight",
                        //         hintText: "Choose a Weight",
                        //         value: selectedWeight != null
                        //             ? "${selectedWeight!.value} ${selectedWeight!.measureType}"
                        //             : null,
                        //         onChanged: (String? value) {
                        //           if (value != null) {
                        //             final selectedOption = product
                        //                 .availableWeightsWithPrice!
                        //                 .firstWhere(
                        //               (e) =>
                        //                   "${e.value} ${e.measureType}" ==
                        //                   value,
                        //               orElse: () => WeightWithPrice(),
                        //             );
                        //             print(selectedOption.value);
                        //             // if (double.parse(selectedOption.price!) <
                        //             //     double.parse(
                        //             //         selectedOption.specialPrice!)) {
                        //             //   grandTotal = double.tryParse(
                        //             //           selectedOption.price ?? "") ??
                        //             //       0;
                        //             // } else {
                        //             //   grandTotal = double.tryParse(
                        //             //           selectedOption.specialPrice ??
                        //             //               "") ??
                        //             //       0;
                        //             // }
                        //             // 0;
                        //             setState(() {
                        //               selectedWeight = selectedOption;
                        //             });
                        //           }
                        //         },
                        //       )
                        //     : const SizedBox(),
                        // const SizedBox(height: 14),
                        // product.specifications != null &&
                        //         product.specifications!.isNotEmpty
                        //     ? ListView.separated(
                        //         shrinkWrap: true,
                        //         itemBuilder: (BuildContext context, int index) {
                        //           final specification =
                        //               product.specifications![index];
                        //           final isDisabled = selectedWeight == null ||
                        //               (index > 0 &&
                        //                   (selectedSpecifications[product
                        //                               .specifications![
                        //                                   index - 1]
                        //                               .specification] ==
                        //                           null ||
                        //                       selectedSpecifications[product
                        //                               .specifications![
                        //                                   index - 1]
                        //                               .specification]!
                        //                           .isEmpty));
                        //           // Check if the current specification has already been selected
                        //           final specificationSelected =
                        //               selectedSpecifications[
                        //                       specification.specification] !=
                        //                   null;
                        //
                        //           // Disable dropdown if no weight is selected or if the current specification is already selected
                        //           final isSelected = selectedWeight == null ||
                        //               specificationSelected;
                        //           return DropdownFieldComponent(
                        //             disableDropdown:
                        //                 hasCartItem || isDisabled || isSelected,
                        //             key: ValueKey(selectedSpecifications[
                        //                 specification.specification]),
                        //             needOptionInModal: true,
                        //             items: specification.options
                        //                     ?.map((e) => e.option ?? "")
                        //                     .toList() ??
                        //                 [],
                        //             labelText:
                        //                 "${specification.specification!.capitalize}",
                        //             hintText:
                        //                 "Choose ${specification.specification!.capitalize}",
                        //             value: selectedSpecifications[
                        //                 specification.specification],
                        //             onChanged: (String? value) {
                        //               if (value != null) {
                        //                 final selectedOption =
                        //                     specification.options?.firstWhere(
                        //                   (option) => option.option == value,
                        //                   orElse: () => Option(),
                        //                 );
                        //                 print("${value}value ");
                        //                 print(selectedSpecificationDetails[
                        //                         specification.specification!]
                        //                     ?['option']);
                        //                 if (value !=
                        //                     selectedSpecificationDetails[
                        //                             specification
                        //                                 .specification!]
                        //                         ?['option']) {
                        //                   setState(() {
                        //                     selectedSpecifications[specification
                        //                         .specification!] = value;
                        //                     selectedSpecificationDetails[
                        //                         specification
                        //                             .specification!] = {
                        //                       'id': selectedOption?.id ?? '',
                        //                       'option':
                        //                           selectedOption?.option ?? "",
                        //                       'amount':
                        //                           selectedOption?.amount ?? '',
                        //                     };
                        //                     // double basePrice = double.tryParse(
                        //                     //         product.price ?? '0') ??
                        //                     //     0.0;
                        //                     // double baseSpecialPrice =
                        //                     //     double.tryParse(
                        //                     //             product.specialPrice ??
                        //                     //                 '0') ??
                        //                     //         0.0;
                        //
                        //                     double additionalAmount = 0.0;
                        //                     selectedSpecificationDetails
                        //                         .forEach((key, value) {
                        //                       additionalAmount +=
                        //                           double.tryParse(
                        //                                   value['amount'] ??
                        //                                       '0') ??
                        //                               0.0;
                        //                     });
                        //                     //
                        //                     // grandTotal =
                        //                     //     grandTotal + additionalAmount;
                        //                     // product.specialPrice =
                        //                     //     (baseSpecialPrice +
                        //                     //             additionalAmount)
                        //                     //         .toString();
                        //                   });
                        //                   _checkIfAllSelected();
                        //                 }
                        //                 // You can use the selected option details here
                        //                 print(
                        //                     'Selected ${specification.specification}: $value');
                        //                 print(
                        //                     'Option ID: ${selectedOption?.id}');
                        //                 print(
                        //                     'Option Amount: ${selectedOption?.amount}');
                        //               }
                        //             },
                        //           );
                        //         },
                        //         separatorBuilder:
                        //             (BuildContext context, int index) {
                        //           return const SizedBox(height: 14);
                        //         },
                        //         itemCount: product.specifications!.length)
                        //     : const SizedBox(),
                        // const SizedBox(height: 14),
                        // !hasCartItem &&
                        //         (selectedWeight != null ||
                        //             selectedSpecificationDetails.isNotEmpty)
                        //     ? Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           grandTotal != 0
                        //               ? Row(
                        //                   children: [
                        //                     Text(grandTotal.toString()),
                        //                     grandTotal == regularPrice
                        //                         ? const SizedBox()
                        //                         : Text(
                        //                             regularPrice.toString(),
                        //                             style: const TextStyle(
                        //                                 decoration:
                        //                                     TextDecoration
                        //                                         .lineThrough),
                        //                           ),
                        //                   ],
                        //                 )
                        //               : const SizedBox(),
                        //           TextButton(
                        //               onPressed: () {
                        //                 print(grandTotal == regularPrice);
                        //                 setState(() {
                        //                   selectedWeight = null;
                        //                   selectedSpecificationDetails.clear();
                        //                   selectedSpecifications.clear();
                        //                   grandTotal = 0;
                        //                   choosenquantity = 1;
                        //                 });
                        //               },
                        //               child: Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.center,
                        //                 children: [
                        //                   const Icon(Icons.close),
                        //                   Text(
                        //                     "Clear",
                        //                     style: GoogleFonts.firaSans(
                        //                         color: Colors.black,
                        //                         fontSize: 16),
                        //                   ),
                        //                 ],
                        //               )),
                        //         ],
                        //       )
                        //     : const SizedBox(),
                        ProductCustomizationWidget(
                          product: product,
                          onPricesChanged: _updateGrandTotal,
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
                                    borderRadius: BorderRadius.circular(20)),
                                // height:
                                //     MediaQuery.of(context).size.height * 0.4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            imagePath: AppConstants.siteUrl +
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
                                        itemCount: product.specialities!.length,
                                        itemBuilder: (context, index) {
                                          final speciality =
                                              product.specialities![index];
                                          return ItemKeyPointsView(
                                            imagePath: AppConstants.siteUrl +
                                                speciality['thumbnail'],
                                            title:
                                                speciality['speciality_name'] ??
                                                    '',
                                            desc:
                                                speciality['description'] ?? '',
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
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Get.theme.cardColor.withOpacity(0.6),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  product.quantity != "0"
                      ? Row(
                          children: [
                            grandTotal != 0.0
                                ? Column(
                                    children: [
                                      const Text("Total price (with tax)",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              "${product.currency!} $grandTotal",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text("x ${choosenquantity.toInt()}")
                                        ],
                                      )
                                    ],
                                  )
                                : const SizedBox(
                                    width: 100,
                                  ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 1,
                              child: Obx(
                                () {
                                  final cartItem = cartViewModel
                                      .productCartMap[product.id.toString()];
                                  if (cartItem != null &&
                                      cartItem.id == product.id) {
                                    return _buildCartActions(cartItem);
                                  } else {
                                    return _buildCartNoActions();
                                  }
                                },
                              ),
                            )
                          ],
                        )
                      : const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Out of Stock",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ],
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartNoActions() {
    return ElevatedButton(
      onPressed: () async {
        print(selectedWeight);
        print(selectedSpecifications);
        if (grandTotal > 0) {
          print("id is ${product.id}");
          try {
            context.loaderOverlay.show();
            await cartViewModel.addToCart(CartItem(
                product: product,
                takenquantity: choosenquantity.toString(),
                chosenWeight:
                    "${selectedWeight!.value} ${selectedWeight!.measureType}",
                specification: selectedSpecifications,
                productTotal: grandTotal.toString(),
                sellPrice: grandTotal.toString(),
                AvailableitemQuantity: int.parse(product.quantity!)));
            setState(() {
              selectedWeight = null;
              selectedSpecificationDetails.clear();
              selectedSpecifications.clear();
            });
          } catch (e) {
            print("Error happended in detail page while adding to cart $e");
            showNotificationSnackBar("Something went wrong.Please try again..",
                NotificationStatus.failure);
          } finally {
            context.loaderOverlay.hide();
          }
        } else {
          Get.defaultDialog(
              title: "Warning",
              titleStyle: GoogleFonts.firaSans(color: Colors.white),
              backgroundColor: Get.theme.primaryColor,
              content: const Text(
                "Please Choose all product Specification you need",
                style: TextStyle(color: Colors.white),
              ),
              textConfirm: "OK",
              barrierDismissible: false,
              confirm: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("Ok"),
              ));
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        backgroundColor: Get.theme.primaryColor,
      ),
      child: const Text(
        "Add to cart",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCartActions(CartItem cartItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
          onTap: () async {
            print(cartItem.specification);
            log(cartViewModel.productCartMap.toString());
            print("displaying cartitems");
            log(cartItem.toString());
            await cartViewModel.addToCart(CartItem(
                product: Product(
                  id: product.id,
                  imageUrl: product.imageUrl,
                  productName: product.productName,
                  quantity: product.quantity,
                  price: product.price,
                  offerPercentage: product.offerPercentage,
                  specialPrice: product.specialPrice,
                  weight: product.weight,
                  description: product.description,
                  specialFromDate: product.specialFromDate,
                  specialToDate: product.specialToDate,
                  currency: cartItem.currency,
                ),
                takenquantity: cartItem.takenquantity,
                chosenWeight: cartItem.chosenWeight,
                specification: cartItem.specification,
                sellPrice: cartItem.sellPrice,
                productTotal: cartItem.productTotal ?? grandTotal.toString(),
                AvailableitemQuantity: int.parse(product.quantity!)));
          },
          child: Image.asset(
            Assets.imagesAddIcon,
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          (cartItem.takenquantity).toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 20),
        InkResponse(
          onTap: () async {
            await cartViewModel.removeFromCart(cartItem);
            if (cartViewModel.cartCount.value == 0) {
              setState(() {
                grandTotal = 0.0;
              });
            }
          },
          child: Image.asset(
            Assets.imagesRemoveIcon,
            width: 40,
            height: 40,
          ),
        ),
      ],
    );
  }
}
