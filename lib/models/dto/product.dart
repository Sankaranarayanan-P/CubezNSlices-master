// import 'dart:convert';
//
// import 'package:intl/intl.dart';
//
// class Product {
//   String? categories;
//   String? id;
//   String? imageUrl;
//   String? weight;
//   String? specialFromDate;
//   String? specialToDate;
//   String? currency;
//   String? productname;
//   String? quantity;
//   String? specialPrice;
//   String? offerPercentage;
//   final String? price;
//   String? description;
//   String? measurement;
//
//   Product(
//       {this.categories,
//       this.id,
//       this.imageUrl,
//       this.weight,
//       this.productname,
//       this.quantity = "0",
//       this.specialPrice,
//       this.price,
//       this.currency,
//       this.specialFromDate,
//       this.specialToDate,
//       this.offerPercentage,
//       this.description,
//       this.measurement});
//
//   // ---------------------------------------------------------------------------
//   // JSON
//   // ---------------------------------------------------------------------------
//   factory Product.fromRawJson(String str) => Product.fromMap(json.decode(str));
//
//   String toRawJson() => json.encode(toMap());
//
//   // ---------------------------------------------------------------------------
//   // Maps
//   // ---------------------------------------------------------------------------
//
//   factory Product.fromMap(Map<String, dynamic> json) {
//     var offerPercentage = _calculateOffer(
//         json['price'],
//         json['special_price'] ?? "0",
//         json['special_from_date'] ?? "0",
//         json['special_to_date'] ?? "0");
//
//     print("printing json from product class $json");
//     return Product(
//         // categories: json['categories'],
//         id: json['product_id'],
//         imageUrl: json['image_url'] ?? json['image'] ?? "",
//         weight: json['weight'],
//         productname: json['name'] ?? json['product_name'] ?? "",
//         quantity: json['quantity'],
//         specialPrice: json['special_price'],
//         price: json['price'] ?? "0",
//         currency: json['currency'] ?? "₹",
//         specialFromDate: json['special_from_date'],
//         specialToDate: json['special_to_date'],
//         offerPercentage: offerPercentage.toString(),
//         description: json['description'],
//         measurement: json['measurement']);
//   }
//
//   Map<String, dynamic> toMap() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     // data['categories'] = categories;
//     data['id'] = id;
//     data['imageUrl'] = imageUrl;
//     data['weight'] = weight;
//     data['productname'] = productname;
//     data['quantity'] = quantity;
//     data['specialPrice'] = specialPrice;
//     data['price'] = price;
//     data['offerPercentage'] = offerPercentage ?? 0;
//     data['specialFromDate'] = specialFromDate;
//     data['specialToDate'] = specialToDate;
//     data['currency'] = currency;
//     data['description'] = description;
//     data['measurement'] = measurement;
//     return data;
//   }
//
//   static double _calculateOffer(
//       String price, String specialprice, String startdate, String enddate) {
//     if (startdate == "0" || enddate == "0") {
//       return 0.0;
//     } else {
//       print(
//           "price is $price special price is $specialprice start date is $startdate end date is $enddate");
//       final double regularPrice = double.tryParse(price) ?? 0.0;
//       final double specialPrice = double.tryParse(specialprice) ?? 0.0;
//
//       // Parse the Unix timestamps
//       DateTime startDate;
//       DateTime endDate;
//       final DateTime currentDate = DateTime.now();
//       try {
//         startDate =
//             DateTime.fromMillisecondsSinceEpoch(int.parse(startdate) * 1000);
//         endDate =
//             DateTime.fromMillisecondsSinceEpoch(int.parse(enddate) * 1000);
//       } catch (e) {
//         final DateFormat inputFormat = DateFormat("MMM d, yyyy hh:mm:ss a");
//         startDate = inputFormat.parse(startdate);
//         endDate = inputFormat.parse(enddate);
//       }
//
//       // Format the dates to remove the time part
//       String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
//       String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
//       String formattedCurrentDate =
//           DateFormat('yyyy-MM-dd').format(currentDate);
//
//       print("Formatted start date: $formattedStartDate");
//       print("Formatted end date: $formattedEndDate");
//       print("Formatted current date: $formattedCurrentDate");
//
//       // Parse the formatted dates back to DateTime objects
//       final DateTime parsedStartDate = DateTime.parse(formattedStartDate);
//       final DateTime parsedEndDate = DateTime.parse(formattedEndDate);
//       final DateTime parsedCurrentDate = DateTime.parse(formattedCurrentDate);
//
//       if ((parsedCurrentDate.isAfter(parsedStartDate) ||
//               parsedCurrentDate.isAtSameMomentAs(parsedStartDate)) &&
//           (parsedCurrentDate.isBefore(parsedEndDate) ||
//               parsedCurrentDate.isAtSameMomentAs(parsedEndDate))) {
//         if (regularPrice <= 0 ||
//             specialPrice <= 0 ||
//             specialPrice >= regularPrice) {
//           return 0.0;
//         }
//         return ((regularPrice - specialPrice) / regularPrice) * 100;
//       } else {
//         return 0.0;
//       }
//     }
//   }
// }

import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';

class Product {
  String? id;

  // List<String>? categoryIds;
  String? productName;
  String? description;
  String? sku;
  String? imageUrl;
  String? visibility;
  String? supplierName;
  String? features;
  String? subcategory;
  String? taxSgst;
  String? taxCgst;
  String? taxIgst;
  List<dynamic>? additionalTax;
  String? price;
  String? specialPrice;
  String? quantity;
  String? measurement;
  String? specialFromDate;
  String? specialToDate;
  String? outOfStock;
  String? status;
  String? createdAt;
  String? updatedAt;

  // bool? isFeatured;
  String? metaTitle;
  String? metaKeyword;
  String? metaDescription;
  String? weight;
  String? slug;

  // String? productSpecificationId;
  List<Specification>? specifications;
  List<String>? availableWeights;
  List<WeightWithPrice>? availableWeightsWithPrice;
  String? currency;
  String? offerPercentage;
  List<dynamic>? specialities;

  Product({
    this.id,
    // this.categoryIds,
    this.productName,
    this.description,
    this.sku,
    this.imageUrl,
    this.visibility,
    this.supplierName,
    this.features,
    this.subcategory,
    this.taxSgst,
    this.taxCgst,
    this.taxIgst,
    this.additionalTax,
    this.specialities,
    this.price,
    this.specialPrice,
    this.quantity,
    this.measurement,
    this.specialFromDate,
    this.specialToDate,
    this.outOfStock,
    this.status,
    this.createdAt,
    this.updatedAt,
    // this.isFeatured,
    this.metaTitle,
    this.metaKeyword,
    this.metaDescription,
    this.weight,
    this.slug,
    // this.productSpecificationId,
    this.specifications,
    this.availableWeights,
    this.currency,
    this.offerPercentage,
    this.availableWeightsWithPrice,
  });

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------
  factory Product.fromRawJson(String str) => Product.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  // ---------------------------------------------------------------------------
  // Maps
  // ---------------------------------------------------------------------------

  factory Product.fromMap(Map<String, dynamic> json) {
    var offerPercentage = _calculateOffer(
      json['price'] as String? ?? "",
      json['special_price'] as String? ?? "0",
      json['special_from_date'] as String? ?? "0",
      json['special_to_date'] as String? ?? "0",
    );

    Map<String, String> newPrice = {};

    if (json['available_weights_with_price'] != null &&
        json['available_weights_with_price'] != "null") {
      newPrice = updatePrice(
          json['available_weights_with_price'] as String,
          json['currency'] ?? "",
          json['specifications'] != null
              ? (json['specifications'] as List)
                  .map((e) => Specification.fromMap(e as Map<String, dynamic>))
                  .toList()
              : []);
    }

    return Product(
      id: json['product_id'] as String? ?? "",
      productName: json['name'] as String? ?? "",
      description: json['description'] as String? ?? "",
      sku: json['sku'] as String? ?? "",
      imageUrl: json['image_url'] as String? ?? "",
      visibility: json['visibility'] as String? ?? "",
      supplierName: json['supplier_name'] as String? ?? "",
      features: json['features'] as String? ?? "",
      subcategory: json['subcategory'] as String? ?? "",
      taxSgst: json['tax_sgst'] as String? ?? "",
      taxCgst: json['tax_cgst'] as String? ?? "",
      taxIgst: json['tax_igst'] as String? ?? "",
      additionalTax: json['additional_tax'] != null
          ? jsonDecode(json['additional_tax'] as String)
          : [],
      price: newPrice["regularPrice"]!.isNotEmpty
          ? newPrice["regularPrice"]!
          : (json['price'] as String? ?? ""),
      specialPrice: newPrice["specialPrice"]!.isNotEmpty
          ? newPrice["specialPrice"]!
          : (json['special_price'] as String? ?? ""),
      quantity: json['quantity'] as String? ?? "0",
      measurement: json['measurement'] as String? ?? "",
      specialFromDate: json['special_from_date'] as String? ?? "",
      specialToDate: json['special_to_date'] as String? ?? "",
      outOfStock: json['out_of_stock'] as String? ?? "",
      status: json['status'] as String? ?? "",
      createdAt: json['created_at'] as String? ?? "",
      updatedAt: json['updated_at'] as String? ?? "",
      metaTitle: json['meta_title'] as String? ?? "",
      metaKeyword: json['meta_keyword'] as String? ?? "",
      metaDescription: json['meta_description'] as String? ?? "",
      weight: json['weight'] as String? ?? "",
      slug: json['slug'] as String? ?? "",
      specifications: json['specifications'] != null
          ? (json['specifications'] as List)
              .map((e) => Specification.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      availableWeights: json['availableWeights'] != null
          ? List<String>.from(json['availableWeights'] as List)
          : [],
      currency: json['currency'] as String? ?? "",
      offerPercentage: offerPercentage.toString(),
      availableWeightsWithPrice: json['available_weights_with_price'] != null &&
              json['available_weights_with_price'] != "null"
          ? (jsonDecode(json['available_weights_with_price'] as String) as List)
              .map((e) => WeightWithPrice.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      specialities: json['speciality_details'] != null
          ? json['speciality_details'] as List<dynamic>
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    // data['categoryIds'] = jsonEncode(categoryIds);
    data['name'] = productName;
    data['description'] = description ?? "";
    data['sku'] = sku;
    data['imageUrl'] = imageUrl;
    data['visibility'] = visibility;
    data['supplierName'] = supplierName;
    data['features'] = features;
    data['subcategory'] = subcategory;
    data['taxSgst'] = taxSgst;
    data['taxCgst'] = taxCgst;
    data['taxIgst'] = taxIgst;
    data['additionalTax'] = jsonEncode(additionalTax);
    data['speciality_details'] = specialities;
    data['price'] = price;
    data['specialPrice'] = specialPrice;
    data['quantity'] = quantity;
    data['measurement'] = measurement;
    data['specialFromDate'] = specialFromDate;
    data['specialToDate'] = specialToDate;
    data['outOfStock'] = outOfStock;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    // data['isFeatured'] = isFeatured ? "1" : "0";
    data['metaTitle'] = metaTitle;
    data['metaKeyword'] = metaKeyword;
    data['metaDescription'] = metaDescription;
    data['weight'] = weight;
    data['slug'] = slug;
    // data['productSpecificationId'] = productSpecificationId;
    data['specifications'] = specifications?.map((e) => e.toMap()).toList();
    data['availableWeights'] = availableWeights;
    data['currency'] = currency;
    data['offerPercentage'] = offerPercentage;
    data['available_weights_with_price'] = availableWeightsWithPrice != null
        ? jsonEncode(availableWeightsWithPrice!.map((e) => e.toJson()).toList())
        : null;
    return data;
  }

  static double _calculateOffer(
      String price, String specialprice, String startdate, String enddate) {
    print("${specialprice}sidasda");
    print(specialprice);
    // Convert input prices to double with default values
    final double regularPrice = double.tryParse(price) ?? 0.0;
    final double specialPrice =
        double.tryParse(specialprice == "0" ? price : specialprice) ??
            regularPrice;

    // Check for valid date ranges
    DateTime startDate;
    DateTime endDate;
    final DateTime currentDate = DateTime.now();

    try {
      // Attempt to parse dates from epoch time (assuming input is in seconds)
      startDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(startdate) * 1000);
      endDate = DateTime.fromMillisecondsSinceEpoch(int.parse(enddate) * 1000);
    } catch (e) {
      // If parsing fails, try parsing date strings in a readable format
      try {
        final DateFormat inputFormat = DateFormat("MMM d, yyyy hh:mm:ss a");
        startDate = inputFormat.parse(startdate);
        endDate = inputFormat.parse(enddate);
      } catch (e) {
        // Handle invalid date format
        print("Date parsing error: $e");
        return 0.0;
      }
    }

    // Ensure valid price values
    if (regularPrice <= 0 ||
        specialPrice <= 0 ||
        specialPrice >= regularPrice) {
      return 0.0;
    }

    // Compare current date with start and end dates
    if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
      return ((regularPrice - specialPrice) / regularPrice) * 100;
    } else {
      return 0.0;
    }
  }

  // static String updatePrice(String availableWeightWithPrice) {
  //   try {
  //     print("entering inside updatePrice");
  //     List<dynamic> availableWeightWithPriceList =
  //         jsonDecode(availableWeightWithPrice);
  //     if (availableWeightWithPriceList.isEmpty) {
  //       return "";
  //     } else {
  //       List<WeightWithPrice> prices = availableWeightWithPriceList
  //           .map((e) => WeightWithPrice.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //       String startingPrice = "0";
  //       String finalPrice = "0";
  //       if ((double.tryParse(prices.first.specialPrice ?? "0") ?? 0) <
  //           (double.tryParse(prices.first.price ?? "0") ?? 0)) {
  //         startingPrice = prices.first.specialPrice ?? "0";
  //       } else {
  //         startingPrice = prices.first.price ?? "0";
  //       }
  //       if ((double.tryParse(prices.last.specialPrice ?? "0") ?? 0) <
  //           (double.tryParse(prices.last.price ?? "0") ?? 0)) {
  //         finalPrice = prices.last.specialPrice ?? "0";
  //       } else {
  //         finalPrice = prices.last.price ?? "0";
  //       }
  //       return "$startingPrice - $finalPrice";
  //     }
  //   } catch (e) {
  //     print("Error parsing available weights with price: $e");
  //     return "";
  //   }
  // }
  static Map<String, String> updatePrice(String availableWeightWithPrice,
      String currency, List<Specification> specification) {
    try {
      print("entering inside updatePrice");
      List<dynamic> availableWeightWithPriceList =
          jsonDecode(availableWeightWithPrice);
      if (availableWeightWithPriceList.isEmpty) {
        return {"regularPrice": "", "specialPrice": ""};
      } else {
        List<WeightWithPrice> prices = availableWeightWithPriceList
            .map((e) => WeightWithPrice.fromJson(e as Map<String, dynamic>))
            .toList();

        double minRegularPrice = double.infinity;
        double maxRegularPrice = 0;
        double minSpecialPrice = double.infinity;
        double maxSpecialPrice = 0;

        for (var price in prices) {
          double regularPrice = double.tryParse(price.price ?? "0") ?? 0;
          double specialPrice = double.tryParse(price.specialPrice ?? "0") ?? 0;

          minRegularPrice = min(minRegularPrice, regularPrice);
          maxRegularPrice = max(maxRegularPrice, regularPrice);

          if (specialPrice > 0) {
            minSpecialPrice = min(minSpecialPrice, specialPrice);
            maxSpecialPrice = max(maxSpecialPrice, specialPrice);
          }
        }

        for (var spec in specification) {
          for (var option in spec.options ?? []) {
            double amount = double.tryParse(option.amount ?? "0") ?? 0;
            maxRegularPrice += amount;
            maxSpecialPrice += amount;
          }
        }

        String regularPriceRange = minRegularPrice == maxRegularPrice
            ? "$currency${minRegularPrice.round()}"
            : "$currency${minRegularPrice.round()} - $currency${maxRegularPrice.round()}";

        String specialPriceRange = minSpecialPrice == double.infinity
            ? ""
            : (minSpecialPrice == maxSpecialPrice
                ? "$currency${minSpecialPrice.round()}"
                : "$currency${minSpecialPrice.round()} - $currency${maxSpecialPrice.round()}");

        return {
          "regularPrice": regularPriceRange,
          "specialPrice": specialPriceRange
        };
      }
    } catch (e) {
      print("Error parsing available weights with price: $e");
      return {"regularPrice": "", "specialPrice": ""};
    }
  }
}

class Specification {
  String? specification;
  List<Option>? options;

  Specification({this.specification, this.options});

  factory Specification.fromMap(Map<String, dynamic> json) {
    return Specification(
      specification: json['specification'],
      options: (json['options'] as List).map((e) => Option.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['specification'] = specification;
    data['options'] = options?.map((e) => e.toMap()).toList();
    return data;
  }
}

class Option {
  String? id;
  String? option;
  String? amount;

  Option({this.id, this.option, this.amount});

  factory Option.fromMap(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      option: json['option'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['option'] = option;
    data['amount'] = amount;
    return data;
  }
}

class WeightWithPrice {
  String? price;
  String? value;
  String? measureType;
  String? specialPrice;

  WeightWithPrice(
      {this.price, this.value, this.measureType, this.specialPrice});

  factory WeightWithPrice.fromJson(Map<String, dynamic> json) {
    return WeightWithPrice(
      price: json['price'],
      value: json['value'],
      measureType: json['measure_type'],
      specialPrice: json['special_price'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['value'] = value;
    data['measure_type'] = measureType;
    data['special_price'] = specialPrice;
    return data;
  }
}
