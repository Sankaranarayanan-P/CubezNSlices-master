import 'package:cubes_n_slice/views/welcome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _circleAnimation;
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _imageRevealAnimation;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _circleAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
    ));

    _circleScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
    ));

    _imageRevealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final SharedPreferences _sharedPref =
            await SharedPreferences.getInstance();
        isLoggedIn = _sharedPref.getBool("isLoggedIn") ?? false;
        if (isLoggedIn) {
          Future.delayed(
            const Duration(seconds: 1),
            () => Get.offAllNamed("/dashboard", arguments: 1),
          );
        } else {
          Future.delayed(
            const Duration(seconds: 1),
            () => Get.offAll(() => const WelcomeScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double circleSize = screenSize.width * 0.65;
    final double imageSize = circleSize * 0.8;

    return Scaffold(
      backgroundColor: Get.theme.primaryColor,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SlideTransition(
              position: _circleAnimation,
              child: ScaleTransition(
                scale: _circleScaleAnimation,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _imageRevealAnimation,
              builder: (context, child) {
                return ClipPath(
                  clipper: RevealClipper(_imageRevealAnimation.value),
                  child: child,
                );
              },
              child: Hero(
                tag: 'app_icon_hero',
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: Tween<double>(begin: 1.0, end: 0.5)
                            .animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ))
                            .value,
                        child: Transform.translate(
                          offset: Tween<Offset>(
                            begin: Offset.zero,
                            end: Offset(0, -screenSize.height * 0.1),
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
                      backgroundColor: Colors.transparent,
                      radius: imageSize / 2,
                      child: ClipOval(
                        child: Image.asset(
                          Assets.imageLogoWithoutSubtitle,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: imageSize / 2,
                  child: ClipOval(
                    child: Image.asset(
                      Assets.imageLogoWithoutSubtitle,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevealClipper extends CustomClipper<Path> {
  final double revealPercent;

  RevealClipper(this.revealPercent);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * revealPercent, 0);
    path.lineTo(size.width * revealPercent, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(RevealClipper oldClipper) =>
      revealPercent != oldClipper.revealPercent;
}
