import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget{
  String message;
  ErrorMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Text(message, style: const TextStyle(color: Colors.black),)
    );
  }

}