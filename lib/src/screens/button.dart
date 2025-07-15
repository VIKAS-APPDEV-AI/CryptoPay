import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final AnimationController controller;
  final String text;
  final VoidCallback onTap;
  final double finalWidth;
  final double finalHeight;
  final double finalRadius;
  final Color backgroundColor;
  final TextStyle textStyle;

  late final Animation<double> largura;
  late final Animation<double> altura;
  late final Animation<double> radius;
  late final Animation<double> opacidade;

  Button({
    super.key,
    required this.controller,
    required this.onTap,
    this.text = "Login",
    this.finalWidth = 500,
    this.finalHeight = 50,
    this.finalRadius = 20,
    this.backgroundColor = const Color(0xFF487FFF),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  }) {
    largura = Tween<double>(
      begin: 0,
      end: finalWidth,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5),
      ),
    );

    altura = Tween<double>(
      begin: 0,
      end: finalHeight,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.5, 0.7),
      ),
    );

    radius = Tween<double>(
      begin: 0,
      end: finalRadius,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.6, 1.0),
      ),
    );

    opacidade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.6, 0.8),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: finalHeight,
        child: Container(
          width: largura.value,
          height: altura.value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius.value),
            color: backgroundColor,
          ),
          child: Center(
            child: FadeTransition(
              opacity: opacidade,
              child: Text(
                text,
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
