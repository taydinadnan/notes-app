import 'package:flutter/material.dart';

class BottomSlideAnimation extends StatelessWidget {
  const BottomSlideAnimation({
    super.key,
    required this.isAnimatingIn,
    required this.context,
  });

  final bool isAnimatingIn;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RotatedBox(
          quarterTurns: 0,
          child: Image.asset(
            "assets/torn_paper.png",
            width: MediaQuery.of(context).size.width,
            height: isAnimatingIn ? MediaQuery.of(context).size.height / 5 : 0,
            fit: BoxFit.fitWidth,
            color: const Color(0xFFffad0f),
          ),
        ),
        AnimatedContainer(
          color: const Color(0xFFffad0f),
          height: isAnimatingIn ? MediaQuery.of(context).size.height / 2 : 0,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
