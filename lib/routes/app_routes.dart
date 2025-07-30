import 'package:get/get.dart';
import 'package:event_management/screens/splash_screen.dart';
import 'package:event_management/screens/home_screen.dart';
import 'package:event_management/screens/event_list_screen.dart';
import 'package:event_management/screens/profile_screen.dart';
import 'package:event_management/authentication/login_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String eventList = '/event-list';
  static const String profile = '/profile';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: eventList, page: () => const EventListScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
  ];
}
