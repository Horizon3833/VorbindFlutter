import 'package:flutter/material.dart';
import 'package:vorbind/animations/logo_animation.dart';
import 'package:vorbind/helpers/custom_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.darkGrey[700],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LogoAnimation(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login', style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold,),
              ),
              Text(
                'Please sign in to continue', style: TextStyle(color: Colors.grey, fontSize: 17,),
              ),
              Form(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              ))
            ]
          )
        ],
      ),
    );
  }
}
