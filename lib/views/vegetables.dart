import 'package:cubes_n_slice/views/common_widgets/Search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../constants/assets.dart';
import '../domain/productViewModel.dart';
import '../models/dto/product.dart';
import '../utils/myStates.dart';
import 'common_widgets/CartIcon.dart';
import 'common_widgets/appBar.dart';
import 'common_widgets/horizontal_product_list.dart';

class VegetablesScreen extends StatefulWidget {
  VegetablesScreen({Key? key}) : super(key: key);

  @override
  State<VegetablesScreen> createState() => _VegetablesScreenState();
}

class _VegetablesScreenState extends State<VegetablesScreen> {
  final ProductViewModel productViewModel = Get.find<ProductViewModel>();
  bool isLoading = true;
  late List<Product> _productList;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show();
    print(Get.arguments['feature_type']);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productViewModel.getFeaturedProducts(Get.arguments['feature_type']);
      setState(() {});
      context.loaderOverlay.hide();
    });
  }

  double getCardWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 320) return 180;
    if (screenWidth <= 375) return 200;
    if (screenWidth <= 414) return 220;
    return 220;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = getCardWidth(context);
    return Scaffold(
      appBar: MyAppBar(
        title: const Padding(
            padding: EdgeInsets.only(right: 16.0), child: SearchOverlay()),
        leading:
            InkResponse(onTap: () => Get.back(), child: const BackButtonIcon()),
        actions: <Widget>[CartIcon()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () {
            // Use the productViewModel.currentState to determine the state
            if (productViewModel.productState is LoadingState) {
              // Loading state, show a loading indicator or placeholder
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  mainAxisExtent: 225,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffdddddd),
                        border: Border.all(color: const Color(0xffF1F1F5)),
                        borderRadius: BorderRadius.circular(8)),
                    width: (MediaQuery.of(context).size.width / 2) - 34,
                  );
                },
                itemCount: 6,
              );
            } else if (productViewModel.productState is LoadedState) {
              // Loaded state, display the product list
              _productList =
                  (productViewModel.productState as LoadedState).data;
              return DefaultTabController(
                length: 3,
                child: GridView.builder(
                  shrinkWrap: true,
                  // controller: ProductViewModel.scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      mainAxisExtent: 300),
                  itemBuilder: (context, index) {
                    if (index < _productList.length) {
                      print(
                          "product list in ui length =>${_productList.length}");
                      return ProductCard(
                        product: _productList[index],
                        cardWidth: cardWidth,
                      );
                    }
                    print("product list in ui length =>${_productList.length}");
                    return const SizedBox.shrink();
                    // Customize this part to extract data from your product model
                  },
                  itemCount: _productList.length +
                      (productViewModel.page.value < 8 ? 1 : 0),
                ),
              );
            } else if (productViewModel.productState is FailureState) {
              // Failure state, show an error message
              final errorMessage =
                  (productViewModel.productState as FailureState).errorMessage;
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
                      onPressed: () {
                        context.loaderOverlay.show();
                        print("feature type " + Get.arguments['feature_type']);
                        productViewModel
                            .getFeaturedProducts(Get.arguments['feature_type']);
                        context.loaderOverlay.hide();
                      },
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
            } else {
              // Handle other states as needed
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  mainAxisExtent: 225,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffdddddd),
                        border: Border.all(color: const Color(0xffF1F1F5)),
                        borderRadius: BorderRadius.circular(8)),
                    width: (MediaQuery.of(context).size.width / 2) - 34,
                  );
                },
                itemCount: 6,
              );
            }
          },
        ),
      ),
    );
  }
}
