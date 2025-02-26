import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/dto/product.dart';
import '../models/product_repo_Impl.dart';

class SearchViewController extends GetxController {
  ProductRepository _productRepository;
  SearchViewController({required ProductRepository productRepositoryImpl})
      : _productRepository = productRepositoryImpl;
  final searchTextController = TextEditingController();
  final products = <Product>[].obs;
  final Rx<dynamic> state = Rx<dynamic>(null);
  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchTextController.removeListener(_onSearchChanged);
    searchTextController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchProducts(searchTextController.text);
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      products.clear();
      return;
    }

    try {
      final results = await _productRepository.searchProducts(query);
      products.assignAll(results);
    } catch (e) {
      print('Error searching products: $e');
    }
  }
}
