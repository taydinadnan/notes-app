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
          height: isAnimatingIn ? MediaQuery.of(context).size.height / 2 : 0,
          duration: const Duration(milliseconds: 100),
        ),
        AnimatedContainer(
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 100),
            child: RotatedBox(
              quarterTurns: 2,
              child: Image.asset(
                "assets/torn_paper.png",
                fit: BoxFit.fitWidth,
                color: const Color(0xFFffad0f),
                height:
                    isAnimatingIn ? MediaQuery.of(context).size.height / 5 : 0,
              ),
            )),
      ],
    );
  }
}
