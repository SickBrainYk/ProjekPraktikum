import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home/home_page.dart';
import 'pages/user/home_user_page.dart';
import 'pages/user/login_page.dart';
import 'data/user_session_manager.dart';
import 'controllers/user_controller.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<UserModel?> _initializeSession() async {
    final int? userId = await UserSessionManager.getUserId();
    if (userId == null) return null;

    final user = await UserController().fetchUserById(userId);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _initializeSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final UserModel? user = snapshot.data;

        Widget initialRoute;
        if (user != null) {
          initialRoute = HomeUserPage(user: user);
        } else {
          initialRoute = const HomePage();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: initialRoute,
        );
      },
    );
  }
}
