import 'dart:convert';

class User {
  String? phoneNumber;
  String? firstName;
  String? middleName;
  String? lastName;
  String? emailAddress;
  String? gender;
  String? salutation;
  User(
      {this.phoneNumber,
      this.firstName,
      this.emailAddress,
      this.gender,
      this.lastName,
      this.middleName});

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------
  factory User.fromRawJson(String str) => User.fromMap(json.decode(str));

  String toRawJson() => json.encode(toMap());

  // ---------------------------------------------------------------------------
  // Maps
  // ---------------------------------------------------------------------------

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      phoneNumber: json['contact_number'],
      firstName: json['name'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};
    data['contact_number'] = phoneNumber;
    data['name'] = firstName;
    return data;
  }
}

class Address {
  String addressId;
  String customerId;
  String firstName;
  String lastName;
  String contactNumber;
  String email;
  String streetAddress;
  String landmark;
  String city;
  String state;
  String country;
  String postalCode;
  String defaultBilling;
  String defaultShipping;
  String status;

  Address({
    required this.addressId,
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.contactNumber,
    required this.email,
    required this.streetAddress,
    required this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.defaultBilling,
    required this.defaultShipping,
    required this.status,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      addressId: map['address_id'] ?? '',
      customerId: map['customer_id'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      contactNumber: map['contact_number'] ?? '',
      email: map['email'] ?? '',
      streetAddress: map['street_address'] ?? '',
      landmark: map['landmark'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postal_code'] ?? '',
      defaultBilling: map['default_billing'] ?? '',
      defaultShipping: map['default_shipping'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address_id': addressId,
      'customer_id': customerId,
      'first_name': firstName,
      'last_name': lastName,
      'contact_number': contactNumber,
      'email': email,
      'street_address': streetAddress,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'default_billing': defaultBilling,
      'default_shipping': defaultShipping,
      'status': status,
    };
  }
  @override
  String toString() {
    return '''
  Address {
    addressId: $addressId,
    customerId: $customerId,
    firstName: $firstName,
    lastName: $lastName,
    contactNumber: $contactNumber,
    email: $email,
    streetAddress: $streetAddress,
    landmark: $landmark,
    city: $city,
    state: $state,
    country: $country,
    postalCode: $postalCode,
    defaultBilling: $defaultBilling,
    defaultShipping: $defaultShipping,
    status: $status
  }
  ''';
  }
}
