import 'package:get/get.dart';

import '../models/dto/categorie.dart';
import '../models/product_repo_Impl.dart';
import '../utils/myStates.dart';

class CategorieViewModel extends GetxController {
  final ProductRepository _productRepository;
  CategorieViewModel({required ProductRepository productRepositoryImpl})
      : _productRepository = productRepositoryImpl;

  final Rx<MyState> _currentState = MyState().obs;
  MyState get currentState => _currentState.value;

  final Rx<MyState> _subCategoriesState = MyState().obs;
  MyState get subCategoriesState => _subCategoriesState.value;

  final Rx<MyState> _productsState = MyState().obs;
  MyState get productsState => _productsState.value;

  static List<Categorie> _categories = [];
  List<Categorie> get categories => _categories;

  Future<List<Categorie>> getAllCategoriesFromRepo(
      {bool hardRest = false}) async {
    return await _productRepository.getCategory(hardRest: hardRest);
  }

  Future<void> getAllCategories(
      {bool hardRest = false,
      bool hasParameter = false,
      String category_id = ""}) async {
    try {
      _currentState.value = LoadingState();
      _categories = await getAllCategoriesFromRepo(hardRest: hardRest);

      if (!hasParameter) {
        getSubCategories(_categories.first.category_id!);
      } else {
        getSubCategories(category_id);
      }
      _currentState.value = LoadedState(_categories);
    } catch (err) {
      print("error on category view $err");
      _currentState.value = FailureState(err.toString());
    }
  }

  Future<void> getSubCategories(String categoryId) async {
    try {
      _subCategoriesState.value = LoadingState();
      final subCategories =
          await _productRepository.getSubCategoriesWithProducts(categoryId);
      print("data loaded $subCategories");
      _subCategoriesState.value = LoadedState(subCategories);
    } catch (err) {
      print("error fetching subcategories: $err");
      _subCategoriesState.value = FailureState(err.toString());
    }
  }

  @override
  void onInit() {
    super.onInit();
    getAllCategories();
  }
}
