import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
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
  final double _gravity = 15.0; //(verso il basso positivo)
  final Vector2 velocity = Vector2.zero(); //fermo di default

  late Vector2 _minClamp;
  late Vector2 _maxClamp;

  Mario({required Vector2 position, required Rectangle levelBounds})
      : super(
            position: position,
            size: Vector2(Globals.tileSize, Globals.tileSize),
            anchor: Anchor.center) {
    debugMode = true;
    debugColor = const Color.fromARGB(255, 255, 128, 0);
    _minClamp =
        levelBounds.topLeft + (size / 2); //diviso 2 per no nfare uscire mario
    _maxClamp = levelBounds.bottomRight - (size / 2);
    add(CircleHitbox());
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    final SpriteAnimation idle = await AnimationConfigs.mario.idle();
    //setter per la map  di animazioni
    animations = {MarioAnimationState.idle: idle};
    current = MarioAnimationState
        .idle; //lo stato attuale è idle a cui corrisp l'animazione definta sopra
  }

  @override
  void update(double dt) {
    //refresh schermo
    super.update(dt);

    // if (dt > 0.05) {
    //   return; //non faccio nulla
    // }
    velocityUpdate();
    positionUpdate(dt);
  }

  //ogni dt la vel in y aum con gravity
  void velocityUpdate() {
    velocity.y += _gravity;
  }

  void positionUpdate(double dt) {
    Vector2 distance = velocity * dt;
    position += distance;

    position.clamp(_minClamp, _maxClamp); //costringo la posizione
  }
}
