import 'package:cubes_n_slice/domain/OrderController.dart';
import 'package:cubes_n_slice/domain/profileView.dart';
import 'package:cubes_n_slice/models/OrderRepositoryImpl.dart';
import 'package:cubes_n_slice/models/user_repo_Impl.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/appConstants.dart';
import '../domain/SearchController.dart';
import '../domain/cartIconController.dart';
import '../domain/cartViewModel.dart';
import '../domain/categorieViewModel.dart';
import '../domain/productViewModel.dart';
import '../models/product_repo_Impl.dart';
import '../models/shopingCart_repo_impl.dart';
import '../models/source/local/cart_local_storage.dart';
import '../models/source/local/product_local_storage.dart';
import '../models/source/local/user_local_storage.dart';
import '../models/source/remote/api.dart';

Future initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => LocalStorageImpl(sharedPreferences: sharedPreferences),
      fenix: true);

  Get.lazyPut(() => ApiImpl(AppConstants.BASE_URL), fenix: true);

  Get.lazyPut(
      () => ProductRepositoryImpl(
            api: Get.find<ApiImpl>(),
            localStorage: Get.find<LocalStorageImpl>(),
          ),
      fenix: true);

  Get.lazyPut(
      () => ProductViewModel(
          productRepositoryImpl: Get.find<ProductRepositoryImpl>()),
      fenix: true);

  Get.lazyPut(() => CartLocalStorageImpl(sharedPreferences: sharedPreferences),
      fenix: true);

  Get.lazyPut(
      () => CartRepositoryImpl(
            api: Get.find<ApiImpl>(),
            cartLocalStorage: Get.find<CartLocalStorageImpl>(),
          ),
      fenix: true);

  Get.lazyPut(
      () => ShoppingCartViewModel(
          cartRepositoryImpl: Get.find<CartRepositoryImpl>()),
      fenix: true);

  Get.lazyPut(
      () => CartIconModel(cartRepositoryImpl: Get.find<CartRepositoryImpl>()),
      fenix: true);

  Get.lazyPut(() => UserLocalStorageImpl(sharedPreferences: sharedPreferences),
      fenix: true);

  Get.lazyPut(
      () => UserRepositoryImpl(
            api: Get.find<ApiImpl>(),
            localStorage: Get.find<UserLocalStorageImpl>(),
          ),
      fenix: true);
  Get.lazyPut(
      () =>
          ProfileViewModel(userRepositoryImpl: Get.find<UserRepositoryImpl>()),
      fenix: true);

  Get.put(
      CategorieViewModel(
          productRepositoryImpl: Get.find<ProductRepositoryImpl>()),
      permanent: true);

  Get.lazyPut(
      () => SearchViewController(
          productRepositoryImpl: Get.find<ProductRepositoryImpl>()),
      fenix: true);

  Get.lazyPut(
      () =>
          OrderViewModel(orderRepositoryImpl: Get.find<OrderRepositoryImpl>()),
      fenix: true);

  Get.lazyPut(() => OrderRepositoryImpl(api: Get.find<ApiImpl>()), fenix: true);

  //Get.put(SearchViewModel());

  //Get.put(MyGameController());
}

Future<LottieComposition?> customDecoder(List<int> bytes) {
  return LottieComposition.decodeZip(bytes, filePicker: (files) {
    return files.firstWhereOrNull(
        (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'));
  });
}
