import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/dto/product.dart';
import '../models/product_repo_Impl.dart';
import '../models/source/remote/api.dart';
import '../utils/myStates.dart';

class ProductViewModel extends GetxController {
  final ProductRepository _productRepository;

  ProductViewModel({required ProductRepository productRepositoryImpl})
      : _productRepository = productRepositoryImpl;

  final Rx<MyState> _productState = MyState().obs;

  MyState get productState => _productState.value;

  final Rx<MyState> _bannerState = MyState().obs;

  MyState get bannerState => _bannerState.value;

  final RxList<Product> _productList = <Product>[].obs;

  List<Product> get productList => _productList;

  final RxList<Banners> _bannerList = <Banners>[].obs;

  List<Banners> get bannerList => _bannerList;

  RxInt page = 1.obs;

  // Future<void> getAllProductList(int page) async {
  //   try {
  //     final productList =
  //         await _productRepository.getAllProductList(page: page);
  //     _productState.value = LoadingState();
  //
  //     if (productList.isEmpty) {
  //       // Set state to EmptyDataState if the result is empty
  //       _productState.value = FailureState('Data is empty');
  //     } else {
  //       // Update state to LoadedState with data
  //       _productState.value = LoadedState(productList);
  //       _productList.value = productList;
  //     }
  //   } catch (e) {
  //     print('Error fetching data in viewModel: $e');
  //     // Update state to FailureState with error message
  //     _productState.value = FailureState('An error occurred');
  //   }
  // }

  Future<void> getFeaturedProducts(String featureType,
      {bool hardRest = false}) async {
    try {
      _productState.value = LoadingState();
      final productList = await _productRepository
          .getFeaturedProducts(featureType, hardRest: hardRest);
      print("productlist ${productList}");
      if (productList.isEmpty) {
        // Set state to EmptyDataState if the result is empty
        _productState.value = FailureState('Data is empty');
      } else {
        // Update state to LoadedState with data
        print("updated the state");
        _productList.assignAll(productList);
        _productState.value = LoadedState(productList);
      }
    } catch (e) {
      print('Error fetching data in viewModel: $e');
      // Update state to FailureState with error message
      _productState.value = FailureState('An error occurred');
    }
  }

  Future<void> getAllBanners({bool hardRest = false}) async {
    try {
      _bannerList.clear();
      _bannerState.value = LoadingState();
      final bannerList =
          await _productRepository.getAllBanners(hardRest: hardRest);
      if (bannerList.isEmpty) {
        // Set state to EmptyDataState if the result is empty
        _bannerState.value = FailureState('Data is empty');
      } else {
        // Update state to LoadedState with data
        _bannerState.value = LoadedState(bannerList);
        _bannerList.assignAll(bannerList);
      }
    } catch (e) {
      print('Error fetching data in viewModel: $e');
      // Update state to FailureState with error message
      _bannerState.value = FailureState('An error occurred');
    }
  }

  Future<Product?> getProductById(int id) async {
    Product product = Product();
    try {
      final data = await _productRepository.getProductByid(id);
      product = data;
      return product;
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    await getAllBanners(hardRest: true);
  }

  @override
  void onClose() {
    _productState.close();
    _bannerState.close();
    // scrollController.dispose();
    super.onClose();
  }
}
