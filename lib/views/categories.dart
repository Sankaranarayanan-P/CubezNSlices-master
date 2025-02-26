import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/views/common_widgets/Search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../domain/categorieViewModel.dart';
import '../models/dto/categorie.dart';
import '../models/dto/product.dart';
import '../utils/dimensions.dart';
import '../utils/myStates.dart';
import 'common_widgets/CartIcon.dart';
import 'common_widgets/appBar.dart';

class Categories extends StatefulWidget {
  final int initialIndex;
  final String categoryId;

  const Categories({super.key, this.initialIndex = 0, this.categoryId = ""});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories>
    with AutomaticKeepAliveClientMixin {
  final CategorieViewModel _categorieViewModel = Get.find<CategorieViewModel>();

  int selectedCategoryIndex = 0;
  bool hasParameters = false;
  bool initiallyLoadedFromCategorySelection = false;

  @override
  void initState() {
    super.initState();

    getInitialData();
  }

  Future<void> getInitialData() async {
    try {
      context.loaderOverlay.show();
      if (initiallyLoadedFromCategorySelection == false &&
          widget.initialIndex != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _categorieViewModel.getAllCategories(
              hasParameter: true, category_id: widget.categoryId);
        });
        selectedCategoryIndex = int.parse(widget.initialIndex.toString());
        await _categorieViewModel.getSubCategories(widget.categoryId);
        hasParameters = true;
        initiallyLoadedFromCategorySelection = true;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _categorieViewModel.getAllCategories();
          if (_categorieViewModel.categories.isNotEmpty) {
            await _categorieViewModel.getSubCategories(_categorieViewModel
                .categories[selectedCategoryIndex].category_id!);
          }
        });
        hasParameters = false;
      }
    } catch (e) {
      await _categorieViewModel.getAllCategories();
      if (_categorieViewModel.categories.isNotEmpty) {
        await _categorieViewModel.getSubCategories(
            _categorieViewModel.categories[selectedCategoryIndex].category_id!);
      }

      hasParameters = false;
    } finally {
      context.loaderOverlay.hide();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(Get.currentRoute == "/HomeScreen");
    return Scaffold(
      appBar: MyAppBar(
        leading: Get.currentRoute == "/HomeScreen"
            ? const SizedBox()
            : BackButton(
                onPressed: () {
                  Get.back();
                  setState(() {
                    selectedCategoryIndex = 0;
                  });
                },
              ),
        title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchOverlay()),
        actions: <Widget>[CartIcon()],
      ),
      body: RefreshIndicator(
        onRefresh: getInitialData,
        child: Obx(
          () {
            if (_categorieViewModel.currentState is LoadedState) {
              final categoryList = _categorieViewModel.categories;
              return Row(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 16),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Get.theme.cardColor,
                    ),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: categoryList.length,
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        Categorie category = categoryList[index];
                        return InkWell(
                          onTap: () async {
                            setState(() {
                              selectedCategoryIndex = index;
                              hasParameters = false;
                            });
                            print(categoryList[index].category_id);
                            if (!hasParameters) {
                              context.loaderOverlay.show();
                              await _categorieViewModel.getSubCategories(
                                  categoryList[index].category_id!);
                              context.loaderOverlay.hide();
                            }
                          },
                          child: CategoryItem(
                            title: category.name,
                            icon: category.thumbnail,
                            isSelected: selectedCategoryIndex == index,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (_categorieViewModel.subCategoriesState
                          is LoadingState) {
                        return const SizedBox();
                      } else if (_categorieViewModel.subCategoriesState
                          is LoadedState) {
                        final subCategories = (_categorieViewModel
                                .subCategoriesState as LoadedState)
                            .data as List<SubCategorie>;
                        if (subCategories.isNotEmpty) {
                          return ListView.builder(
                            itemCount: subCategories.length,
                            itemBuilder: (context, index) {
                              final subCategory = subCategories[index];
                              print("products are ${subCategory.products!}");
                              return ExpansionTile(
                                initiallyExpanded: true,
                                title: Text(subCategory.subcategory_name ?? ''),
                                children: [
                                  if (subCategory.products != null &&
                                      subCategory.products!.isNotEmpty)
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                      ),
                                      itemCount: subCategory.products!.length,
                                      itemBuilder: (context, index) {
                                        final Product product =
                                            subCategory.products![index];
                                        print(product.imageUrl);
                                        return GestureDetector(
                                          onTap: () => Get.toNamed('/details',
                                              arguments: product),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GridTile(
                                              footer: GridTileBar(
                                                backgroundColor: Colors.black54,
                                                title: Text(
                                                  product.productName ?? '',
                                                  style: GoogleFonts.firaSans(),
                                                ),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    product.imageUrl ?? '',
                                                fit: BoxFit.contain,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    const Center(
                                      child: Text(
                                          'No products available for this subcategory'),
                                    ),
                                ],
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text('Not Available'));
                        }
                      } else {
                        return const Center(
                            child: Text('Failed to load subcategories'));
                      }
                    }),
                  ),
                ],
              );
            } else if (_categorieViewModel.currentState is LoadingState) {
              return const SizedBox();
            } else {
              return const Center(
                child: Text('Failed to load categories'),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CategoryItem extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;

  const CategoryItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeExtraSmall, horizontal: 2),
      decoration: BoxDecoration(
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 5), // changes position of shadow
                ),
              ]
            : [],
        borderRadius: BorderRadius.circular(20),
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).cardColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 80,
              width: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Get.theme.cardColor.withOpacity(0.05)),
              child: CircleAvatar(
                //backgroundColor: Get.theme.cardColor,
                backgroundColor: Theme.of(context).cardColor,
                radius: 40,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CachedNetworkImage(
                    imageUrl: icon!,
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall),
                child: Text(
                  title!.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
