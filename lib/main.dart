import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Firebase disabled for now
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/app_config.dart';
import 'core/theme/app_theme.dart';
import 'services/aws_iot_service.dart';
import 'services/kvs_webrtc_service.dart';
import 'services/doorphone_manager.dart';
import 'services/notification_service.dart';
import 'services/config_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/config_screen.dart';

// Background message handler for Firebase - DISABLED
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization disabled for now
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const DoorphoneViewerApp());
}

class DoorphoneViewerApp extends StatelessWidget {
  const DoorphoneViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>(create: (_) => AppConfig()),
        Provider<ConfigService>(create: (_) => ConfigServiceImpl()),
        Provider<AWSIoTService>(create: (_) => AWSIoTServiceImpl()),
        Provider<KVSWebRTCService>(create: (_) => KVSWebRTCServiceImpl()),
        ChangeNotifierProvider<DoorphoneManager>(
          create: (context) => DoorphoneManagerImpl(
            awsIoTService: context.read<AWSIoTService>(),
            kvsWebRTCService: context.read<KVSWebRTCService>(),
            configService: context.read<ConfigService>(),
          ),
        ),
        Provider<NotificationService>(
          create: (context) => NotificationServiceImpl(
            doorphoneManager: context.read<DoorphoneManager>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Doorphone Viewer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/config': (context) => const ConfigScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
