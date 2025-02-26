// import 'dart:convert';
//
// import 'package:cubes_n_slice/models/dto/product.dart';
//
// class CartItem extends Product {
//   int itemQuantity;
//   String? specialPrice;
//   String? sellPrice;
//   CartItem(
//       {
//       //   required String? id,
//       // required String? image,
//       // required String? productname,
//       // required String? quantity,
//       // required String? price,
//       // // required String? categories,
//       // required this.itemQuantity,
//       // required String? offerPercentage,
//       // required String? specialPrice
//       required Product product,
//       required this.itemQuantity,
//       this.specialPrice,
//       this.sellPrice})
//       : super(
//             id: product.id,
//             imageUrl: product.imageUrl,
//             productname: product.productname,
//             quantity: product.quantity,
//             price: product.price,
//             offerPercentage: product.offerPercentage,
//             specialPrice: product.specialPrice,
//             weight: product.weight,
//             description: product.description,
//             specialFromDate: product.specialFromDate,
//             specialToDate: product.specialToDate,
//             currency: product.currency
//             // categories: categories
//             );
//
//   // ---------------------------------------------------------------------------
//   // JSON
//   // ---------------------------------------------------------------------------
//
//   factory CartItem.fromRawJson(String str) =>
//       CartItem.fromMap(json.decode(str));
//
//   @override
//   String toRawJson() => json.encode(toMap());
//
//   // ---------------------------------------------------------------------------
//   // Maps
//   // ---------------------------------------------------------------------------
//
//   factory CartItem.fromMap(Map<String, dynamic> json) {
//     print(json);
//     return CartItem(
//         product: Product.fromMap(json),
//         itemQuantity: int.parse(json['quantity']),
//         specialPrice: json['sell_price'],
//         sellPrice: json['']
//         // categories: json['categories'],
//         );
//   }
//   @override
//   Map<String, dynamic> toMap() {
//     final Map<String, dynamic> data = super.toMap();
//     data['itemQuantity'] = itemQuantity;
//     return data;
//   }
// }
import 'dart:convert';

import 'package:cubes_n_slice/models/dto/product.dart';

class CartData {
  final List<CartItem> cart;
  final String grandTotal;
  final String discount;
  final String deliveryCharge;
  final String grandQuantity;
  final String cartCount;
  final String outOfStock;
  final String baseAmount;

  CartData(
      {required this.cart,
      required this.grandTotal,
      required this.discount,
      required this.deliveryCharge,
      required this.grandQuantity,
      required this.cartCount,
      required this.outOfStock,
      required this.baseAmount});

  factory CartData.fromMap(Map<String, dynamic> map) {
    return CartData(
        cart: List<CartItem>.from(
            map['cart']?.map((x) => CartItem.fromMap(x)) ?? []),
        grandTotal: map['cartCount'].toString() == "0"
            ? "₹0"
            : map['grandTotal'].toString(),
        discount: map['discount'].toString(),
        deliveryCharge: map['deliveryCharge'].toString(),
        grandQuantity: map['grandQuantity'].toString(),
        cartCount: map['cartCount'].toString(),
        outOfStock: map['out_of_stock'].toString(),
        baseAmount: map['baseAmount']);
  }

  Map<String, dynamic> toMap() {
    return {
      'cart': cart.map((x) => x.toMap()).toList(),
      'grandTotal': grandTotal,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'grandQuantity': grandQuantity,
      'cartCount': cartCount,
      'out_of_stock': outOfStock,
      'baseAmount': baseAmount
    };
  }
}

class CartItem extends Product {
  int AvailableitemQuantity;
  String? specialPrice;
  String? sellPrice;
  String? OfferPrice;
  String? productoutofstock;
  String? takenquantity;
  String? coupon;
  String? chosenWeight;
  Map<dynamic, dynamic>? specification;
  String? productTotal;
  String? currency;
  String? instructions;

  CartItem(
      {required Product product,
      required this.AvailableitemQuantity,
      this.specialPrice,
      this.sellPrice,
      this.productoutofstock,
      this.takenquantity,
      this.coupon,
      this.OfferPrice,
      this.chosenWeight,
      this.specification,
      this.currency,
      this.instructions,
      this.productTotal})
      : super(
          id: product.id,
          imageUrl: product.imageUrl,
          productName: product.productName,
          quantity: product.quantity,
          offerPercentage: product.offerPercentage,
          weight: product.weight,
          description: product.description,
          specialFromDate: product.specialFromDate,
          specialToDate: product.specialToDate,
          currency: currency,
        );

  factory CartItem.fromRawJson(String str) =>
      CartItem.fromMap(json.decode(str));

  @override
  String toRawJson() => json.encode(toMap());

  factory CartItem.fromMap(Map<String, dynamic> json) {
    print("json");
    print(json);
    return CartItem(
        product: Product.fromMap(json['product']),
        AvailableitemQuantity: int.tryParse(json['itemQuantity']) ?? 0,
        specialPrice: json['sell_price'],
        sellPrice: json['sell_price'],
        OfferPrice: json['offer_price'],
        takenquantity: json['quantity'],
        productoutofstock: json['out_of_stock'],
        coupon: json['coupon'] ?? "",
        specification: jsonDecode(json['specifications'] ?? ""),
        chosenWeight: json['takenWeight'],
        productTotal: json['total_price'],
        instructions: json['instructions'],
        currency: json['currency']);
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['itemQuantity'] = AvailableitemQuantity;
    data['specialPrice'] = specialPrice;
    data['sellPrice'] = sellPrice;
    data['productoutofstock'] = productoutofstock;
    data['takenquantity'] = takenquantity;
    data['coupon'] = coupon;
    data['specification'] = specification;
    data['chosenWeight'] = chosenWeight;
    data['currency'] = currency;
    data['productTotal'] = productTotal;
    data['instructions'] = instructions;
    data['OfferPrice'] = OfferPrice;
    return data;
  }

  @override
  String toString() {
    return toRawJson().toString();
  }
}

class Coupon {
  final String couponId;
  final String couponName;
  final DateTime couponFrom;
  final DateTime couponTo;
  final String couponType;
  final String couponTypeValue;
  final String couponStatus;
  final String discountType;
  final double discountAmount;
  final double discountPercentage;
  final double minimumAmount;
  final double maximumAmount;
  final DateTime couponFromDateTime;
  final DateTime couponToDateTime;

  Coupon({
    required this.couponId,
    required this.couponName,
    required this.couponFrom,
    required this.couponTo,
    required this.couponType,
    required this.couponTypeValue,
    required this.couponStatus,
    required this.discountType,
    required this.discountAmount,
    required this.discountPercentage,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.couponFromDateTime,
    required this.couponToDateTime,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final int couponFromEpoch = int.parse(json['coupon_from'] as String);
    final int couponToEpoch = int.parse(json['coupon_to'] as String);

    return Coupon(
      couponId: json['coupon_id'] as String,
      couponName: json['coupon_name'] as String,
      couponFrom: DateTime.fromMillisecondsSinceEpoch(couponFromEpoch),
      couponTo: DateTime.fromMillisecondsSinceEpoch(couponToEpoch),
      couponType: json['coupon_type'] as String,
      couponTypeValue: json['coupon_type_value'] ?? 'null',
      couponStatus: json['coupon_status'] as String,
      discountType: json['discount_type'] as String,
      discountAmount: double.tryParse(json['discount_amount'] as String) ?? 0.0,
      discountPercentage:
          double.tryParse(json['discount_percentage'] as String) ?? 0.0,
      minimumAmount: double.tryParse(json['minimum_amount'] as String) ?? 0.0,
      maximumAmount: double.tryParse(json['maximum_amount'] as String) ?? 0.0,
      couponFromDateTime: DateTime.fromMillisecondsSinceEpoch(couponFromEpoch),
      couponToDateTime: DateTime.fromMillisecondsSinceEpoch(couponToEpoch),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'coupon_name': couponName,
      'coupon_from': couponFrom.millisecondsSinceEpoch.toString(),
      'coupon_to': couponTo.millisecondsSinceEpoch.toString(),
      'coupon_type': couponType,
      'coupon_type_value': couponTypeValue,
      'coupon_status': couponStatus,
      'discount_type': discountType,
      'discount_amount': discountAmount.toStringAsFixed(2),
      'discount_percentage': discountPercentage.toStringAsFixed(2),
      'minimum_amount': minimumAmount.toStringAsFixed(2),
      'maximum_amount': maximumAmount.toStringAsFixed(2),
      'coupon_from_date_time': couponFromDateTime.toIso8601String(),
      'coupon_to_date_time': couponToDateTime.toIso8601String(),
    };
  }
}
