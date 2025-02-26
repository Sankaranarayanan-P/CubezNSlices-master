import 'dart:convert';

import 'package:cubes_n_slice/models/dto/User.dart';

class Order {
  String? orderId;
  String? customerId;
  String? customerName;
  String? contactNumber;
  String? dateOfPurchase;
  String? amount;
  String? currency;
  String? shippingAddress;
  String? billingAddress;
  String? deliveryDate;
  String? cancelRequestStatus;
  String? cancelRequestNote;
  String? cancelRequestDate;
  String? orderStatus;
  String? paymentStatus;
  String? deliveryStatus;
  String? deliveryCharge;
  String? orderEntryDate;
  String? updatedOn;
  String? pdfPath;
  String? prescriptionPath;
  List<OrderItem>? items;
  Payment? payment;
  String? trackingUrl;
  String? cancelRequest;
  String? discount;
  String? cancelNote;
  String? cancelDate;
  String? coupon;
  String? deliveryTip;
  String? platformFee;
  Address? deliveryAddress;
  String? baseAmount;
  String? estimatedDate;
  String? estimatedTime;

  Order(
      {this.orderId,
      this.customerId,
      this.customerName,
      this.contactNumber,
      this.dateOfPurchase,
      this.amount,
      this.currency,
      this.shippingAddress,
      this.billingAddress,
      this.deliveryDate,
      this.cancelRequestStatus,
      this.cancelRequestNote,
      this.cancelRequestDate,
      this.orderStatus,
      this.paymentStatus,
      this.deliveryStatus,
      this.deliveryCharge,
      this.orderEntryDate,
      this.updatedOn,
      this.pdfPath,
      this.prescriptionPath,
      this.items,
      this.payment,
      this.trackingUrl,
      this.cancelRequest,
      this.discount,
      this.cancelNote,
      this.cancelDate,
      this.coupon,
      this.deliveryAddress,
      this.deliveryTip,
      this.platformFee,
      this.baseAmount,
      this.estimatedDate,
      this.estimatedTime});

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
        orderId: map['order_id'],
        customerId: map['customer_id'],
        customerName: map['customer_name'],
        contactNumber: map['contact_number'],
        dateOfPurchase: map['date_of_purchase'],
        amount: map['amount'],
        currency: map['currency'],
        shippingAddress: map['shipping_address'],
        billingAddress: map['billing_address'],
        deliveryDate: map['delivery_date'],
        cancelRequestStatus: map['cancel_request_status'],
        cancelRequestNote: map['cancel_request_note'],
        cancelRequestDate: map['cancel_request_date'],
        orderStatus: map['order_status'],
        paymentStatus: map['payment_status'],
        deliveryStatus: map['delivery_status'],
        deliveryCharge: map['delivery_charge'],
        orderEntryDate: map['order_entry_date'],
        updatedOn: map['updated_on'],
        pdfPath: map['pdf_path'],
        prescriptionPath: map['prescription_path'],
        items:
            List<OrderItem>.from(map['items'].map((x) => OrderItem.fromMap(x))),
        payment: Payment.fromMap(map['payment']),
        trackingUrl: map['tracking_url'],
        cancelRequest: map['cancel_request'],
        discount: map['discount'],
        cancelNote: map['cancel_note'],
        cancelDate: map['cancel_date'],
        coupon: map['coupon'],
        platformFee: map['platform_fee'],
        deliveryTip: map['delivery_tip'],
        deliveryAddress: Address.fromMap(jsonDecode(map['shipping_address'])),
        baseAmount: map['baseAmount'],
        estimatedDate: map['estimated_delivery'],
        estimatedTime: map['estimated_delivery_time']);
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'customer_name': customerName,
      'contact_number': contactNumber,
      'date_of_purchase': dateOfPurchase,
      'amount': amount,
      'currency': currency,
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'delivery_date': deliveryDate,
      'cancel_request_status': cancelRequestStatus,
      'cancel_request_note': cancelRequestNote,
      'cancel_request_date': cancelRequestDate,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'delivery_status': deliveryStatus,
      'delivery_charge': deliveryCharge,
      'order_entry_date': orderEntryDate,
      'updated_on': updatedOn,
      'pdf_path': pdfPath,
      'prescription_path': prescriptionPath,
      'items': items!.map((x) => x.toMap()).toList(),
      'payment': payment!.toMap(),
      'tracking_url': trackingUrl,
      'cancel_request': cancelRequest,
      'discount': discount,
      'cancel_note': cancelNote,
      'cancel_date': cancelDate,
      'coupon': coupon,
      'platformFee': platformFee,
      "deliveryTip": deliveryTip,
      "deliveryAddress": deliveryAddress,
      "baseAmount": baseAmount,
      "estimatedDate": estimatedTime,
      "estimatedTime": estimatedTime
    };
  }
}

class OrderItem {
  String? orderDetailsId;
  String? productId;
  String? productName;
  String? image;
  int? orderQuantity;
  double? orderPrice;
  String? orderId;
  double? taxIgst;
  double? taxSgst;
  double? taxCgst;
  List<dynamic>? additionalTax;
  String? trackingId;
  int? orderDetailsEntryDate;
  String? name;

  OrderItem({
    this.orderDetailsId,
    this.productId,
    this.productName,
    this.image,
    this.orderQuantity,
    this.orderPrice,
    this.orderId,
    this.taxIgst,
    this.taxSgst,
    this.taxCgst,
    this.additionalTax,
    this.trackingId,
    this.orderDetailsEntryDate,
    this.name,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderDetailsId: map['order_details_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      image: map['image'],
      orderQuantity: int.parse(map['order_quantity']),
      orderPrice: double.parse(map['order_price']),
      orderId: map['order_id'],
      taxIgst: double.parse(map['tax_igst']),
      taxSgst: double.parse(map['tax_sgst']),
      taxCgst: double.parse(map['tax_cgst']),
      additionalTax: json.decode(map['additional_tax']),
      trackingId: map['tracking_id'],
      orderDetailsEntryDate: int.parse(map['order_details_entry_date']),
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_details_id': orderDetailsId,
      'product_id': productId,
      'product_name': productName,
      'image': image,
      'order_quantity': orderQuantity.toString(),
      'order_price': orderPrice.toString(),
      'order_id': orderId,
      'tax_igst': taxIgst.toString(),
      'tax_sgst': taxSgst.toString(),
      'tax_cgst': taxCgst.toString(),
      'additional_tax': json.encode(additionalTax),
      'tracking_id': trackingId,
      'order_details_entry_date': orderDetailsEntryDate.toString(),
      'name': name,
    };
  }
}

class Payment {
  String? paymentId;
  String? orderId;
  String? customerId;
  String? transactionId;
  String? extOrderId;
  String? modeOfPayment;
  String? currency;
  String? razorpayPaymentId;
  double? paymentAmount;
  String? paymentStatus;
  int? paymentEntryDate;
  String? note;

  Payment({
    this.paymentId,
    this.orderId,
    this.customerId,
    this.transactionId,
    this.extOrderId,
    this.modeOfPayment,
    this.currency,
    this.razorpayPaymentId,
    this.paymentAmount,
    this.paymentStatus,
    this.paymentEntryDate,
    this.note,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      paymentId: map['payment_id'],
      orderId: map['order_id'],
      customerId: map['customer_id'],
      transactionId: map['transaction_id'],
      extOrderId: map['ext_order_id'],
      modeOfPayment: map['mode_of_payment'],
      currency: map['currency'],
      razorpayPaymentId: map['razorpay_payment_id'],
      paymentAmount: double.parse(map['payment_amount']),
      paymentStatus: map['payment_status'],
      paymentEntryDate: int.parse(map['payment_entry_date']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'customer_id': customerId,
      'transaction_id': transactionId,
      'ext_order_id': extOrderId,
      'mode_of_payment': modeOfPayment,
      'currency': currency,
      'razorpay_payment_id': razorpayPaymentId,
      'payment_amount': paymentAmount.toString(),
      'payment_status': paymentStatus,
      'payment_entry_date': paymentEntryDate.toString(),
      'note': note,
    };
  }
}
