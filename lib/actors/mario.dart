import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:supermario_flutter/constants/animation_configs.dart';
import 'package:supermario_flutter/constants/globals.dart';

enum MarioAnimationState {
  idle,
  walking,
  jumping,
}

class Mario extends SpriteAnimationGroupComponent<MarioAnimationState> {
  Mario({required Vector2 position, required Rectangle levelBounds})
      : super(
            position: position,
            size: Vector2(Globals.tileSize, Globals.tileSize),
            anchor: Anchor.topLeft) {
    debugMode = true;
    debugColor = const Color.fromARGB(255, 255, 128, 0);
  }

  @override
  FutureOr<void> onLoad() async {
    final SpriteAnimation idle = await AnimationConfigs.mario.idle();
    //setter per la map  di animazioni
    animations = {MarioAnimationState.idle: idle};
    current = MarioAnimationState
        .idle; //lo stato attuale è idle a cui corrisp l'animazione definta sopra
    return super.onLoad();
  }
}
