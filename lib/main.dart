import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vorbind/helpers/custom_colors.dart';
import 'package:vorbind/pages/home.dart';
import 'animations/logo_animation.dart';
import 'firebase_options.dart';
import 'helpers/vorbind_routes.dart';
import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: CustomColors.darkGrey,
      ),
      initialRoute: VorbindRoutes.splashPage,
      routes: {
        VorbindRoutes.splashPage: (BuildContext context) => const SplashScreen(),
        VorbindRoutes.homePage: (BuildContext context) => const Home(),
        VorbindRoutes.loginPage: (BuildContext context) => const LoginPage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  _nextScreen(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    _nextScreen(context);

    return const Scaffold(
      backgroundColor: CustomColors.darkGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoAnimation(), // Use LogoAnimation directly here
          ],
        ),
      ),
    );
  }
}
