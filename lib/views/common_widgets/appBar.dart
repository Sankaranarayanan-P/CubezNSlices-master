import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final double? leadingWidth;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  final Color? backgroundColor;
  const MyAppBar(
      {super.key,
      this.leading,
      this.leadingWidth,
      this.title,
      this.actions,
      this.backgroundColor,
      this.bottom});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 1,
        leading: leading,
        leadingWidth: leadingWidth,
        elevation: 4,
        titleSpacing: 0.0,
        centerTitle: true,
        title: title,
        toolbarHeight: 200,
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
