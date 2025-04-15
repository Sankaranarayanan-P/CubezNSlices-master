// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/utils/SnackBarNotification.dart';
import 'package:cubes_n_slice/views/address_page.dart';
import 'package:cubes_n_slice/views/cart.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:cubes_n_slice/views/common_widgets/TextFormFieldComponent.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:cubes_n_slice/views/home.dart';
import 'package:dio/dio.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../domain/profileView.dart';
import 'deliveryLocations.dart';

class AddAddress extends StatefulWidget {
  final Address? address;
  final bool hasAddress;
  final bool fromCart;
  final TextEditingController? postalCodeController;
  final String? firstName;
  final String? lastName;
  final String? contactNumber;
  final String? emailAddress;
  final String? streetAddress;
  final String? landMark;
  // final String? postalCodeController;
  const AddAddress(
      {super.key,
      this.address,
      this.hasAddress = false,
      this.fromCart = false,
      this.firstName,
      this.lastName,
      this.contactNumber,
      this.emailAddress,
      this.streetAddress,
      this.landMark,
      this.postalCodeController});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  late String pageFrom;

  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  // TextEditingController firstName = TextEditingController();
  // TextEditingController lastName = TextEditingController();
  // TextEditingController contactNumber = TextEditingController();
  // TextEditingController emailAddress = TextEditingController();
  // TextEditingController streetAddress = TextEditingController();
  // TextEditingController landMark = TextEditingController();

  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController contactNumber;
  late TextEditingController emailAddress;
  late TextEditingController streetAddress;
  late TextEditingController landMark;

  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  // TextEditingController postalCode = TextEditingController();

  bool isDefaultShipping = false;
  bool isDefaultBilling = false;
  final _formKey = GlobalKey<FormState>();

  bool isPinCodeValid = false;

  Future<void> checkPinCode(String pinCode) async {
    print("Inside check function++++++++++++++++++++++++++++");
    print(pinCode);

    final dio = Dio();

    try {
      final response = await dio.post(
        "${AppConstants.BASE_URL}${AppConstants.checkPincodeValidity}",
        data: {'pinCode': pinCode}, // Send as form data
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          }, // Form data header
        ),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data['data']; // Access the 'data' key
        if (data['isValid'] == true) {
          setState(() {
            isPinCodeValid = true;
            print("VALID PINCODE!!!!!!!!!!!!!");
          });
        } else {
          setState(() {
            isPinCodeValid = false;
            print("INVALID PINCODE!!!!!!!!!!!!!");
          });
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(''),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sorry, Delivery location is invalid!'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Navigate to DeliveryLocationsPage
                      Get.to(() => const DeliverylocationsPage(), arguments: {
                        'firstName': firstName.text,
                        'lastName': lastName.text,
                        'contactNumber': contactNumber.text,
                        'emailAddress': emailAddress.text,
                        'streetAddress': streetAddress.text,
                        'landMark': landMark.text,
                        'pageFrom': Get.arguments?['pageFrom'] == 'addresspage'
                            ? 'addresspage'
                            : 'cartpage'
                      });
                    },
                    child: const Text(
                      'Available Delivery Locations',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          isPinCodeValid = false;
        });
        print("Error: ${response.statusCode}");
        // Show error dialog for status code error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            // title: Row(
            //   children: [
            //     Icon(Icons.error_outline, color: Colors.red, size: 30),
            //     const SizedBox(width: 10),
            //     Text(
            //       'Invalid Location',
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.red,
            //       ),
            //     ),
            //   ],
            // ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sorry, the selected delivery location is invalid.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Navigate to DeliveryLocationsPage
                    Get.to(() => const DeliverylocationsPage(), arguments: {
                      'firstName': firstName.text,
                      'lastName': lastName.text,
                      'contactNumber': contactNumber.text,
                      'emailAddress': emailAddress.text,
                      'streetAddress': streetAddress.text,
                      'landMark': landMark.text,
                      'pageFrom': Get.arguments?['pageFrom'] == 'addresspage'
                          ? 'addresspage'
                          : 'cartpage'
                    });
                  },
                  child: const Text(
                    'View Available Delivery Locations',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isPinCodeValid = false;
      });
      print("Error: $e");
      // Show error dialog for exception
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // title: Row(
          //   children: [
          //     Icon(Icons.error_outline, color: Colors.red, size: 30),
          //     const SizedBox(width: 10),
          //     Text(
          //       'Invalid Location',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.red,
          //       ),
          //     ),
          //   ],
          // ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sorry, the selected delivery location is invalid.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigate to DeliveryLocationsPage
                  Get.to(() => const DeliverylocationsPage(), arguments: {
                    'firstName': firstName.text,
                    'lastName': lastName.text,
                    'contactNumber': contactNumber.text,
                    'emailAddress': emailAddress.text,
                    'streetAddress': streetAddress.text,
                    'landMark': landMark.text,
                    'pageFrom': Get.arguments?['pageFrom'] == 'addresspage'
                        ? 'addresspage'
                        : 'cartpage'
                  });
                },
                child: const Text(
                  'View Available Delivery Locations',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showNotificationSnackBar(
            "Location permissions are denied", NotificationStatus.failure);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showNotificationSnackBar(
          "Location permissions are permanently denied, we cannot request permissions.",
          NotificationStatus.failure);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    streetAddress.text =
        '${place.street},${place.subLocality},${place.locality}';
    city.text = '${place.locality}';
    state.text = '${place.administrativeArea}';
    country.text = '${place.country}';
    postalCode.text = '${place.postalCode}';
    // return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
  }

  void _getAddress() async {
    try {
      context.loaderOverlay.show();
      Position position = await _determinePosition();
      await _getAddressFromLatLng(position);
      context.loaderOverlay.hide();
    } catch (e) {
      print(e);
      context.loaderOverlay.hide();
    }
  }

  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
  bool isEdit = false;
  String addressId = "";
  TextEditingController postalCode = TextEditingController();
  @override
  void initState() {
    // Initialize controllers with data passed via the constructor or default values
    firstName = TextEditingController(text: widget.firstName ?? '');
    lastName = TextEditingController(text: widget.lastName ?? '');
    contactNumber = TextEditingController(text: widget.contactNumber ?? '');
    emailAddress = TextEditingController(text: widget.emailAddress ?? '');
    streetAddress = TextEditingController(text: widget.streetAddress ?? '');
    landMark = TextEditingController(text: widget.landMark ?? '');
    postalCode =
        TextEditingController(text: widget.postalCodeController?.text ?? '');
    if (widget.hasAddress) {
      isEdit = true;
      Address address = widget.address!;
      addressId = address.addressId;
      firstName.text = address.firstName;
      lastName.text = address.lastName;
      contactNumber.text = address.contactNumber;
      emailAddress.text = address.email;
      streetAddress.text = address.streetAddress;
      landMark.text = address.landmark;
      postalCode.text = address.postalCode;
      city.text = address.city;
      state.text = address.state;
      country.text = address.country;
      isDefaultBilling = address.defaultBilling == "1" ? true : false;
      isDefaultShipping = address.defaultShipping == "1" ? true : false;
    } else {
      isEdit = false;
    }

    if (widget.postalCodeController != null) {
      postalCode = widget.postalCodeController!;
    }

    final arguments = Get.arguments ?? {};
    print("Arguments in AddAddress page: $arguments");

    // Extract individual values
    var pageFrom = arguments['pageFrom'] ?? '';
    final address = arguments['Address'] ?? {};
    print("Page From: $pageFrom");
    print("Address: $address");
    print("Arguments.. in add addrerss page... ${Get.arguments}");
    if (arguments.isNotEmpty) {
      // Initialize controllers with received data or empty if not provided
      firstName = TextEditingController(text: arguments['firstName'] ?? '');
      lastName = TextEditingController(text: arguments['lastName'] ?? '');
      contactNumber =
          TextEditingController(text: arguments['contactNumber'] ?? '');
      emailAddress =
          TextEditingController(text: arguments['emailAddress'] ?? '');
      streetAddress =
          TextEditingController(text: arguments['streetAddress'] ?? '');
      landMark = TextEditingController(text: arguments['landMark'] ?? '');
      postalCode = TextEditingController(text: arguments['postalcode'] ?? '');
      pageFrom = arguments['pageFrom'] ?? '';
      print("Page received in add address page is :$pageFrom");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Print the received values for debugging
    print("Received values in AddAddress page:");
    print('Address: $widget.address.firstName');
    print('Has Address: $widget.hasAddress');
    print('From Cart: $widget.fromCart');
    print(
        'Page From: ${Get.arguments?['pageFrom']}'); // It should print 'addresspage'

    // Set the initial pincode value and trigger address fetch logic
    if (postalCode.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // Fetch the address data
          var data =
              await profileViewModel.getAddressFromPincode(postalCode.text);

          // Check if data is valid and populate the text fields
          if (data != null) {
            city.text = data['city'] ?? ''; // Populate city
            state.text = data['state'] ?? ''; // Populate state
            country.text = data['country'] ?? ''; // Populate country
          } else {
            print('No address data found for the given pincode');
          }
        } catch (e) {
          print('Error fetching address: $e');
        }
      });
    }

    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          "${isEdit ? 'EDIT' : 'ADD'} AN ADDRESS",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: BackButton(
          onPressed: () {
            widget.fromCart
                ? Get.to(() => AddressPage(
                      fromCart: widget.fromCart,
                    ))
                : Get.back();
          },
        ),
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(content: Text("Tap back again to leave")),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: CustomButton(
                  text: "Use My Current Location",
                  onPressed: () async {
                    _getAddress();
                  },
                  padding: const EdgeInsets.all(10),
                ),
              ),
              TextFormFieldComponent(
                  controller: firstName,
                  padding: 20,
                  labelText: "First Name",
                  prefixIcon: const Icon(Icons.person_2_outlined),
                  keyboardType: TextInputType.name,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter First Name";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: lastName,
                  padding: 20,
                  labelText: "Last Name",
                  isRequired: true,
                  prefixIcon: const Icon(Icons.person_2_outlined),
                  keyboardType: TextInputType.name,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Last Name";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: contactNumber,
                  padding: 20,
                  labelText: "Contact Number",
                  prefixIcon: const Icon(Icons.phone_android_outlined),
                  prefix: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "+91",
                      style: GoogleFonts.firaSans(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Contact Number";
                    } else if (value.length != 10) {
                      return "Contact Number is should 10 digits";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: emailAddress,
                  padding: 20,
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Email Address";
                    } else if (!emailRegex.hasMatch(value)) {
                      return "Please Enter a valid Email";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: streetAddress,
                  padding: 20,
                  labelText: "Street Address",
                  prefixIcon: const Icon(Icons.map_outlined),
                  keyboardType: TextInputType.streetAddress,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Street Address";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: landMark,
                  padding: 20,
                  labelText: "Landmark",
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Landmark";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: postalCode,
                  padding: 20,
                  labelText: "Postal Code",
                  prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  onChanged: (String? value) async {
                    setState(() {
                      isDefaultShipping = false;
                    });

                    if (value!.length == 6) {
                      var data =
                          await profileViewModel.getAddressFromPincode(value);
                      city.text = data['city'];
                      state.text = data['state'];
                      country.text = data['country'];
                    }
                  },
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Postal Code";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: city,
                  padding: 20,
                  labelText: "City",
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter City";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: state,
                  padding: 20,
                  labelText: "State",
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.place_outlined),
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter State";
                    }
                    return null;
                  }),
              TextFormFieldComponent(
                  controller: country,
                  padding: 20,
                  labelText: "Country",
                  prefixIcon: const Icon(Icons.flag_outlined),
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validation: (String? value) {
                    if (value == "" || value == null) {
                      return "Please Enter Country";
                    }
                    return null;
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: const Text(
                        "Do You Want To Make this Address As Default Shipping Address"),
                  ),
                  Switch(
                    value: isDefaultShipping,
                    activeColor: Colors.green,
                    // onChanged: (bool value) {
                    //   setState(() {
                    //     isDefaultShipping = !isDefaultShipping;
                    //   });
                    // })
                    onChanged: (bool value) {
                      setState(() {
                        isDefaultShipping = value; // Update the switch state
                      });
                      if (value) {
                        // If the switch is turned on, check pin code validity
                        checkPinCode(postalCode.text);
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: const Text(
                        "Do You Want To Make this Address As Default Billing Address"),
                  ),
                  Switch(
                      value: isDefaultBilling,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        setState(() {
                          isDefaultBilling = !isDefaultBilling;
                        });
                      })
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                    text: "Submit",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (firstName.text.isNotEmpty &&
                            lastName.text.isNotEmpty &&
                            contactNumber.text.isNotEmpty &&
                            emailAddress.text.isNotEmpty &&
                            streetAddress.text.isNotEmpty &&
                            landMark.text.isNotEmpty &&
                            postalCode.text.isNotEmpty &&
                            city.text.isNotEmpty &&
                            state.text.isNotEmpty &&
                            country.text.isNotEmpty) {
                          context.loaderOverlay.show();
                          if (isEdit) {
                            bool response =
                                await profileViewModel.updateAddress(
                                    addressId: addressId,
                                    firstName: firstName.text,
                                    lastName: lastName.text,
                                    contactNumber: contactNumber.text,
                                    emailAddress: emailAddress.text,
                                    streetAddress: streetAddress.text,
                                    landMark: landMark.text,
                                    postalCode: postalCode.text,
                                    city: city.text,
                                    state: state.text,
                                    country: country.text,
                                    isDefaultShipping: isDefaultShipping,
                                    isDefaultBilling: isDefaultBilling);

                            if (response) {
                              context.loaderOverlay.hide();

                              profileViewModel.getAllAddress();

                              showNotificationSnackBar("Successfully Updated",
                                  NotificationStatus.success);
                              // Get.back();
                              print(
                                  "Add address successful...${Get.arguments['pageFrom']}");
                              // Check the pageFrom argument
                              if (Get.arguments != null &&
                                  Get.arguments['pageFrom'] == 'cartpage') {
                                Get.to(() => const CartScreen());
                              } else if (Get.arguments != null &&
                                  Get.arguments['pageFrom'] == 'addresspage') {
                                Get.to(() => const AddressPage());
                              } else {
                                Get.back();
                              }
                            } else {
                              context.loaderOverlay.hide();
                              showNotificationSnackBar("Something went wrong",
                                  NotificationStatus.failure);
                            }
                          } else {
                            bool response = await profileViewModel.saveAddress(
                                firstName: firstName.text,
                                lastName: lastName.text,
                                contactNumber: contactNumber.text,
                                emailAddress: emailAddress.text,
                                streetAddress: streetAddress.text,
                                landMark: landMark.text,
                                postalCode: postalCode.text,
                                city: city.text,
                                state: state.text,
                                country: country.text,
                                isDefaultShipping: isDefaultShipping,
                                isDefaultBilling: isDefaultBilling);
                            if (response) {
                              context.loaderOverlay.hide();
                              showNotificationSnackBar("Successfully Added",
                                  NotificationStatus.success);
                              // widget.fromCart ? Get.off(()=>HomeScreen(initialIndex: 2,)) : Get.back();
                              // Check the pageFrom argument
                              if (Get.arguments != null &&
                                  Get.arguments['pageFrom'] == 'cartpage') {
                                Get.to(() => const CartScreen());
                              } else if (Get.arguments != null &&
                                  Get.arguments['pageFrom'] == 'addresspage') {
                                Get.to(() => const AddressPage());
                              } else {
                                Get.back();
                              }

                              profileViewModel.getAllAddress();
                            } else {
                              context.loaderOverlay.hide();
                              showNotificationSnackBar("Something went wrong",
                                  NotificationStatus.failure);
                            }
                          }
                        } else {
                          showNotificationSnackBar(
                              "Please fill all mandatory Fields",
                              NotificationStatus.failure);
                        }
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
