import 'package:flutter/widgets.dart';

class CalcDimensions {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * percent / 100.0;
  }

  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * percent / 100.0;
  }
}
