import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../constants/assets.dart';
import '../../domain/cartViewModel.dart';
import '../../models/dto/cart.dart';
import '../../models/dto/product.dart';
import '../../utils/SnackBarNotification.dart';

class VegetableCardWidget extends StatelessWidget {
  final Product product;
  BuildContext currentcontext;

  VegetableCardWidget(
      {super.key, required this.product, required this.currentcontext});

  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();

  @override
  Widget build(BuildContext context) {
    return Material(
      //color: Get.theme.cardColor,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width / 2) - 34,
        // height: cardWidth,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/details', arguments: product),
                  child: Hero(
                    tag: product.id!,
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl ?? "",
                      // width: 120,
                      // height: 120,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.low,
                      errorWidget: (context, url, error) =>
                          Image.asset(Assets.noImage),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.specialPrice != product.price)
                        Text(
                          product.price!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough),
                        ),
                      Text(
                        product.specialPrice!,
                        style: const TextStyle(
                          color: Color(0xffFF324B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   "/${product.measurement ?? ""}",
                      //   style: const TextStyle(
                      //       fontSize: 10, fontWeight: FontWeight.bold),
                      // )
                    ],
                  ),
                ),
                // product.offerPercentage != "0" &&
                //         product.specialPrice != "0.00" &&
                //         product.specialPrice != null &&
                //         product.specialPrice != ""
                //     ? Row(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: [
                //           // Text(
                //           //   product.currency! + product.price!,
                //           //   style: TextStyle(
                //           //       decoration: TextDecoration.lineThrough,
                //           //       color: Get.theme.colorScheme.primary,
                //           //       fontSize: 10,
                //           //       fontWeight: FontWeight.bold),
                //           // ),
                //           const SizedBox(
                //             width: 8,
                //           ),
                //           product.offerPercentage! == "0.0"
                //               ? const SizedBox()
                //               : Text(
                //                   "${double.parse(product.offerPercentage!).toStringAsFixed(1)}%",
                //                   style: const TextStyle(
                //                       color: Color.fromARGB(255, 27, 133, 185),
                //                       fontSize: 10,
                //                       fontWeight: FontWeight.bold),
                //                 ),
                //         ],
                //       )
                //     : SizedBox(),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    product.productName.toString().capitalize ?? "????",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 48,
          //   right: 0,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Obx(
          //       () {
          //         final cartItem =
          //             cartViewModel.productCartMap[product.id.toString()];
          //         return cartItem != null && cartItem.id == product.id
          //             ? _buildCartActions(cartItem)
          //             : _buildCartNoActions();
          //       },
          //     ),
          //   ),
          // ),
          product.offerPercentage! == "0.0"
              ? const SizedBox()
              : Positioned(
                  top: 0, // to shift little up
                  left: 0,
                  child: Container(
                      width: 40,
                      height: 40,
                      //color: Colors.amber.shade100,
                      decoration: const BoxDecoration(
                          color: Color(0xffE9F5FA),
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(8))),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                              "${double.parse(product.offerPercentage!).toStringAsFixed(1)}%",
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.primaryColor)),
                          Text("OFF",
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.primaryColor))
                        ],
                      )),
                )
        ]),
      ),
    );
  }

  Widget _buildCartActions(CartItem cartItem) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
          color: const Color(0xffE9F5FA),
          borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          InkResponse(
            onTap: () async {
              try {
                currentcontext.loaderOverlay.show();
                await cartViewModel.addToCart(cartItem);
              } catch (e) {
                print("Error happended in detail page while adding to cart $e");
                showNotificationSnackBar(
                    "Something went wrong.Please try again..",
                    NotificationStatus.failure);
              } finally {
                currentcontext.loaderOverlay.hide();
              }
            },
            child: Image.asset(
              Assets.imagesAddIcon,
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            (cartItem.takenquantity).toString(),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(width: 8),
          InkResponse(
            onTap: () {
              cartViewModel.removeFromCart(cartItem);
            },
            child: Image.asset(
              Assets.imagesRemoveIcon,
              width: 28,
              height: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartNoActions() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkResponse(
        onTap: () async {
          try {
            currentcontext.loaderOverlay.show();
            cartViewModel.addToCart(CartItem(
                product: product,
                takenquantity: "1",
                AvailableitemQuantity: int.parse(product.quantity!)));
          } catch (e) {
            print("Error happended in detail page while adding to cart $e");
            showNotificationSnackBar("Something went wrong.Please try again..",
                NotificationStatus.failure);
          } finally {
            currentcontext.loaderOverlay.hide();
          }
        },
        child: Image.asset(
          Assets.imagesAddIcon,
          width: 28,
          height: 28,
        ),
      ),
    );
  }
}
