import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/cartIconController.dart';
import '../../domain/cartViewModel.dart';

class CartIcon extends StatelessWidget {
  CartIcon({super.key});
  final ShoppingCartViewModel shoppingCart = Get.find<ShoppingCartViewModel>();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Get.toNamed("/cart");
          },
          icon: StreamBuilder<int>(
            stream: Get.find<CartIconModel>().cartUpdates,
            builder: (context, snapshot) {
              final int cartCount = snapshot.data ?? 0;
              return cartCount > 0
                  ? badges.Badge(
                      badgeContent: Text(
                        cartCount.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      position: badges.BadgePosition.topEnd(top: -10, end: -10),
                      child: const Icon(Icons.shopping_cart_rounded),
                    )
                  : const Icon(Icons.shopping_cart_outlined);
            },
          ),
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }
}
