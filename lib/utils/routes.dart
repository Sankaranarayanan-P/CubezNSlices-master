import 'package:cubes_n_slice/views/add_address.dart';
import 'package:cubes_n_slice/views/address_page.dart';
import 'package:cubes_n_slice/views/cart.dart';
import 'package:cubes_n_slice/views/categories.dart';
import 'package:cubes_n_slice/views/common_widgets/Search.dart';
import 'package:cubes_n_slice/views/deliveryLocations.dart';
import 'package:cubes_n_slice/views/orderDetailpage.dart';
import 'package:cubes_n_slice/views/orderSummary.dart';
import 'package:cubes_n_slice/views/paymentProcessing.dart';
import 'package:cubes_n_slice/views/paymentSuccessFailure.dart';
import 'package:cubes_n_slice/views/policy_page.dart';
import 'package:cubes_n_slice/views/profile.dart';
import 'package:cubes_n_slice/views/profileUpdate.dart';
import 'package:cubes_n_slice/views/registration.dart';
import 'package:cubes_n_slice/views/splash.dart';
import 'package:cubes_n_slice/views/vegetables.dart';
import 'package:cubes_n_slice/views/welcome.dart';
import 'package:get/get.dart';

import '../views/OtpViewPage.dart';
import '../views/dashboard.dart';
import '../views/home.dart';
import '../views/ordersPage.dart';
import '../views/paymentModes.dart';
import '../views/product_detail.dart';

class MyRoutes {
  static final List<GetPage> pages = [
    GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/', page: () => const WelcomeScreen()),
    GetPage(name: '/registration', page: () => RegistrationScreen()),

    GetPage(name: '/deliveryLocations', page: () => DeliverylocationsPage()),
    GetPage(
        name: "/otp",
        page: () => const OtpPage(
              data: {},
            )),
    GetPage(name: '/dashboard', page: () => HomeScreen()),
    GetPage(name: '/home', page: () => DashboardScreen()),
    GetPage(name: '/categories', page: () => const Categories()),
    GetPage(name: '/cart', page: () => CartScreen()),
    GetPage(name: '/profile', page: () => const Profile()),
    GetPage(name: '/vegetables', page: () => VegetablesScreen()),
    GetPage(name: '/search', page: () => const SearchOverlay()),
    GetPage(name: '/details', page: () => const ProductDetails()),
    GetPage(name: "/profileupdate", page: () => const ProfileUpdate()),
    GetPage(name: "/policyPage", page: () => const PolicyPage()),
    GetPage(name: "/addresspage", page: () => AddressPage()),
    GetPage(name: "/add-address", page: () => const AddAddress()),
    GetPage(name: "/orderSummary", page: () => const orderSummary()),
    GetPage(
        name: "/paymentmode",
        page: () => PaymentModes(
              orderDetails: {},
            )),
    GetPage(
        name: "/paymentsuccessfailure", page: () => PaymentSuccessFailure()),
    // GetPage(name: "/paymentmainpage", page: () => PaymentMainPage())
    GetPage(
        name: "/paymentprocessing",
        page: () => PaymentProcessing(
              transcationalDetails: const {},
              orderDetails: {},
            )),
    GetPage(name: "/ordersPage", page: () => const OrdersPage()),
    GetPage(
      name: "/orderdetail",
      page: () => OrderDetailPage(),
    ),
    GetPage(name: "/invoicepdf", page: () => PDFScreen())
  ];
}
