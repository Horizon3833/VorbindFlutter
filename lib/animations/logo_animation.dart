// logo_animation.dart
import 'package:flutter/material.dart';

class LogoAnimation extends StatefulWidget {
  const LogoAnimation({super.key});

  @override
  _LogoAnimationState createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: LogoPainter(_animation.value),
          child: Container(
            width: 150.0,
            height: 150.0,
          ),
        );
      },
    );
  }
}

class LogoPainter extends CustomPainter {
  final double animationValue;

  LogoPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    final Path path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.8);

    final double waveHeight = 20.0;

    final double waveOffset =
        size.height * 0.5 + waveHeight * 0.5 * (1 - animationValue);

    path.quadraticBezierTo(size.width * 0.8, waveOffset - waveHeight,
        size.width * 0.5, waveOffset);
    path.quadraticBezierTo(size.width * 0.2, waveOffset - waveHeight,
        size.width * 0.2, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
