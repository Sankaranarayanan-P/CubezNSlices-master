import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubes_n_slice/domain/SearchController.dart';
import 'package:cubes_n_slice/models/dto/product.dart';
import 'package:cubes_n_slice/utils/myStates.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:searchfield/searchfield.dart';

import '../../utils/helper.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  List<String> hintlist = [
    'Search for fresh meat or fish...',
    "Search for 'Prawns'",
    "Search for 'Beef'"
  ];
  String currenthint = "What are you looking for?";
  final focus = FocusNode();
  late final SearchViewController searchController;

  int hintIndex = 0;

  late Timer timer;
  @override
  void initState() {
    try {
      searchController = Get.find<SearchViewController>();
    } catch (e) {
      initDependencies();
    }
    timer = Timer.periodic(const Duration(seconds: 5), (count) {
      setState(() {
        hintIndex = (hintIndex + 1) % hintlist.length;
        currenthint = hintlist[hintIndex];
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    searchController.searchTextController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: SearchField<Product>(
            controller: searchController.searchTextController,
            hint: currenthint,
            suggestionStyle: GoogleFonts.firaSans(fontStyle: FontStyle.italic),
            searchInputDecoration: SearchInputDecoration(
              searchStyle: GoogleFonts.firaSans(fontStyle: FontStyle.italic),
              suffixIcon: searchController.searchTextController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.searchTextController.clear();
                      },
                    )
                  : null,
              hintStyle: const TextStyle(fontSize: 18, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            suggestionState: Suggestion.expand,
            itemHeight: 100,
            suggestions: searchController.products
                .map(
                  (e) => SearchFieldListItem<Product>(
                    e.productName!,
                    item: e,
                    child: SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(e.imageUrl!),
                            ),
                            const SizedBox(width: 10),
                            Text(e.productName!),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            onSuggestionTap: (SearchFieldListItem<Product> product) {
              focus.unfocus();
              Get.toNamed('/details',
                  arguments: product.item, preventDuplicates: false);
              searchController.searchTextController.clear();
            },
            focusNode: focus,
            suggestionsDecoration: SuggestionDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            onSearchTextChanged: (query) {
              () async {
                await searchController.searchProducts(query);
                setState(() {});
              }();
              return null;
            },
          ),
        ),
        Obx(() {
          final state = searchController.state.value;
          if (state is LoadingState) {
            return const SizedBox();
          } else if (state is FailureState) {
            return Text('Error: ${state.error}');
          } else if (state is LoadedState) {
            return Text('${state.data.length} results found');
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }
}
