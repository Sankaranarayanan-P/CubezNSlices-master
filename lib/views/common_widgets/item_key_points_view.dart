import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../constants/assets.dart';

class ItemKeyPointsView extends StatelessWidget {
  const ItemKeyPointsView({
    super.key,
    required this.imagePath,
    required this.title,
    required this.desc,
  });

  final String imagePath;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      height: 200,
      child: Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                return Image.asset(
                  Assets.noImage,
                  width: 60,
                  height: 60,
                );
              },
            ),
            const SizedBox(
                height: 12), // Increased spacing between image and title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff23AA49),
              ),
              textAlign: TextAlign.center,
            ),

            Expanded(
              child: Html(
                data: desc,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(14),
                    textAlign: TextAlign.center,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
