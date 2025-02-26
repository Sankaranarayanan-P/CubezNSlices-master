import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/productViewModel.dart';
import '../../models/product_repo_Impl.dart';
import '../../models/source/remote/api.dart';
import '../../utils/myStates.dart';

class Carousel extends StatefulWidget {
  final String bannerType;

  const Carousel({super.key, required this.bannerType});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late ProductViewModel productViewModel;

  @override
  void initState() {
    super.initState();
    productViewModel = Get.put(
      ProductViewModel(
          productRepositoryImpl: Get.find<ProductRepositoryImpl>()),
      tag: widget.bannerType,
      permanent: true, // This keeps the ViewModel in memory
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Only fetch if the state is not loaded or banners are not available
      if (productViewModel.bannerState is! LoadedState) {
        await productViewModel.getAllBanners();
      }
    });
  }

  @override
  void didUpdateWidget(Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannerType != widget.bannerType) {
      productViewModel.getAllBanners();
    }
  }

  bool isAutoplay = true;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Obx(() {
        final state = productViewModel.bannerState;
        if (state is LoadedState) {
          List<Banners> bannerList = state.data;
          List<Banners> filteredBanners = bannerList
              .where((item) => item.bannerType == widget.bannerType)
              .toList();

          isAutoplay = filteredBanners.length > 1;
          return filteredBanners.isNotEmpty
              ? CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1,
                    aspectRatio: widget.bannerType.toLowerCase() == "ad"
                        ? 32 / 10
                        : 16 / 9,
                    enableInfiniteScroll: isAutoplay,
                    initialPage: 2,
                    autoPlay: isAutoplay,
                    autoPlayCurve: Curves.easeIn,
                    autoPlayInterval: const Duration(seconds: 5),
                  ),
                  items: filteredBanners.map((item) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.28,
                            imageUrl: item.imgPath!,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              : const SizedBox();
        } else if (state is FailureState) {
          return Text('Error loading banners: ${state.errorMessage}');
        } else {
          return const CircularProgressIndicator(); // Show loader while data is being fetched
        }
      }),
    );
  }
}
