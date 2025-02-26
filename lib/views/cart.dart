import 'package:cubes_n_slice/constants/appConstants.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/utils/myStates.dart';
import 'package:cubes_n_slice/views/add_address.dart';
import 'package:cubes_n_slice/views/address_page.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:popover/popover.dart';

import '../constants/assets.dart';
import '../domain/cartViewModel.dart';
import '../domain/profileView.dart';
import 'common_widgets/appBar.dart';
import 'common_widgets/cart_item.dart';
import 'deliveryLocations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ShoppingCartViewModel cartViewModel = Get.find<ShoppingCartViewModel>();
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  // final RxBool isCartEmpty = false.obs;
  bool isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartViewModel.getCartItemList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          "CART 🛒",
          style:
              GoogleFonts.firaSans(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Get.currentRoute == "/HomeScreen" ? const SizedBox() : null,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                if (!mounted) {
                  return const SizedBox();
                }
                if (cartViewModel.cartState is LoadingState) {
                  if (!isOverlayVisible) {
                    context.loaderOverlay.show();
                    isOverlayVisible = true;
                  }
                  return const SizedBox();
                } else if (cartViewModel.cartState is LoadedState) {
                  if (isOverlayVisible) {
                    context.loaderOverlay.hide();
                    isOverlayVisible = false;
                  }
                  final cartItemList =
                      cartViewModel.productCartMap.values.toList();

                  if (cartItemList.isEmpty) {
                    // isCartEmpty.value = true;
                    return Center(
                      child: Image.asset(
                        Assets.imagesEmptyCart,
                        width: 300,
                        height: 300,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) {
                            return const Divider(
                              color: Color(0xffF1F1F5),
                            );
                          },
                          itemCount: cartViewModel.productCartMap.length,
                          itemBuilder: (context, index) {
                            return CartItemWidget(
                              item: cartItemList[index],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            "Your shopping cart will remain saved and we will send you a notification to complete your purchase.",
                            style: TextStyle(
                                fontSize: 12,
                                color: Get.theme.colorScheme.primary),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  final errorMessage =
                      (cartViewModel.cartState as FailureState).errorMessage;
                  return Center(
                    child: Column(
                      children: [
                        Image.asset(
                          Assets.imagesEmptyList,
                          scale: 4,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(errorMessage),
                        const SizedBox(
                          height: 8,
                        ),
                        ElevatedButton(
                          onPressed: () => {cartViewModel.getCartItemList()},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            shape: const StadiumBorder(),
                            backgroundColor: Get.theme.primaryColor,
                          ),
                          child: const Text(
                            "Refresh",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  );
                }
              }),
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Get.theme.cardColor.withOpacity(0.6),
              child: Column(
                children: [
                  Obx(() => cartViewModel.productCartMap.values.toList().isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text("Add items to Enjoy our Seamless orders",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.bottomNavigationBarTheme
                                      .backgroundColor)),
                        )
                      : const SizedBox()),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cartViewModel.baseAmount.value == "₹0"
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Total price (with tax)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 4),
                                Builder(builder: (context) {
                                  return Obx(() => Text(
                                        cartViewModel.baseAmount.value,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ));
                                }),
                              ],
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() {
                          final cartItemList =
                              cartViewModel.productCartMap.values.toList();
                          return CustomButton(
                            text: "Checkout",
                            onPressed: cartItemList.isEmpty ||
                                    cartViewModel.outOfStock.value
                                ? () {}
                                : _showCheckoutDialog,
                            backgroundColor: !cartViewModel.outOfStock.value &&
                                    cartItemList.isNotEmpty
                                ? Get.theme.primaryColor
                                : Get.theme.disabledColor,
                          );
                          return ElevatedButton(
                            onPressed: cartItemList.isEmpty
                                ? null
                                : cartViewModel.outOfStock.value
                                    ? null
                                    : _showCheckoutDialog,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              shape: const StadiumBorder(),
                              backgroundColor:
                                  !cartViewModel.outOfStock.value &&
                                          cartItemList.isNotEmpty
                                      ? Get.theme.primaryColor
                                      : Get.theme.disabledColor,
                            ),
                            child: const Text(
                              "Checkout",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                      ),
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

  Future<Object?> showPopoverNotification(BuildContext context,
      {required ShoppingCartViewModel cartViewModel}) {
    final baseAmount = cartViewModel.baseAmount.value;
    final discountPrice = cartViewModel.disCountPrice.value;
    final deliveryCharge = cartViewModel.deliveryCharge.value;
    return showPopover(
      context: context,
      // backgroundColor: Colors.white,
      radius: 16.0,
      bodyBuilder: (context) => Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [const Text("Amount"), Text(baseAmount)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Delivery Charge"),
                    Text(deliveryCharge)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [const Text("Discount"), Text("- $discountPrice")],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Grand Total"),
                    Text(cartViewModel.grandTotal.value)
                  ],
                ),
              ),
            ],
          )),
      direction: PopoverDirection.bottom,
      width: 210,
      height: 200,
      // arrowHeight: 15,
      // arrowWidth: 30,
      // onPop: () {},
    );
  }

  void _showCheckoutDialog() async {
    Get.bottomSheet(
      const ConfirmAddress(),
      isScrollControlled: true,
    );
  }
}

class ConfirmAddress extends StatefulWidget {
  const ConfirmAddress({super.key});

  @override
  State<ConfirmAddress> createState() => _ConfirmAddressState();
}

class _ConfirmAddressState extends State<ConfirmAddress> {
  List<Address> addressList = [];
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  bool isLoading = false;
  @override
  void initState() {
    () async {
      await _fetchAddress();
    }();
    super.initState();
  }

  List<Widget> addressWidgetList = [];
  bool hasAnyShipping = false;
  bool hasAnyBilling = false;
  bool isPinCodeValid = false;
  Future<void> checkPinCode(String pinCode, Address addressData) async {
    print("Inside check function++++++++++++++++++++++++++++");
    print("Pin Code: $pinCode");

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
            _handlePincodeError(addressData);
          });
        }
      } else {
        _handlePincodeError(addressData);
      }
    } catch (e) {
      print("Error: $e");
      _handlePincodeError(addressData);
    }
  }

  void _handlePincodeError(Address addressData) {
    setState(() {
      isPinCodeValid = false;
    });
    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(''),
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
                // Get.to(() => DeliverylocationsPage(),
                //     arguments: {
                //       'pageFrom':'cartpage',
                //       'first':addressData.firstName,
                //       'last':addressData.lastName,
                //       'contact':addressData.contactNumber,
                //       'email' :addressData.email,
                //       'street':addressData.streetAddress,
                //       'land':addressData.landmark
                //     }
                // );

                Get.to(() => const DeliverylocationsPage(), arguments: {
                  'pageFrom': 'cartpage',
                  'firstName': addressData.firstName,
                  'lastName': addressData.lastName,
                  'contactNumber': addressData.contactNumber,
                  'emailAddress': addressData.email,
                  'streetAddress': addressData.streetAddress,
                  'landMark': addressData.landmark,
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAddress() async {
    setState(() {
      isLoading = true;
    });
    addressList = await profileViewModel.getAllAddress();
    addressWidgetList.clear();
    for (var addressdata in addressList) {
      bool hasShipping = addressdata.defaultShipping == "1";
      bool hasBilling = addressdata.defaultBilling == "1";

      if (hasShipping) {
        print("%%%%%%%%%%%%%%%%%%%%%%%%");
        print("Address Data:");
        print(
            addressdata); // Will print all fields if `toString` is implemented.

        // Access individual fields if needed:
        print("Postal Code: ${addressdata.postalCode}");
        print("First Name: ${addressdata.firstName}");
        checkPinCode(addressdata.postalCode, addressdata);
        hasAnyShipping = true;
        addressWidgetList.add(
          addressWidget(
            addressdata,
            "Shipping address",
            hasAllAddress: hasBilling,
          ),
        );
      }

      if (hasBilling) {
        hasAnyBilling = true;
        addressWidgetList.add(
          addressWidget(
            addressdata,
            "Billing address",
            hasAllAddress: hasShipping,
          ),
        );
      }
    }

// Add messages if no addresses were found
    if (!hasAnyShipping) {
      addressWidgetList.add(Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text("Please choose Shipping Address to continue"),
          TextButton(
              onPressed: () {
                _showAllAddresses(
                  addressList,
                  "Shipping Address",
                );
              },
              child: const Text("Choose an address"))
        ],
      ));
    }

    if (!hasAnyBilling) {
      addressWidgetList.add(Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text("Please choose Billing Address to continue"),
          TextButton(
              onPressed: () {
                _showAllAddresses(
                  addressList,
                  "Billing Address",
                );
              },
              child: const Text("Choose an address"))
        ],
      ));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: isLoading
          ? Container(
              height: MediaQuery.of(context).size.height * 0.5,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Address'.capitalize!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Handling addressList being empty
                    addressList.isEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(Assets.noAddressJson,
                                      repeat: false, height: 200),
                                  const Text(
                                    "You don't have any addresses saved.\nAdd Address to Continue",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap:
                                true, // Important: prevents ListView from taking up infinite space
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevents ListView from scrolling independently
                            itemCount: addressWidgetList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return addressWidgetList[index];
                            },
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Add new address"),
                        IconButton(
                          icon: const Icon(Icons.add, size: 30),
                          tooltip: 'Add Address',
                          onPressed: () {
                            Get.to(() => const AddAddress(fromCart: true));
                          },
                          color: Colors.blue,
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                    CustomButton(
                      text: 'Confirm',
                      onPressed: addressList.isEmpty || !isPinCodeValid
                          ? null // Disable the button if address list is empty
                          : () {
                              Get.back();
                              Get.toNamed("/orderSummary");
                            },
                      isEnabled: !addressList
                          .isEmpty, // Disable if address list is empty
                      backgroundColor: Theme.of(context)
                          .primaryColor, // Optional: set background color
                    )
                  ],
                ),
              )),
    );
  }

  Column addressWidget(Address address, String addressType,
      {bool hasAllAddress = true, String notAvailableAddress = ""}) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildAddressSection(
            addressType,
            "${address.firstName} ${address.lastName}",
            address.contactNumber,
            '${address.streetAddress},${address.city},${address.state},${address.country}-${address.postalCode}',
            addressList),
      ],
    );
  }

  Widget _buildAddressSection(String addressType, String name, String phone,
      String address, List<Address> addresslist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          addressType.capitalize!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            print("Clicked");
            _showAllAddresses(
              addresslist,
              addressType,
            );
            // here open another modal showing all the address
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(phone),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(address,
                                style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAllAddresses(
    List<Address> alladdresslist,
    String addressType,
  ) {
    Get.bottomSheet(
      AddressSelectionWidget(
        alladdresslist: alladdresslist,
        addressType: addressType,
        onAddressSelected: _fetchAddress,
      ),
      isScrollControlled: true,
    );
  }
}

class AddressSelectionWidget extends StatefulWidget {
  final List<Address> alladdresslist;
  String? addressType;
  final VoidCallback onAddressSelected;
  AddressSelectionWidget(
      {super.key,
      required this.alladdresslist,
      required this.addressType,
      required this.onAddressSelected});

  @override
  State<AddressSelectionWidget> createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends State<AddressSelectionWidget>
    with WidgetsBindingObserver {
  int? selectedAddressIndex;
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  String addressId = "";
  @override
  void initState() {
    super.initState();
    selectedAddressIndex = widget.alladdresslist.indexWhere((address) =>
        address.defaultShipping == "1" || address.defaultBilling == "1");
    addressId = widget.alladdresslist[selectedAddressIndex ?? 0].addressId;
  }

  bool isPinCodeValid = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose a ${widget.addressType}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: widget.alladdresslist.length,
                itemBuilder: (BuildContext context, int index) {
                  Address address = widget.alladdresslist[index];
                  return _buildAddressItem(
                      address.addressId,
                      "${address.firstName} ${address.lastName}",
                      address.contactNumber,
                      '${address.streetAddress},${address.city},${address.state},${address.country}-${address.postalCode}',
                      address.defaultShipping == "1",
                      address.defaultBilling == "1",
                      index);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      foregroundColor: Colors.black),
                  child: const Text('Close'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.addressType?.toLowerCase() ==
                          "billing address") {
                        await profileViewModel.updateAddressBilling(
                            addressId: addressId);
                        widget.onAddressSelected();
                        Get.back();
                      } else if (widget.addressType?.toLowerCase() ==
                          "shipping address") {
                        await profileViewModel.updateAddressShipping(
                            addressId: addressId);
                        widget.onAddressSelected();
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        // minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.green,
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        foregroundColor: Colors.black),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(String Id, String name, String phone, String address,
      bool isShippingAddress, bool isBillingAddress, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: Colors.blue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (isShippingAddress)
                        const Badge(
                          backgroundColor: Colors.green,
                          label: Text("Shipping Address"),
                        ),
                      if (isShippingAddress) const SizedBox(width: 10),
                      if (isBillingAddress)
                        const Badge(
                          backgroundColor: Colors.blue,
                          label: Text("Billing Address"),
                        )
                    ],
                  ),
                  Text(phone),
                  Text(address, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(
                onPressed: () async {
                  await Get.to(() => AddAddress(
                        address: widget.alladdresslist[index],
                        hasAddress: true,
                      ));
                  widget.onAddressSelected();
                  Get.back();
                },
                icon: const Icon(Icons.edit)),
            Radio<int>(
              value: index,
              groupValue: selectedAddressIndex,
              onChanged: (value) {
                setState(() {
                  selectedAddressIndex = value;
                  addressId = Id;
                });
                print(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
