// import 'package:cubes_n_slice/models/dto/User.dart';
// import 'package:cubes_n_slice/models/dto/categorie.dart';
// import 'package:cubes_n_slice/views/categories.dart';
// import 'package:cubes_n_slice/views/common_widgets/Search.dart';
// import 'package:cubes_n_slice/views/home.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:launch_review/launch_review.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import 'package:new_version/new_version.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:whatsapp_unilink/whatsapp_unilink.dart';
//
// import '../constants/assets.dart';
// import '../domain/categorieViewModel.dart';
// import '../domain/productViewModel.dart';
// import '../domain/profileView.dart';
// import '../models/product_repo_Impl.dart';
// import '../utils/myStates.dart';
// import 'common_widgets/CustomButton.dart';
// import 'common_widgets/appBar.dart';
// import 'common_widgets/carousel.dart';
// import 'common_widgets/categories_view.dart';
// import 'common_widgets/horizontal_product_list.dart';
// import 'common_widgets/see_all_view.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen>
//     with AutomaticKeepAliveClientMixin {
//   final ProductViewModel productViewModel = Get.find<ProductViewModel>();
//
//   final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
//   final newVersion = NewVersion(
//     iOSId: 'com.suffix.cubezNslice.cubez_n_slice',
//     androidId: 'com.suffix.cubezNslice.cubez_n_slice',
//   );
//   PackageInfo _packageInfo = PackageInfo(
//     appName: 'Unknown',
//     packageName: 'Unknown',
//     version: 'Unknown',
//     buildNumber: 'Unknown',
//   );
//
//   String userVersion = '';
//   Future<void> _initPackageInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     setState(() {
//       _packageInfo = info;
//       print(_packageInfo.version.runtimeType);
//       userVersion = _packageInfo.version;
//       print(userVersion);
//     });
//   }
//
//   bool isLoading = false;
//   User? user;
//
//   @override
//   void initState() {
//     () async {
//       setState(() {
//         isLoading = true;
//       });
//       user = await profileViewModel.getUserProfile();
//       await profileViewModel.checkAppVersion();
//       final SharedPreferences shared = await SharedPreferences.getInstance();
//       String? appVersion = shared.getString("appVersion");
//
//       print("tHE APP VERSION is ${appVersion!}");
//       await _initPackageInfo();
//       if (userVersion != appVersion) {
//         print("update required");
//         Future.delayed(const Duration(seconds: 1), () {
//           _showDialog();
//         });
//       }
//       setState(() {
//         isLoading = false;
//       });
//     }();
//     context.loaderOverlay.hide();
//     super.initState();
//   }
//
//   void _showDialog() {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             "Update",
//             style: GoogleFonts.firaSans(),
//           ),
//           content: Text("New Version Available", style: GoogleFonts.firaSans()),
//           actions: <Widget>[
//             CustomButton(
//               onPressed: () async {
//                 if (_packageInfo.packageName == "unknown") {
//                   LaunchReview.launch(
//                       androidAppId: 'com.suffix.cubezNslice.cubez_n_slice');
//                 } else {
//                   LaunchReview.launch(androidAppId: _packageInfo.packageName);
//                 }
//               },
//               text: 'Update Now',
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
//   var dio = Dio();
//
//   final CategorieViewModel categoryViewModel = Get.find<CategorieViewModel>();
//
//   @override
//   dispose() {
//     super.dispose();
//   }
//
//   bool isHardRest = false;
//
//   Future<void> loadRefreshedData() async {
//     // setState(() {
//     //   isHardRest = true;
//     // });
//     context.loaderOverlay.show();
//     await categoryViewModel.getAllCategories(hardRest: true);
//     Get.put(ProductViewModel(
//         productRepositoryImpl: Get.find<ProductRepositoryImpl>()));
//     await productViewModel.getAllBanners(hardRest: true);
//     await productViewModel.getFeaturedProducts("Top Selling Products",
//         hardRest: true);
//     await productViewModel.getFeaturedProducts("Special Products",
//         hardRest: true);
//     Future.delayed(const Duration(seconds: 2), () {
//       context.loaderOverlay.hide();
//     });
//     // setState(() {
//     //   isHardRest = false;
//     // });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(100.0),
//         child: MyAppBar(
//             leading: Padding(
//               padding: const EdgeInsets.only(bottom: 8, top: 8),
//               // child: DropDownMenu(),
//               child: Image.asset(
//                 Assets.imagesAppIcon,
//                 fit: BoxFit.cover,
//                 scale: 7.5,
//               ),
//             ),
//             leadingWidth: MediaQuery.of(context).size.width * 2.5 / 6,
//             actions: <Widget>[
//               // ThemeSwitcher(
//               //     clipper: const ThemeSwitcherCircleClipper(),
//               //     builder: (context) {
//               //       return
//               GestureDetector(
//                 onTap: () => {
//                   // ThemeSwitcher.of(context).changeTheme(
//                   //     theme: Get.isDarkMode
//                   //         ? AppThemes.lightTheme1
//                   //         : AppThemes.darkTheme2,
//                   //     isReversed: Get.isDarkMode ? false : true)
//                   Get.to(
//                       () => HomeScreen(
//                             initialIndex: 4,
//                           ),
//                       preventDuplicates: false)
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Text(user!.firstName!),
//                   ),
//                 ),
//               )
//               // }),
//             ]),
//       ),
//       body: RefreshIndicator(
//         onRefresh: loadRefreshedData,
//         child: SingleChildScrollView(
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           child: Column(children: [
//             const Padding(padding: EdgeInsets.all(10), child: SearchOverlay()),
//             Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                 child: Obx(() {
//                   if (productViewModel.bannerState is LoadingState) {
//                     return const SizedBox();
//                   } else if (productViewModel.bannerState is LoadedState) {
//                     return const Carousel(
//                       bannerType: "Main",
//                     );
//                   } else {
//                     return Container(
//                       margin: const EdgeInsets.all(20),
//                       height: 200,
//                       decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.4),
//                           borderRadius: BorderRadius.circular(20)),
//                     );
//                   }
//                 })),
//             Column(
//               children: [
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: SeeAllView(
//                       context: context,
//                       name: "Shop By Categories",
//                       onTapAction: () => Get.off(
//                           () => HomeScreen(
//                                 initialIndex: 1,
//                               ),
//                           preventDuplicates: false)),
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Obx(() {
//                     if (categoryViewModel.currentState is LoadingState) {
//                       return const SizedBox();
//                     } else if (categoryViewModel.currentState is FailureState) {
//                       return const Center(
//                           child: Text("Error loading categories"));
//                     } else if (categoryViewModel.currentState is LoadedState) {
//                       final categories = categoryViewModel.categories;
//                       return CategoryGridBuilder(categories: categories);
//                     } else {
//                       return const Text('Failed to load Categories');
//                     }
//                   }),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: SeeAllView(
//                     context: context,
//                     name: "Top Selling Products",
//                     onTapAction: () => Get.toNamed("/vegetables",
//                         arguments: {"feature_type": "Top Selling Products"}),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 12,
//                 ),
//                 LayoutBuilder(
//                   builder: (context, constraints) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: SizedBox(
//                         height: MediaQuery.of(context).size.width * 0.75,
//                         child: Obx(() {
//                           if (productViewModel.productState is LoadingState) {
//                             return const SizedBox();
//                           }
//                           return HorizontalProductList(
//                             page: 1,
//                             hardRefresh: isHardRest,
//                             featureType: "Top Selling Products",
//                             uniqueId: "top_selling",
//                           );
//                         }),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 ),
//                 Padding(
//                     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                     child: Obx(() {
//                       if (productViewModel.bannerState is LoadingState) {
//                         return const SizedBox();
//                       } else if (productViewModel.bannerState is LoadedState) {
//                         return const Carousel(
//                           bannerType: "Ad",
//                         );
//                       } else {
//                         return const SizedBox();
//                       }
//                     })),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: SeeAllView(
//                     context: context,
//                     name: "Our Signature Products",
//                     onTapAction: () => Get.toNamed("/vegetables",
//                         arguments: {"feature_type": "Our Signature Product"}),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 12,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 16),
//                   child: SizedBox(
//                       height: MediaQuery.of(context).size.width * 0.75,
//                       //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                       child: Obx(() {
//                         if (productViewModel.productState is LoadingState) {
//                           return const SizedBox();
//                         }
//                         return HorizontalProductList(
//                           page: 1,
//                           hardRefresh: isHardRest,
//                           featureType: "Our signature product",
//                           uniqueId: "special_products",
//                         );
//                       })),
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 ),
//               ],
//             ),
//           ]),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.green,
//         onPressed: () async {
//           const link = WhatsAppUnilink(
//             phoneNumber: '+917736078232',
//             text: "Hey! I'm inquiring about the CubezNSlices",
//           );
//           await launchUrl(link.asUri());
//         },
//         child: const Icon(FontAwesomeIcons.whatsapp),
//       ),
//     );
//   }
// }
//

import 'package:cubes_n_slice/controllers/app_update_controller.dart';
import 'package:cubes_n_slice/models/dto/User.dart';
import 'package:cubes_n_slice/models/dto/categorie.dart';
import 'package:cubes_n_slice/views/common_widgets/Search.dart';
import 'package:cubes_n_slice/views/home.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../constants/assets.dart';
import '../domain/categorieViewModel.dart';
import '../domain/productViewModel.dart';
import '../domain/profileView.dart';
import '../utils/myStates.dart';
import 'categories.dart';
import 'common_widgets/appBar.dart';
import 'common_widgets/carousel.dart';
import 'common_widgets/categories_view.dart';
import 'common_widgets/horizontal_product_list.dart';
import 'common_widgets/see_all_view.dart';

class CategoryGridBuilder extends StatelessWidget {
  const CategoryGridBuilder({
    super.key,
    required this.categories,
  });

  final List<Categorie> categories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double idealItemWidth = 80;
      int crossAxisCount = (constraints.maxWidth / idealItemWidth).floor();
      crossAxisCount = crossAxisCount.clamp(2, 5);

      final double itemWidth = (constraints.maxWidth - 20) / 4;
      final double aspectRatio = itemWidth / 150;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  Categorie category = categories[index];
                  Widget categoryWidget = Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(15),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.grey.withOpacity(0.1),
                    //       spreadRadius: 1,
                    //       blurRadius: 4,
                    //       offset: const Offset(0, 2),
                    //     ),
                    //   ],
                    // ),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => Categories(
                            initialIndex: index,
                            categoryId: category.category_id!,
                          ),
                          arguments: 1,
                        );
                      },
                      child: CategoriesView(
                        imagePath: category.thumbnail!,
                        catName: category.name!,
                        context: Get.context!,
                      ),
                    ),
                  );

                  if (categories.length < 3) {
                    return Center(
                      child: SizedBox(
                        width: constraints.minHeight,
                        child: categoryWidget,
                      ),
                    );
                  } else {
                    return categoryWidget;
                  }
                },
              );
            },
          ),
        ),
      );
    });
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  final ProductViewModel productViewModel = Get.find<ProductViewModel>();
  final ProfileViewModel profileViewModel = Get.find<ProfileViewModel>();
  final CategorieViewModel categoryViewModel = Get.find<CategorieViewModel>();
  final newVersion = NewVersion(
    iOSId: 'com.suffix.cubezNslice.cubez_n_slice',
    androidId: 'com.suffix.cubezNslice.cubez_n_slice',
  );

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  String userVersion = '';
  bool isLoading = false;
  bool isHardRest = false;
  User? user;
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    context.loaderOverlay.show();
    user = await profileViewModel.getUserProfile();
    await profileViewModel.checkAppVersion();
    await _loadPackageInfo();
    // await _checkForUpdates();
    Get.put(AppUpdateController()).checkAppUpdate();
    context.loaderOverlay.hide();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      userVersion = info.version;
    });
  }

  // Future<void> _checkForUpdates() async {
  //   // if(kDebugMode) return;
  //   final SharedPreferences shared = await SharedPreferences.getInstance();
  //   String? appVersion = shared.getString("appVersion");
  //   if (userVersion != appVersion) {
  //     _showUpdateDialog();
  // }

  // void _showUpdateDialog() {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.0), // Rounded corners
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0), // Add padding around content
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min, // Wrap content
  //             children: [
  //               const Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     Icons.system_update, // Icon for context
  //                     size: 40,
  //                     color: Colors.blueAccent,
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16), // Add space between icon and title
  //               Text(
  //                 "Update Available",
  //                 style: GoogleFonts.firaSans(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 10), // Space between title and content
  //               Text(
  //                 "A new version is available. Update to the latest version for better performance and new features!",
  //                 style: GoogleFonts.firaSans(
  //                   fontSize: 16,
  //                   color: Colors.grey[700],
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 20), // Space before button
  //               CustomButton(
  //                 onPressed: () async {
  //                   if (Platform.isAndroid) {
  //                     final appId = Platform.isAndroid
  //                         ? _packageInfo.packageName
  //                         : _packageInfo.packageName;
  //                     try {
  //                       launchUrl(
  //                         Uri.parse("market://details?id=$appId"),
  //                         mode: LaunchMode.externalApplication,
  //                       );
  //                     } on PlatformException catch (e) {
  //                       launchUrl(
  //                         Uri.parse(
  //                             "https://play.google.com/store/apps/details?id=$appId"),
  //                         mode: LaunchMode.externalApplication,
  //                       );
  //                     } finally {
  //                       launchUrl(
  //                         Uri.parse(
  //                             "https://play.google.com/store/apps/details?id=$appId"),
  //                         mode: LaunchMode.externalApplication,
  //                       );
  //                     }
  //                   }
  //                 },
  //                 text: 'Update Now',
  //                 textStyle: GoogleFonts.firaSans(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 ),
  //                 backgroundColor: Colors.blueAccent,
  //                 // Customize button style
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
  //               ),
  //               const SizedBox(height: 10), // Space after button
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> _loadRefreshedData() async {
    context.loaderOverlay.show();
    await categoryViewModel.getAllCategories(hardRest: true);
    await productViewModel.getAllBanners(hardRest: true);
    await productViewModel.getFeaturedProducts("Top Selling Products",
        hardRest: true);
    await productViewModel.getFeaturedProducts("Special Products",
        hardRest: true);
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadRefreshedData,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: SearchOverlay(),
              ),
              _buildBanner("Main"),
              const SizedBox(height: 16),
              _buildCategorySection(),
              const SizedBox(height: 30),
              _buildProductSection("Top Selling Products", "top_selling"),
              _buildBanner("Ad"),
              const SizedBox(height: 30),
              _buildProductSection("Our signature product", "special_products"),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildWhatsAppButton(),
    );
  }

  PreferredSize _buildAppBar() {
    print('firstname is ${user?.firstName!.isEmpty}');
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: MyAppBar(
        leading: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child:
              Image.asset(Assets.imagesAppIcon, fit: BoxFit.cover, scale: 7.5),
        ),
        leadingWidth: MediaQuery.of(context).size.width * 2.5 / 6,
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => HomeScreen(initialIndex: 4),
                preventDuplicates: false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                child: Text(user?.firstName!.isNotEmpty ?? false
                    ? user?.firstName?.substring(0, 1) ?? 'CS'
                    : "CS"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String bannerType) {
    return Obx(() {
      // Check the banner state reactively
      if (productViewModel.bannerState is LoadingState) {
        return Container(
          margin: const EdgeInsets.all(20),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        ); // or your loading widget
      } else if (productViewModel.bannerState is LoadedState) {
        return Carousel(bannerType: bannerType);
      } else {
        return Container(
          margin: const EdgeInsets.all(20),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }
    });
  }

  // Widget _buildPlaceholderBanner() {
  //   return Container(
  //     margin: const EdgeInsets.all(20),
  //     height: 200,
  //     decoration: BoxDecoration(
  //       color: Colors.grey.withOpacity(0.4),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //   );
  // }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 30),
          SeeAllView(
            context: context,
            name: "Shop By Categories",
            onTapAction: () => Get.off(() => HomeScreen(initialIndex: 1),
                preventDuplicates: false),
          ),
          const SizedBox(height: 16),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Obx(() {
      if (categoryViewModel.currentState is LoadingState)
        return const SizedBox();
      if (categoryViewModel.currentState is FailureState)
        return const Center(child: Text("Error loading categories"));
      if (categoryViewModel.currentState is LoadedState) {
        final categories = categoryViewModel.categories;
        return CategoryGridBuilder(categories: categories);
      }
      return const Text('Failed to load Categories');
    });
  }

  Widget _buildProductSection(String featureType, String uniqueId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SeeAllView(
            context: context,
            name: featureType,
            onTapAction: () => Get.toNamed("/vegetables",
                arguments: {"feature_type": featureType}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.8,
            child: Obx(() {
              if (productViewModel.productState is LoadingState) {
                return const SizedBox();
              }
              return HorizontalProductList(
                page: 1,
                hardRefresh: isHardRest,
                featureType: featureType,
                uniqueId: uniqueId,
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  FloatingActionButton _buildWhatsAppButton() {
    return FloatingActionButton(
      backgroundColor: Colors.green,
      tooltip: "Contact Us",
      onPressed: () async {
        String? text;
        if (user!.firstName!.isNotEmpty && user!.lastName!.isNotEmpty) {
          text =
              "Hey,My Name is ${user!.firstName} ${user!.middleName} ${user!.lastName}.I am interested in Fresh Meats and Fishes. I would like to know more about it, including pricing, availability, and any ongoing offers.";
        } else {
          text =
              "Hey! I am interested in Fresh Meats and Fishes. I would like to know more about it, including pricing, availability, and any ongoing offers.";
        }
        final link = WhatsAppUnilink(phoneNumber: '+917736078232', text: text);
        await launchUrl(link.asUri());
      },
      child: const Icon(FontAwesomeIcons.whatsapp),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
