import 'package:cubes_n_slice/models/source/local/product_local_storage.dart';
import 'package:cubes_n_slice/models/source/remote/api.dart';

import 'dto/categorie.dart';
import 'dto/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Api _api;
  final LocalStorage _localStorage;

  ProductRepositoryImpl({
    required Api api,
    required LocalStorage localStorage,
  })  : _api = api,
        _localStorage = localStorage;

  Product? removeProductByid({required BigInt id}) {
    return _localStorage.removeProductById(id: id);
  }

  @override
  Future<List<Banners>> getAllBanners({bool hardRest = false}) async {
    if (!hardRest) {
      final cachedList = _localStorage.loadBanners();
      if (cachedList.isNotEmpty) {
        return cachedList;
      }
    }

    final fetchedList = await _api.loadBanners();
    await _localStorage.saveBanners(banners: fetchedList);

    return fetchedList;
  }

  @override
  Future<List<Product>> getFeaturedProducts(String featureType,
      {bool hardRest = false}) async {
    try {
      // if (!hardRest) {
      //   final cachedList = _localStorage.loadFeaturedProductList(featureType);
      //
      //   if (cachedList.isNotEmpty) {
      //     return cachedList;
      //   }
      // }

      final fetchedList = await _api.loadFeaturedProducts(featureType);
      // await _localStorage.saveFeaturedProducts(
      //     list: fetchedList, featureType: featureType);
      return fetchedList;
    } catch (e) {
      final fetchedList = await _api.loadFeaturedProducts(featureType);
      // await _localStorage.saveFeaturedProducts(
      //     list: fetchedList, featureType: featureType);
      return fetchedList;
    }
  }

  @override
  Future<List<Categorie>> getCategory({bool hardRest = false}) async {
    try {
      if (!hardRest) {
        final cachedList = _localStorage.loadCategory();

        if (cachedList.isNotEmpty) {
          return cachedList;
        }
      }
      final fetchedList = await _api.getAllCategory();
      await _localStorage.saveCategory(categories: fetchedList);
      return fetchedList;
    } catch (e) {
      final fetchedList = await _api.getAllCategory();
      await _localStorage.saveCategory(categories: fetchedList);
      return fetchedList;
    }
  }

  @override
  Future<List<SubCategorie>> getSubCategoriesWithProducts(
      String categoryId) async {
    final fetchedlist = await _api.getAllSubCategoryWithProducts(categoryId);
    return fetchedlist;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final fetchedlist = await _api.searchProducts(query);
    return fetchedlist;
  }

  @override
  Future<Product> getProductByid(int id) async {
    final fetchedlist = await _api.getProductById(id);
    return fetchedlist;
  }
}

abstract class ProductRepository {
  Future<List<Banners>> getAllBanners({bool hardRest = false});

  Future<List<Product>> getFeaturedProducts(String featureType,
      {bool hardRest = false});

  Future<List<Categorie>> getCategory({bool hardRest = false});

  Future<List<SubCategorie>> getSubCategoriesWithProducts(String categoryId);

  Future<List<Product>> searchProducts(String query);

  Future<Product> getProductByid(int id);
}
