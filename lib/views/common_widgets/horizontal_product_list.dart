import 'package:cubes_n_slice/constants/assets.dart';
import 'package:cubes_n_slice/domain/productViewModel.dart';
import 'package:cubes_n_slice/models/dto/product.dart';
import 'package:cubes_n_slice/models/product_repo_Impl.dart';
import 'package:cubes_n_slice/utils/myStates.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

class HorizontalProductList extends StatefulWidget {
  final int page;
  final bool hardRefresh;
  final String featureType;
  final String uniqueId;

  const HorizontalProductList({
    super.key,
    required this.page,
    this.hardRefresh = false,
    required this.featureType,
    required this.uniqueId,
  });

  @override
  State<HorizontalProductList> createState() => _HorizontalProductListState();
}

class _HorizontalProductListState extends State<HorizontalProductList> {
  late ProductViewModel productViewModel;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    () async {
      productViewModel = Get.put(
          ProductViewModel(
              productRepositoryImpl: Get.find<ProductRepositoryImpl>()),
          tag: widget.uniqueId,
          permanent: true);
      if (productViewModel.productState is! LoadedState) {
        await productViewModel.getFeaturedProducts(widget.featureType,
            hardRest: widget.hardRefresh);
      }
    }();
    // });
  }

  @override
  void didUpdateWidget(HorizontalProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.featureType != widget.featureType) {
      productViewModel.getFeaturedProducts(widget.featureType);
    }
  }

  double getCardWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 320) return 160;
    if (screenWidth <= 375) return 180;
    if (screenWidth <= 414) return 200;
    return 220;
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = getCardWidth(context);

    return SizedBox(
      height: cardWidth * 1.8,
      child: Obx(() {
        if (productViewModel.productState is LoadingState) {
          return _buildLoadingList(cardWidth);
        } else if (productViewModel.productState is LoadedState) {
          return _buildLoadedList(cardWidth);
        } else if (productViewModel.productState is FailureState) {
          return _buildErrorWidget();
        } else {
          return _buildLoadingList(cardWidth);
        }
      }),
    );
  }

  Widget _buildLoadingList(double cardWidth) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 234, 234, 234),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadedList(double cardWidth) {
    List<Product> productList =
        (productViewModel.productState as LoadedState).data;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: productList.length,
      // padding: const EdgeInsets.symmetric(horizontal: 16),

      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: cardWidth,
            child: ProductCard(
              product: productList[index],
              cardWidth: cardWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    final errorMessage =
        (productViewModel.productState as FailureState).errorMessage;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.imagesEmptyList,
            height: 80,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                productViewModel.getFeaturedProducts(widget.featureType),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final double cardWidth;

  const ProductCard({
    super.key,
    required this.product,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed('/details', arguments: product),
      child: SizedBox(
        width: cardWidth * 0.3,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section - Fixed aspect ratio
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl ?? Assets.noImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            size: cardWidth * 0.3,
                            color: Colors.grey[500],
                          ),
                        );
                      },
                    ),
                    if (product.quantity != null &&
                        double.parse(product.quantity!) < 5 &&
                        double.parse(product.quantity!) != 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Only Few Left',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: cardWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Details Section - Remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      Expanded(
                        child: Text(
                          product.productName!.toTitleCase(),
                          style: TextStyle(
                            fontSize: cardWidth * 0.09,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price and Cart Button
                      if (product.specialPrice != product.price) ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text(
                              '${product.specialPrice}',
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: cardWidth * 0.08,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              '${product.price}',
                              style: TextStyle(
                                fontSize: cardWidth * 0.08,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                height:
                                    0.5, // Adjust this value to lower the striked price
                              ),
                            ),
                            // SizedBox(width: cardWidth * 0.09),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
