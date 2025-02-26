// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loader_overlay/loader_overlay.dart';
//
// import '../../constants/assets.dart';
// import '../../domain/cartViewModel.dart';
// import '../../models/dto/cart.dart';
// import '../../models/dto/product.dart';
//
// class CartItemWidget extends StatelessWidget {
//   final CartItem item;
//   final bool isOrderSummary;
//
//   CartItemWidget({Key? key, required this.item, this.isOrderSummary = false})
//       : super(key: key);
//
//   final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
//
//   @override
//   Widget build(BuildContext context) {
//     print("detail fish ${item.AvailableitemQuantity} ${item.quantity}");
//     final bool isOutOfStock = item.productoutofstock == "YES" ? true : false;
//     print(item.imageUrl);
//     print(item.specification);
//     return InkWell(
//       onTap: isOutOfStock
//           ? null
//           : isOrderSummary
//               ? null
//               : () async => {
//                     Get.toNamed('/details',
//                         arguments: item, parameters: {'from_page': "cart"})
//                   },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//                 child: Container(
//               height: 60,
//               width: 60,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isOutOfStock
//                       ? Colors.grey[300]
//                       : const Color(0xffffffff)),
//               child: Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(50),
//                     color: Colors.white),
//                 child: CachedNetworkImage(
//                   imageUrl: item.imageUrl!,
//                   fit: BoxFit.cover,
//                   width: 40,
//                   height: 40,
//                   filterQuality: FilterQuality.high,
//                   //fit: BoxFit.cover,
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 ),
//               ),
//             )),
//             const SizedBox(
//               width: 8,
//             ),
//             Expanded(
//               flex: 3,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.productName ?? "????",
//                     style: TextStyle(
//                       overflow: TextOverflow.ellipsis,
//                       fontSize: 14,
//                       fontWeight: FontWeight.normal,
//                       color: isOutOfStock ? Colors.grey : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Row(
//                     children: [
//                       !isOrderSummary
//                           ? const SizedBox()
//                           : Text("${item.takenquantity} X ",
//                               style: const TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.bold)),
//                       if (item.OfferPrice != null &&
//                           item.OfferPrice != "0" &&
//                           item.OfferPrice != item.sellPrice)
//                         Text(
//                           item.currency! + item.sellPrice!,
//                           style: const TextStyle(
//                             color: Colors.grey,
//                             fontSize: 16,
//                             fontWeight: FontWeight.normal,
//                             decoration: TextDecoration.lineThrough,
//                           ),
//                         ),
//                       if (item.OfferPrice != null &&
//                           item.OfferPrice != "0" &&
//                           item.OfferPrice != item.sellPrice)
//                         const SizedBox(width: 5),
//                       Text(
//                         item.currency! +
//                             (item.OfferPrice != null && item.OfferPrice != "0"
//                                 ? item.OfferPrice!
//                                 : item.sellPrice!),
//                         style: const TextStyle(
//                           color: Color(0xffFF324B), // Red for special price
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text("Weight - ${item.chosenWeight}"),
//                   item.specification!.isNotEmpty
//                       ? Column(
//                           children: item.specification!.entries.map((entry) {
//                             return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 4.0),
//                                 child: Row(
//                                   children: [
//                                     Text(entry.key.toString().capitalize ?? ""),
//                                     const SizedBox(
//                                       width: 5,
//                                     ),
//                                     const Text("-"),
//                                     const SizedBox(
//                                       width: 5,
//                                     ),
//                                     Text(entry.value)
//                                   ],
//                                 ));
//                           }).toList(),
//                         )
//                       : const SizedBox(),
//                   if (item.instructions != null &&
//                       item.instructions!.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Instructions: ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Expanded(
//                             child: Text(
//                               "\"${item.instructions ?? ''}\"",
//                               textAlign: TextAlign.start,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   isOrderSummary
//                       ? const SizedBox()
//                       : Text(
//                           isOutOfStock ? "Out of stock" : "",
//                           style: TextStyle(
//                             color: isOutOfStock ? Colors.red : Colors.black,
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//             isOrderSummary
//                 ? const SizedBox()
//                 : SizedBox(
//                     height: 120,
//                     child: isOutOfStock
//                         ? IconButton(
//                             onPressed: () {
//                               cartViewModel.removeFromCart(item,
//                                   removeAll: true);
//                             },
//                             color: Colors.red,
//                             icon: const Icon(Icons.delete_outline),
//                           )
//                         : Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                     color: const Color(0xffE9F5FA),
//                                     borderRadius: BorderRadius.circular(24)),
//                                 child: Row(
//                                   children: [
//                                     InkWell(
//                                       onTap: (() async {
//                                         // log(item.toRawJson());
//                                         // print(item.specification);
//                                         context.loaderOverlay.show();
//                                         await cartViewModel.addToCart(CartItem(
//                                             product: Product(
//                                               id: item.id,
//                                               imageUrl: item.imageUrl,
//                                               productName: item.productName,
//                                               quantity: item.quantity,
//                                               price: item.price,
//                                               offerPercentage:
//                                                   item.offerPercentage,
//                                               specialPrice: item.specialPrice,
//                                               weight: item.weight,
//                                               description: item.description,
//                                               specialFromDate:
//                                                   item.specialFromDate,
//                                               specialToDate: item.specialToDate,
//                                               currency: item.currency,
//                                             ),
//                                             sellPrice: item.sellPrice,
//                                             specialPrice: item.specialPrice,
//                                             takenquantity:
//                                                 (int.parse(item.takenquantity!) + 1)
//                                                     .toString(),
//                                             chosenWeight: item.chosenWeight,
//                                             specification: item.specification,
//                                             productTotal: (item.specialPrice !=
//                                                         null &&
//                                                     item.specialPrice != "0")
//                                                 ? (double.parse(item.specialPrice!) *
//                                                         (int.parse(item.takenquantity!) +
//                                                             1))
//                                                     .toStringAsFixed(2)
//                                                 : (double.parse(item.sellPrice!) *
//                                                         (int.parse(item
//                                                                 .takenquantity!) +
//                                                             1))
//                                                     .toStringAsFixed(2),
//                                             AvailableitemQuantity:
//                                                 int.parse(item.quantity!)));
//                                         context.loaderOverlay.hide();
//                                       }),
//                                       child: Image.asset(
//                                         Assets.imagesAddIcon,
//                                         width: 28,
//                                         height: 28,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 8,
//                                     ),
//                                     Text(
//                                       item.takenquantity.toString(),
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                         //color: Colors.black
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 8,
//                                     ),
//                                     InkWell(
//                                       onTap: () async {
//                                         context.loaderOverlay.show();
//                                         await cartViewModel.removeFromCart(
//                                             CartItem(
//                                                 product: Product(
//                                                   id: item.id,
//                                                   imageUrl: item.imageUrl,
//                                                   productName: item.productName,
//                                                   quantity: item.quantity,
//                                                   price: item.price,
//                                                   offerPercentage:
//                                                       item.offerPercentage,
//                                                   specialPrice:
//                                                       item.specialPrice,
//                                                   weight: item.weight,
//                                                   description: item.description,
//                                                   specialFromDate:
//                                                       item.specialFromDate,
//                                                   specialToDate:
//                                                       item.specialToDate,
//                                                   currency: item.currency,
//                                                 ),
//                                                 takenquantity:
//                                                     item.takenquantity,
//                                                 chosenWeight: item.chosenWeight,
//                                                 specification:
//                                                     item.specification,
//                                                 productTotal: item.productTotal,
//                                                 AvailableitemQuantity:
//                                                     int.parse(item.quantity!)));
//                                         context.loaderOverlay.hide();
//                                       },
//                                       child: Image.asset(
//                                         Assets.imagesRemoveIcon,
//                                         width: 28,
//                                         height: 28,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.greenAccent.shade400,
//                                       Colors.green.shade700
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black26,
//                                       blurRadius: 8,
//                                       offset: Offset(2, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     const Icon(Icons.shopping_cart,
//                                         color: Colors.white, size: 24),
//                                     // Shopping icon
//                                     const SizedBox(width: 8),
//                                     // Space between icon and text
//                                     Text(
//                                       "Total: ",
//                                       style: GoogleFonts.lato(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     Text(
//                                       "${item.currency}${item.productTotal}",
//                                       style: GoogleFonts.lato(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize:
//                                             20, // Larger and bold text for price
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Spacer(),
//                               IconButton(
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         title: Text("Confirm Removal",
//                                             style: GoogleFonts.firaSans()),
//                                         content: const Text(
//                                             "Do you want to remove from cart?"),
//                                         actions: <Widget>[
//                                           TextButton(
//                                             child: const Text("No"),
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                           ),
//                                           TextButton(
//                                             child: const Text(
//                                               "Yes",
//                                               style:
//                                                   TextStyle(color: Colors.red),
//                                             ),
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                               cartViewModel.removeFromCart(item,
//                                                   removeAll: true);
//                                             },
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                                 color: Colors.red,
//                                 icon: const Row(
//                                   children: [
//                                     Icon(Icons.delete_outline),
//                                     Text("Remove")
//                                   ],
//                                 ),
//                               )
//                             ],
//                           )),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../domain/cartViewModel.dart';
import '../../models/dto/cart.dart';
import '../../models/dto/product.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final bool isOrderSummary;

  CartItemWidget({Key? key, required this.item, this.isOrderSummary = false})
      : super(key: key);
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = item.productoutofstock == "YES" ? true : false;
    print("item speci ${item.specification}");
    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : isOrderSummary
              ? null
              : () async => {
                    Get.toNamed('/details',
                        arguments: item, parameters: {'from_page': "cart"})
                  },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        item.productName ?? AppConstants.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Base Price and Offer Price
                      Row(
                        children: [
                          if (item.OfferPrice != null &&
                              item.OfferPrice != "0" &&
                              item.OfferPrice != item.sellPrice)
                            Text(
                              "${item.currency}${item.sellPrice}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (item.OfferPrice != null &&
                              item.OfferPrice != "0" &&
                              item.OfferPrice != item.sellPrice)
                            const SizedBox(width: 8),
                          Text(
                            "${item.currency}${item.OfferPrice}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Weight Information
                      Text(
                        "Weight: ${item.chosenWeight}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      item.specification!.isNotEmpty
                          ? Column(
                              children:
                                  item.specification!.entries.map((entry) {
                                print("entry is " + entry.value);
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Text(entry.key.toString().capitalize ??
                                            ""),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text("-"),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(entry.value)
                                      ],
                                    ));
                              }).toList(),
                            )
                          : const SizedBox(),
                      if (item.instructions != null &&
                          item.instructions!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Instructions: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  "\"${item.instructions ?? ''}\"",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Quantity Selector and Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Selector
                isOutOfStock
                    ? const Text(
                        "Out of Stock",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    : isOrderSummary
                        ? Text("Quantity: ${item.takenquantity}")
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    context.loaderOverlay.show();
                                    await cartViewModel.removeFromCart(CartItem(
                                        product: Product(
                                          id: item.id,
                                          imageUrl: item.imageUrl,
                                          productName: item.productName,
                                          quantity: item.quantity,
                                          price: item.price,
                                          offerPercentage: item.offerPercentage,
                                          specialPrice: item.specialPrice,
                                          weight: item.weight,
                                          description: item.description,
                                          specialFromDate: item.specialFromDate,
                                          specialToDate: item.specialToDate,
                                          currency: item.currency,
                                        ),
                                        takenquantity: item.takenquantity,
                                        chosenWeight: item.chosenWeight,
                                        specification: item.specification,
                                        productTotal: item.productTotal,
                                        AvailableitemQuantity:
                                            int.parse(item.quantity!)));
                                    context.loaderOverlay.hide();
                                  },
                                  icon: const Icon(Icons.remove,
                                      color: Colors.green),
                                ),
                                Text(
                                  item.takenquantity ?? "1",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    // context.loaderOverlay.show();
                                    print("Item ID: ${item.id}");
                                    print("Item takenquantity: ${item.takenquantity}");
                                    print("Item quantity: ${item.quantity}");
                                    print("Item sellPrice: ${item.sellPrice}");
                                    print("Item OfferPrice: ${item.OfferPrice}");
                                    await cartViewModel.addToCart(CartItem(
                                        product: Product(
                                          id: item.id,
                                          imageUrl: item.imageUrl,
                                          productName: item.productName,
                                          quantity: item.quantity,
                                          price: item.price,
                                          offerPercentage: item.offerPercentage,
                                          specialPrice: item.specialPrice,
                                          weight: item.weight,
                                          description: item.description,
                                          specialFromDate: item.specialFromDate,
                                          specialToDate: item.specialToDate,
                                          currency: item.currency,
                                        ),
                                        sellPrice: item.sellPrice,
                                        OfferPrice: item.OfferPrice,
                                        takenquantity:
                                            (int.parse(item.takenquantity!) + 1)
                                                .toString(),
                                        chosenWeight: item.chosenWeight,
                                        specification: item.specification,
                                        productTotal: (item.OfferPrice != null &&
                                                item.OfferPrice != "0" &&
                                                item.OfferPrice !=
                                                    item.sellPrice)
                                            ? (double.parse(item.OfferPrice!) *
                                                    (int.parse(item.takenquantity!) +
                                                        1))
                                                .toStringAsFixed(2)
                                            : (double.parse(item.sellPrice!) *
                                                    (int.parse(item
                                                            .takenquantity!) +
                                                        1))
                                                .toStringAsFixed(2),
                                        AvailableitemQuantity:
                                            int.parse(item.quantity!)));
                                    context.loaderOverlay.hide();
                                  },
                                  icon: const Icon(Icons.add,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                // Total Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total: ${item.currency}${item.productTotal}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Remove Button
                    isOrderSummary
                        ? SizedBox()
                        : TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Confirm Removal",
                                        style: GoogleFonts.firaSans()),
                                    content: Text(
                                      "Do you want to remove from cart?",
                                      style: GoogleFonts.firaSans(),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          "No",
                                          style: GoogleFonts.firaSans(),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          "Yes",
                                          style: GoogleFonts.firaSans(
                                              color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          cartViewModel.removeFromCart(item,
                                              removeAll: true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            label: Text(
                              "Remove",
                              style: GoogleFonts.firaSans(color: Colors.red),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
