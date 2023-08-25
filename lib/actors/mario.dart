import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_audio/flame_audio.dart';
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

  final Vector2 _up = Vector2(0, -1); //def se sto saltando

  static const double _minMoveSpeed = 125; //125 px ogni dt
  static const double _maxMoveSpeed = _minMoveSpeed + 100; //al massimo 100 in +
  double _currentSpeed = _minMoveSpeed;

  //stato di movimento
  bool isFacingRight = true;
  bool isOnGround = false; //parte dall'alto cadendo

  //raccolgo gli input
  int _hAxisInput = 0;
  bool _jumpInput = false; //all'inizio NON salta

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
    Gamepads.events.listen((GamepadEvent event) {
      // print(event.type);
      // print(event.key);
      //print("gamepadId" + event.gamepadId);
      // print("timestamp" + event.timestamp.toString());

      if (event.type == KeyType.analog) {
        _hAxisInput = 0;
        if (event.key == "dwXpos") {
          int increment = 0;
          if (event.value > 32767.0) {
            increment = 1;
          } else if (event.value < 32767.0) {
            increment = -1;
          } else {
            increment = 0;
          }
          _hAxisInput += increment;
        }
      }
      if (event.type == KeyType.button) {
        if (event.key == "button-0") {
          _jumpInput = event.value == 1.0;
        }
      }
    });

    // final gamepads = await Gamepads.list();
    // print('Gamepads' + gamepads.toString());
    final SpriteAnimation idle = await AnimationConfigs.mario.idle();
    final SpriteAnimation walking = await AnimationConfigs.mario.walking();
    final SpriteAnimation jumping = await AnimationConfigs.mario.jumping();

    //setter per la map  di animazioni
    animations = {
      MarioAnimationState.idle: idle,
      MarioAnimationState.walking: walking,
      MarioAnimationState.jumping: jumping,
    };
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

  void facingDirectionUpdate() {
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
    facingDirectionUpdate();
    jumpUpdate();
    marioAnimationUpdate();
  }

  void jumpUpdate() {
    if (_jumpInput && isOnGround) {
      jump();
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;

    //space bar for jumping
    _jumpInput = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void jump() {
    //cambio la velocity
    velocity.y -= _jumpSpeed; //punta verso l'altro per questo sottraggo
    isOnGround = false;

    //play audio
    FlameAudio.play(Globals.jumpSmallSFX);
  }

  void marioAnimationUpdate() {
    if (!isOnGround) {
      current = MarioAnimationState.jumping;
    } else if (_hAxisInput < 0 || _hAxisInput > 0) {
      current = MarioAnimationState.walking;
    } else if (_hAxisInput == 0) {
      current = MarioAnimationState.idle;
    }
  }

  //ogni dt la vel in y aum con gravity
  void velocityUpdate() {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpSpeed, 150); //ma se è troppa la clampo

    velocity.x = _hAxisInput * _currentSpeed;
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
    //se prodotto del versore up con la normale alla collisione > 0.9
    if (_up.dot(collisionNormal) > 0.9) {
      isOnGround = true;
    }
    position += collisionNormal.scaled(penetrationLength); //riscalato
  }
}
