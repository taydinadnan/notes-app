import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';

class AnimatedBackGround extends StatefulWidget {
  const AnimatedBackGround({
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedBackGround> createState() => _AnimatedBackGroundState();
}

class _AnimatedBackGroundState extends State<AnimatedBackGround>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: AnimatedBackground(
        vsync: this,
        behaviour: RandomParticleBehaviour(
            options: const ParticleOptions(
              spawnOpacity: 0.0,
              opacityChangeRate: 0.25,
              minOpacity: 0.1,
              maxOpacity: 0.4,
              spawnMinSpeed: 30.0,
              spawnMaxSpeed: 70.0,
              spawnMinRadius: 7.0,
              spawnMaxRadius: 15.0,
              particleCount: 40,
            ),
            paint: particlePaint),
        child: const SizedBox(),
      ),
    );
  }

  var particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
}
