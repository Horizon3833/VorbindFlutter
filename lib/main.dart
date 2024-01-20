import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vorbind/helpers/auth_provider.dart';
import 'package:vorbind/helpers/custom_colors.dart';
import 'package:vorbind/helpers/firebase_initialized.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vorbind/pages/home.dart';
import 'package:vorbind/pages/profile.dart';
import 'animations/logo_animation.dart';
import 'helpers/vorbind_routes.dart';
import 'pages/login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitialized().initializeFirebase();
  runApp(
    ChangeNotifierProvider(
      create: (context) => VorbindAuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseInitialized _firebaseInitialized = FirebaseInitialized();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInitialized.initializeFirebase(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _firebaseInitialized.connected = true;
        }
        return ScreenUtilInit(
          designSize: const Size(499, 671),
          child: MaterialApp(
            theme: ThemeData(
              primarySwatch: CustomColors.darkGrey,
            ),
            initialRoute: VorbindRoutes.splashPage,
            routes: {
              VorbindRoutes.splashPage: (BuildContext context) =>
                  const SplashScreen(),
              VorbindRoutes.homePage: (BuildContext context) => const Home(),
              VorbindRoutes.loginPage: (BuildContext context) =>
                  const LoginPage(),
              VorbindRoutes.editProfile: (BuildContext context) =>
                  const ProfilePage(),
            },
          ),
        );
      }),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _nextScreen();
  }

  _nextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('login') != null) {
      if (prefs.getBool('login')!) {
        Navigator.pushNamed(context, '/home');
      } else {
        Navigator.pushNamed(context, '/login');
      }
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: CustomColors.darkGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoAnimation(),
          ],
        ),
      ),
    );
  }
}
