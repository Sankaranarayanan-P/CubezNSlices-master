import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cubes_n_slice/constants/assets.dart';
import 'package:cubes_n_slice/domain/network_error_controller.dart';
import 'package:cubes_n_slice/firebase_options.dart';
import 'package:cubes_n_slice/utils/NotificationHandler.dart';
import 'package:cubes_n_slice/utils/helper.dart';
import 'package:cubes_n_slice/utils/myTheme.dart';
import 'package:cubes_n_slice/utils/routes.dart';
import 'package:cubes_n_slice/views/network_error_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';

// Lisitnening to the background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Product/Order/Offer Alert Channel',
    'Product/Order/Offer Alert Channel',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  if (message.notification != null) {
    flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(NetworkErrorController());
  await initDependencies();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationHandler.initialize();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
        initTheme: AppThemes.lightTheme1,
        builder: (context, myTheme) {
          return ScreenUtilInit(
              minTextAdapt: true,
              splitScreenMode: true,
              designSize: const Size(375, 812),
              // Base design size (e.g., iPhone 11)
              builder: (context, child) {
                return GlobalLoaderOverlay(
                  useDefaultLoading: false,
                  overlayWidgetBuilder: (_) {
                    return Center(child: Lottie.asset(Assets.appLoaderJson));
                  },
                  child: GetMaterialApp(
                    scaffoldMessengerKey: rootScaffoldMessengerKey,
                    debugShowCheckedModeBanner: false,
                    title: "CubezNSlices",
                    theme: myTheme,
                    initialRoute: "/splash",
                    getPages: MyRoutes.pages,
                    builder: (context, widget) {
                      return MediaQuery(
                        ///Setting font does not change with system font size
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: NetworkErrorHandler(
                          child: widget!,
                        ),
                      );
                    },
                  ),
                );
              });
        });
  }
}

class NetworkErrorHandler extends StatelessWidget {
  final Widget child;

  const NetworkErrorHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasNetworkError =
          Get.find<NetworkErrorController>().hasNetworkError;
      final hasNetworkConnection =
          Get.find<NetworkErrorController>().isConnected.value;
      return hasNetworkConnection
          ? hasNetworkError
              ? const NetworkErrorScreen()
              : child
          : const NetworkErrorScreen(
              NoConnection: true,
            );
    });
  }
}
