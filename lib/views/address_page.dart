import 'package:cubes_n_slice/constants/assets.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/views/add_address.dart';
import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
import 'package:cubes_n_slice/views/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../domain/profileView.dart';

class AddressPage extends StatefulWidget {
  final bool fromCart;

  const AddressPage({super.key, this.fromCart = false});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          "ADDRESS",
          style: GoogleFonts.firaSans(fontWeight: FontWeight.bold),
        ),
        leading: BackButton(
          onPressed: () {
            // widget.fromCart == false
            //     ? Get.off(() => HomeScreen(
            //           initialIndex: 4,
            //         ))
            //     : Get.back();

            widget.fromCart == false
                ? Get.off(() => HomeScreen(
              initialIndex: 4,
            ))
                : Get.off(() => HomeScreen(
              initialIndex: 4,
            ));
          },
        ),
      ),
      body: FutureBuilder<List<Address>>(
        future: profileViewModel.getAllAddress(),
        builder: (BuildContext context, AsyncSnapshot<List<Address>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoAddressView();
          } else {
            return _buildAddressList(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildNoAddressView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(Assets.noAddressJson, repeat: false),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Oops There is Nothing Over here?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            "You don't have any addresses saved. Saving address helps you checkout faster.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: CustomButton(
            text: "ADD AN ADDRESS",
            onPressed: () {
              Get.offAndToNamed("/add-address");
            },
          ),
        )
      ],
    );
  }

  Widget _buildAddressList(List<Address> addresses) {
    return ListView.builder(
      itemCount: addresses.length + 1, // +1 for the "Add Address" button
      itemBuilder: (context, index) {
        if (index == addresses.length) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: CustomButton(
              text: "ADD AN ADDRESS",
              onPressed: () {
                Get.toNamed("/add-address");
              },
            ),
          );
        }
        Address address = addresses[index];
        bool isDefaultShipping = address.defaultShipping == "1";
        bool isDefaultBilling = address.defaultBilling == "1";
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${address.firstName} ${address.lastName}",
                  style: GoogleFonts.firaSans(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (isDefaultShipping) _buildTag("Shipping", Colors.blue),
                    if (isDefaultBilling) _buildTag("Billing", Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${address.streetAddress}, ${address.landmark}\n${address.city}, ${address.state}, ${address.postalCode}",
                  style: GoogleFonts.firaSans(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // // Print the values to the console before navigating
                      // print('Navigating to AddAddress with the following values:');
                      // print('address: $address');
                      // print('hasAddress: true');
                      // print('fromCart: ${widget.fromCart}');
                      // print('pageFrom: addresspage');
                      // Get.to(() => AddAddress(
                      //     address: address,
                      //     hasAddress: true,
                      //     fromCart: widget.fromCart),
                      //     arguments: {
                      //       'pageFrom': 'addresspage',
                      //       // Add this line to pass 'pageFrom' argument
                      //     }
                      // );

                      Get.to(() => AddAddress(), arguments: {
                        'pageFrom': 'addresspage',
                        'firstName': address.firstName,
                        'lastName': address.lastName,
                        'contactNumber': address.contactNumber,
                        'emailAddress': address.email,
                        'streetAddress': address.streetAddress,
                        'landMark': address.landmark,
                        'city':address.city,
                        'country':address.country,
                        'postalcode':address.postalCode

                      });

                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.firaSans(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
