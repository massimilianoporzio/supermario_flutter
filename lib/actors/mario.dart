import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';

import 'package:gamepads/gamepads.dart';
import 'package:supermario_flutter/constants/animation_configs.dart';
import 'package:supermario_flutter/constants/globals.dart';
import 'package:supermario_flutter/objects/platform.dart';

enum MarioAnimationState {
  idle,
  walking,
  jumping,
}

class Mario extends SpriteAnimationGroupComponent<MarioAnimationState>
    with CollisionCallbacks, KeyboardHandler {
  final double _gravity = 15.0; //(verso il basso positivo)
  final Vector2 velocity = Vector2.zero(); //fermo di default

  late Vector2 _minClamp;
  late Vector2 _maxClamp;

  static const double _minMoveSpeed = 125; //125 px ogni dt
  static const double _maxMoveSpeed = _minMoveSpeed + 100; //al massimo 100 in +
  double _currentSpeed = _minMoveSpeed;

  bool isFacingRight = true;
  //raccolgo gli input
  int _hAxisInput = 0;

  final _jumpSpeed = 400.0; //quanto può andare  veloce

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
    // Gamepads.events.listen((GamepadEvent event) {
    //   //print("gamepadId" + event.gamepadId);
    //   // print("timestamp" + event.timestamp.toString());
    //   _hAxisInput = 0;
    //   if (event.type == KeyType.analog) {
    //     if (event.key == "dwXpos") {
    //       _hAxisInput += event.value > 32767.0 ? 1 : 0;
    //     }
    //     if (event.key == "dwXpos") {
    //       _hAxisInput += event.value < 32767.0 ? -1 : 0;
    //     }
    //   }
    // });

    // final gamepads = await Gamepads.list();
    // print('Gamepads' + gamepads.toString());
    final SpriteAnimation idle = await AnimationConfigs.mario.idle();
    //setter per la map  di animazioni
    animations = {MarioAnimationState.idle: idle};
    current = MarioAnimationState
        .idle; //lo stato attuale è idle a cui corrisp l'animazione definta sopra
  }

  void speedUpdate() {
    if (_hAxisInput == 0) {
      _currentSpeed = _minMoveSpeed;
    } else {
      if (_currentSpeed <= _maxMoveSpeed) {
        _currentSpeed++; //aum vel
      }
    }
  }

  void facingDirection() {
    if (_hAxisInput > 0) {
      isFacingRight = true;
    } else {
      isFacingRight = false;
    }
    if (_hAxisInput > 0 && scale.x < 0 || _hAxisInput < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  void update(double dt) {
    //refresh schermo
    super.update(dt);

    if (dt > 0.05) {
      return; //non faccio nulla
    }

    velocityUpdate();
    positionUpdate(dt);
    speedUpdate();
    facingDirection();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;
    return super.onKeyEvent(event, keysPressed);
  }

  //ogni dt la vel in y aum con gravity
  void velocityUpdate() {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpSpeed, 150); //ma se è troppa la clampo

    velocity.x += _hAxisInput * _currentSpeed;
  }

  void positionUpdate(double dt) {
    Vector2 distance = velocity * dt;
    position += distance;
    //sui vettori clamp non rest nulla
    position.clamp(_minClamp, _maxClamp); //costringo la posizione
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform) {
      //2 point intersections
      if (intersectionPoints.length == 2) {
        platformPositionCheck(intersectionPoints);
      }
    }
  }

  void platformPositionCheck(Set<Vector2> intersectionPoints) {
    //middle point
    final Vector2 mid =
        (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
    final Vector2 collisionNormal = absoluteCenter - mid;
    double penetrationLength = (size.x / 2) - collisionNormal.length;
    collisionNormal.normalize(); //versore
    position += collisionNormal.scaled(penetrationLength); //riscalato
  }
}
