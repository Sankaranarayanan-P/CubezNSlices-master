// import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
// import 'package:cubes_n_slice/views/common_widgets/TextFormFieldComponent.dart';
// import 'package:cubes_n_slice/views/common_widgets/appBar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';
// import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart';
//
// import '../../constants/assets.dart';
//
// class PaymentMainPage extends StatefulWidget {
//   const PaymentMainPage({super.key});
//
//   @override
//   State<PaymentMainPage> createState() => _PaymentMainPageState();
// }
//
// class _PaymentMainPageState extends State<PaymentMainPage> {
//   final List<Map<String, dynamic>> paymentOptions = [
//     {'title': 'Card', 'icon': Icons.credit_card},
//     {'title': 'Upi', 'icon': Icons.account_balance_outlined},
//     {'title': 'Net Banking', 'icon': Icons.food_bank},
//     {'title': 'Wallets', 'icon': Icons.wallet},
//   ];
//   int? selectedIndex;
//   List<Widget> paymentComponents = [];
//   void selectPaymentOption(int index) {
//     paymentComponents.clear();
//     switch (index) {
//       case 0:
//         paymentComponents.add(const CardFillComponent());
//         break;
//       case 1:
//         paymentComponents.add(const UPIComponents());
//         break;
//       default:
//         paymentComponents.add(const SizedBox());
//     }
//     setState(() {
//       selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const MyAppBar(
//         title: Text("Payment"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Select your Payment Method",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.35,
//                     child: GridView.builder(
//                       padding: const EdgeInsets.all(16),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                         childAspectRatio: 1,
//                       ),
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: paymentOptions.length,
//                       itemBuilder: (context, index) {
//                         return GestureDetector(
//                           onTap: () => selectPaymentOption(index),
//                           child: PaymentOptionCard(
//                             title: paymentOptions[index]['title'],
//                             icon: paymentOptions[index]['icon'],
//                             isSelected: index == selectedIndex,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Column(
//                     children: paymentComponents,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Powered By ",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     Image.asset(
//                       Assets.razorPayLogo,
//                       width: 70,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 CustomButton(text: "Pay Now", onPressed: () {}),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class PaymentOptionCard extends StatefulWidget {
//   final String title;
//   final IconData icon;
//   final bool isSelected;
//
//   const PaymentOptionCard({
//     Key? key,
//     required this.title,
//     required this.icon,
//     this.isSelected = false,
//   }) : super(key: key);
//
//   @override
//   State<PaymentOptionCard> createState() => _PaymentOptionCardState();
// }
//
// class _PaymentOptionCardState extends State<PaymentOptionCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       width: 100,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//         color: widget.isSelected ? Colors.blue[50] : Colors.white,
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(widget.icon,
//               size: 32,
//               color: widget.isSelected ? Colors.blue : Colors.grey[600]),
//           const SizedBox(height: 8),
//           Text(widget.title,
//               style: TextStyle(
//                   color: widget.isSelected ? Colors.blue : Colors.black)),
//         ],
//       ),
//     );
//   }
// }
//
// class CardFillComponent extends StatefulWidget {
//   const CardFillComponent({super.key});
//
//   @override
//   State<CardFillComponent> createState() => _CardFillComponentState();
// }
//
// class _CardFillComponentState extends State<CardFillComponent> {
//   bool isLightTheme = true;
//   String cardNumber = '';
//   String expiryDate = '';
//   String cardHolderName = '';
//   String cvvCode = '';
//   bool isCvvFocused = false;
//   bool useGlassMorphism = false;
//   bool useBackgroundImage = true;
//   bool useFloatingAnimation = true;
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Text(
//           "Fill out your card details for seemless checkout",
//           textAlign: TextAlign.start,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         CreditCardWidget(
//             cardNumber: cardNumber,
//             expiryDate: expiryDate,
//             cardHolderName: cardHolderName,
//             cvvCode: cvvCode,
//             obscureCardCvv: false,
//             obscureCardNumber: false,
//             isHolderNameVisible: true,
//             showBackView: false, //true when you want to show cvv(back) view
//             onCreditCardWidgetChange: (CreditCardBrand brand) {}),
//         Column(
//           children: <Widget>[
//             CreditCardForm(
//               formKey: formKey,
//               obscureCvv: true,
//               obscureNumber: false,
//               cardNumber: cardNumber,
//               cvvCode: cvvCode,
//               isHolderNameVisible: true,
//               isCardNumberVisible: true,
//               isExpiryDateVisible: true,
//               autovalidateMode: AutovalidateMode.always,
//               cardHolderName: cardHolderName,
//               expiryDate: expiryDate,
//               enableCvv: true,
//               cvvValidationMessage: 'Please input a valid CVV',
//               dateValidationMessage: 'Please input a valid date',
//               numberValidationMessage: 'Please input a valid number',
//               inputConfiguration: const InputConfiguration(
//                 cardNumberDecoration: InputDecoration(
//                   labelText: 'Number',
//                   hintText: 'XXXX XXXX XXXX XXXX',
//                 ),
//                 expiryDateDecoration: InputDecoration(
//                   labelText: 'Expired Date',
//                   hintText: 'XX/XX',
//                 ),
//                 cvvCodeDecoration: InputDecoration(
//                   labelText: 'CVV',
//                   hintText: 'XXX',
//                 ),
//                 cardHolderDecoration: InputDecoration(
//                   labelText: 'Card Holder',
//                 ),
//               ),
//               onCreditCardModelChange: onCreditCardModelChange,
//             ),
//             const SizedBox(height: 20),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 20, right: 20),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline,
//                       color: Colors.black.withOpacity(0.6)),
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.7,
//                         child: Text(
//                             "We don't store your card details as per RBI Guidelines",
//                             style: TextStyle(
//                               color: Colors.black.withOpacity(0.6),
//                             ))),
//                   )
//                 ],
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
//
//   void onCreditCardModelChange(CreditCardModel creditCardModel) {
//     setState(() {
//       cardNumber = creditCardModel.cardNumber;
//       expiryDate = creditCardModel.expiryDate;
//       cardHolderName = creditCardModel.cardHolderName;
//       cvvCode = creditCardModel.cvvCode;
//       isCvvFocused = creditCardModel.isCvvFocused;
//     });
//   }
// }
//
// class UPIComponents extends StatefulWidget {
//   const UPIComponents({super.key});
//
//   @override
//   State<UPIComponents> createState() => _UPIComponentsState();
// }
//
// class _UPIComponentsState extends State<UPIComponents> {
//   TextEditingController vpacontroller = TextEditingController();
//   final Razorpay _razorpay = Razorpay();
//   @override
//   void initState() {
//     () async {
//       final upiApps = await _razorpay.getAppsWhichSupportUpi();
//       print(upiApps);
//     }();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TextFormFieldComponent(
//           controller: vpacontroller,
//           validation: (String? value) {},
//           labelText: "Enter your VPA",
//           hintText: "VPA Address",
//         )
//       ],
//     );
//   }
// }
