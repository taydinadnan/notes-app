import 'package:flutter/material.dart';

class TopSlideAnimation extends StatelessWidget {
  const TopSlideAnimation({
    super.key,
    required this.isAnimatingIn,
    required this.context,
  });

  final bool isAnimatingIn;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          color: const Color(0xFFffad0f),
          height: isAnimatingIn ? MediaQuery.of(context).size.height / 2.5 : 0,
          duration: const Duration(milliseconds: 200),
        ),
        AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Image.asset("assets/top.png")),
      ],
    );
  }
}
