import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({
    super.key,
    required this.imagePath,
    required this.catName,
    required this.context,
  });

  final String imagePath;
  final String catName;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          //backgroundColor: Get.theme.cardColor,
          backgroundColor: Theme.of(context).cardColor,
          radius: 40,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CachedNetworkImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Center(
          child: SizedBox(
            child: Text(
              catName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.clip,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
