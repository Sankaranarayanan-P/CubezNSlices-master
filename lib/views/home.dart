// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
// import 'package:badges/badges.dart' as badges;
// import 'package:cubes_n_slice/views/profile.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../domain/cartViewModel.dart';
// import 'cart.dart';
// import 'categories.dart';
// import 'dashboard.dart';
//
// class HomeScreen extends StatefulWidget {
//   final int initialIndex;
//
//   const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
//   final RxInt _currentIndex = 0.obs;
//   final ShoppingCartViewModel shoppingCart = Get.find<ShoppingCartViewModel>();
//   PageController? _pageController;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _currentIndex.value = widget.initialIndex;
//     _initPageController();
//     shoppingCart.getCartItemList();
//   }
//
//   void _initPageController() {
//     _pageController?.dispose(); // Dispose of any existing controller
//     _pageController = PageController(initialPage: _currentIndex.value);
//   }
//
//   @override
//   void didUpdateWidget(HomeScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.initialIndex != oldWidget.initialIndex) {
//       _currentIndex.value = widget.initialIndex;
//       _initPageController();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return ThemeSwitchingArea(
//       child: Scaffold(
//         body: PageView(
//           controller: _pageController,
//           onPageChanged: (index) {
//             _currentIndex.value = index;
//           },
//           children: [
//             DashboardScreen(),
//             Categories(),
//             CartScreen(),
//             Profile(),
//           ],
//         ),
//         bottomNavigationBar: _buildBottomNavigationBar(),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _pageController?.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     shoppingCart.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       await shoppingCart.persistCartItems();
//     }
//   }
//
//   Widget _buildBottomNavigationBar() {
//     return Obx(() {
//       return BottomNavigationBar(
//         currentIndex: _currentIndex.value,
//         onTap: (index) {
//           _pageController?.jumpToPage(index);
//         },
//         items: [
//           _buildBottomNavigationBarItem(
//               _currentIndex.value == 0
//                   ? Icons.home_rounded
//                   : Icons.home_outlined,
//               "Home"),
//           _buildBottomNavigationBarItem(
//               _currentIndex.value == 1
//                   ? CupertinoIcons.cube_box_fill
//                   : CupertinoIcons.cube_box,
//               "Categories"),
//           _buildCartNavigationBarItem(),
//           _buildBottomNavigationBarItem(
//               _currentIndex.value == 3
//                   ? Icons.settings
//                   : Icons.settings_outlined,
//               "Settings"),
//         ],
//       );
//     });
//   }
//
//   BottomNavigationBarItem _buildBottomNavigationBarItem(
//       IconData icon, String label) {
//     return BottomNavigationBarItem(
//       icon: Icon(icon),
//       label: label,
//     );
//   }
//
//   BottomNavigationBarItem _buildCartNavigationBarItem() {
//     return BottomNavigationBarItem(
//       icon: StreamBuilder<int>(
//         stream: shoppingCart.cartU       builder: (context, snapshot) {
//           final int cartUpdates = snapshot.data ?? 0;
//           return cartUpdates > 0
//               ? badges.Badge(
//                   badgeContent: Text(
//                     cartUpdates.toString(),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   position: badges.BadgePosition.topEnd(top: -10, end: -10),
//                   child: Icon(Icons.shopping_cart_rounded),
//                 )
//               : const Icon(Icons.shopping_cart_outlined);
//         },
//       ),
//       label: "Cart",
//     );
//   }
// }

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cubes_n_slice/views/profile.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/cartIconController.dart';
import '../domain/cartViewModel.dart';
import 'cart.dart';
import 'categories.dart';
import 'dashboard.dart';
import 'ordersPage.dart';

// class HomeScreenController extends GetxController {
//   final RxInt currentIndex = 0.obs;
//   late PageController pageController;
//   final ShoppingCartViewModel shoppingCart = Get.find<ShoppingCartViewModel>();
//   HomeScreenController({required int initialIndex}) {
//     print("initial index is $initialIndex");
//     currentIndex.value = initialIndex;
//   }
//   @override
//   void onInit() {
//     super.onInit();
//     print("Current index is ${currentIndex.value}");
//     pageController = PageController(initialPage: currentIndex.value);
//     initializeCart();
//   }
//
//   Future<void> initializeCart() async {
//     await shoppingCart.getCartItemList();
//   }
//
//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }
//
//   void changePage(int index) {
//     print("Page change requested: $index");
//     currentIndex.value = index;
//     // pageController.jumpToPage(index);
//     pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
// }

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final bool hasCancelledOrder;

  HomeScreen({Key? key, this.initialIndex = 0, this.hasCancelledOrder = false})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShoppingCartViewModel shoppingCart = Get.find<ShoppingCartViewModel>();
  int _selectedScreenIndex = 0;
  late List<Widget> pages;

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  void initState() {
    shoppingCart.getCartItemList();
    setState(() {
      _selectedScreenIndex = widget.initialIndex;
    });
    pages = <Widget>[
      const DashboardScreen(),
      const Categories(initialIndex: 0),
      const CartScreen(),
      OrdersPage(hasCancelledOrder: widget.hasCancelledOrder),
      const Profile(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("current Index in homescreen is ${widget.initialIndex}");
    return ThemeSwitchingArea(
      child: Scaffold(
        body: DoubleBackToCloseApp(
            snackBar: const SnackBar(content: Text("Tap back again to leave")),
            child: pages[_selectedScreenIndex]),
        bottomNavigationBar: _buildBottomNavigationBar(_selectedScreenIndex),
      ),
    );
  }

  Widget _buildBottomNavigationBar(currentvalue) {
    print("in _buildBottomNavigationBar ${currentvalue}");
    return BottomNavigationBar(
      currentIndex: currentvalue,
      onTap: _selectScreen,
      items: [
        _buildBottomNavigationBarItem(
            currentvalue == 0 ? Icons.home_rounded : Icons.home_outlined,
            "Home"),
        _buildBottomNavigationBarItem(
            currentvalue == 1
                ? CupertinoIcons.cube_box_fill
                : CupertinoIcons.cube_box,
            "Categories"),
        _buildCartNavigationBarItem(),
        _buildBottomNavigationBarItem(
            currentvalue == 3
                ? Icons.shopping_bag
                : Icons.shopping_bag_outlined,
            "My Orders"),
        _buildBottomNavigationBarItem(
            currentvalue == 4 ? Icons.settings : Icons.settings_outlined,
            "Settings"),
      ],
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  BottomNavigationBarItem _buildCartNavigationBarItem() {
    print("cart update in ${shoppingCart.cartUpdates.toString()}");
    return BottomNavigationBarItem(
      icon: StreamBuilder<int>(
        stream: Get.find<CartIconModel>().cartUpdates,
        builder: (context, snapshot) {
          final int cartCount = snapshot.data ?? 0;
          print(cartCount);
          return cartCount > 0
              ? badges.Badge(
                  badgeContent: Text(
                    cartCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  position: badges.BadgePosition.topEnd(top: -10, end: -10),
                  child: const Icon(Icons.shopping_cart_rounded),
                )
              : const Icon(Icons.shopping_cart_outlined);
        },
      ),
      label: "Cart",
    );
  }
}
