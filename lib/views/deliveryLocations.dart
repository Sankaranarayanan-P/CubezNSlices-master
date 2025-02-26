import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'add_address.dart';
import 'common_widgets/appBar.dart';
import 'home.dart';

class DeliverylocationsPage extends StatefulWidget {
  const DeliverylocationsPage({super.key});

  @override
  State<DeliverylocationsPage> createState() => _DeliverylocationsPageState();
}

class _DeliverylocationsPageState extends State<DeliverylocationsPage> {
  late Future<List<Map<String, String>>> _locationsFuture;

  @override
  void initState() {
    super.initState();
    // Log received arguments
    print("Arguments received in DeliverylocationsPage: ${Get.arguments}");
    _locationsFuture = fetchDeliveryLocations();
  }

  Future<List<Map<String, String>>> fetchDeliveryLocations() async {
    const String apiUrl =
        "https://gspedia.com/projects/cubes/api/fetch_delivery_locations";

    try {
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse["data"] ?? [];

        return data
            .map<Map<String, String>>((location) => {
          "office": location["office"] ?? "Unknown Office",
          "pincode": location["pincode"] ?? "Unknown Pincode",
        })
            .toList();
      } else {
        throw Exception("Failed to load locations");
      }
    } catch (e) {
      throw Exception("Error fetching delivery locations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments
    final arguments = Get.arguments;

    // Check and log arguments
    if (arguments != null) {
      print('Received arguments: $arguments');
    } else {
      print('No arguments received!');
    }

    // Extract individual values
    final firstName = arguments?['firstName'] ?? 'Unknown First Name';
    final lastName = arguments?['lastName'] ?? 'Unknown Last Name';
    final contactNumber = arguments?['contactNumber'] ?? 'Unknown Contact';
    final emailAddress = arguments?['emailAddress'] ?? 'Unknown Email';
    final streetAddress = arguments?['streetAddress'] ?? 'Unknown Address';
    final landMark = arguments?['landMark'] ?? 'Unknown Landmark';
    final pageFrom = arguments?['pageFrom'] ?? 'Unknown Page';

    print('Navigated from in delivery locations page: $pageFrom');

    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          "DELIVERY LOCATIONS",
          style: GoogleFonts.firaSans(fontWeight: FontWeight.bold),
        ),
        leading: BackButton(
          onPressed: () {
            Get.off(() => HomeScreen(initialIndex: 4));
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _locationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No delivery locations found."));
          }

          final List<Map<String, String>> locations = snapshot.data!;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return _buildLocationCard(location["office"]!, location["pincode"]!);
            },
          );
        },
      ),
    );
  }

  Widget _buildLocationCard(String office, String pincode) {
    final arguments = Get.arguments;
    return InkWell(
      onTap: arguments != null
          ? () {
        // Add the selected pincode to the arguments
        final updatedArguments = {
          ...arguments,
          'postalcode': pincode,
        };

        // Navigate to AddAddress page with updated arguments
        // Get.to(() => AddAddress(), arguments: updatedArguments);
        // Check if 'pageFrom' is 'cartpage' and pass it explicitly
        if (arguments['pageFrom'] == 'cartpage') {
          updatedArguments['pageFrom'] = 'cartpage';
        }else if (arguments['pageFrom'] == 'addresspage') {
          updatedArguments['pageFrom'] = 'addresspage';
        }

        // Navigate to AddAddress page with updated arguments
        Get.to(() => AddAddress(), arguments: updatedArguments);
      }
          : null, // Disable onTap if no arguments
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 6,
        shadowColor: Colors.teal.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 40,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_post_office,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pincode,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
