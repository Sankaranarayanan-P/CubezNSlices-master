import 'dart:async';

import 'package:cubes_n_slice/views/common_widgets/CustomButton.dart';
import 'package:cubes_n_slice/views/registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/assets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late ImageProvider backgroundImageProvider;
  bool isImageLoaded = false;
  double imageOpacity = 0.0;
  double blueBackgroundOpacity = 1.0;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  Future<void> _loadImage() async {
    // Load image as bytes
    final ByteData data = await rootBundle.load(Assets.imagesWelcomeBg);
    final Uint8List bytes = data.buffer.asUint8List();

    // Create image provider
    backgroundImageProvider = MemoryImage(bytes);

    // Precache the image
    await precacheImage(backgroundImageProvider, context);

    if (mounted) {
      setState(() {
        isImageLoaded = true;
      });

      Timer(const Duration(milliseconds: 100), () {
        setState(() {
          imageOpacity = 1.0;
          blueBackgroundOpacity = 0.0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Blue background with fade-out effect
          AnimatedOpacity(
            opacity: blueBackgroundOpacity,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Container(
              color: Get.theme.primaryColor,
            ),
          ),
          // Image with fade-in effect
          if (isImageLoaded)
            AnimatedOpacity(
              opacity: imageOpacity,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: backgroundImageProvider,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(1),
                  colorBlendMode: BlendMode.softLight,
                ),
              ),
            ),
          Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 44,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'app_icon_hero',
                          flightShuttleBuilder: (
                            BuildContext flightContext,
                            Animation<double> animation,
                            HeroFlightDirection flightDirection,
                            BuildContext fromHeroContext,
                            BuildContext toHeroContext,
                          ) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.fastEaseInToSlowEaseOut,
                              reverseCurve: Curves.fastEaseInToSlowEaseOut,
                            );
                            return AnimatedBuilder(
                              animation: curvedAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      ))
                                      .value,
                                  child: Transform.translate(
                                    offset: Tween<Offset>(
                                      begin: const Offset(0, -100),
                                      end: Offset.zero,
                                    )
                                        .animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOut,
                                        ))
                                        .value,
                                    child: child,
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Get.theme.cardColor,
                                radius: 150,
                                child: ClipOval(
                                  child: Image.asset(
                                    Assets.imagesAppIcon,
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Get.theme.cardColor,
                            radius: 100,
                            child: ClipOval(
                              child: Image.asset(
                                Assets.imagesAppIcon,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: const Text(
                            "We Deliver Fresh Fish and Meat At Your Door Step",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          child: const Text(
                            "Sea-to-table freshness at your fingertips.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 36,
                        ),
                        CustomButton(
                          widthFactor: 0.7,
                          text: "Shop now".toUpperCase(),
                          onPressed: () {
                            Get.to(() => RegistrationScreen());
                          },
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
