//generica classe base per i blocchi
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:supermario_flutter/actors/mario.dart';
import 'package:supermario_flutter/constants/globals.dart';

class GameBlock extends SpriteAnimationComponent with CollisionCallbacks {
  late Vector2 _originalPos; //posiz orig poi sbalzato su e tornerà lì
  final double _gravity = 0.5;
  final double _hitDistance = 5; //di quanti si sposta quando colpito
  final bool shouldCrumble; //resta lì o si sbriciola?

  GameBlock({
    required Vector2 position,
    required SpriteAnimation animation,
    required this.shouldCrumble,
  }) : super(
            position: position,
            animation: animation,
            size: Vector2.all(Globals.tileSize)) {
    _originalPos = position;
    add(RectangleHitbox()
      ..collisionType =
          CollisionType.passive); //collis passiva (solo contro obj attivi)
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (y != _originalPos.y) {
      y += _gravity;
    }
  }

  //metodo quando Mario colpisce un blocco
  void hit() async {
    if (shouldCrumble) {
      await Future.delayed(const Duration(milliseconds: 250));
      add(RemoveEffect()); //rimuovo dopo 1/4 di s
    } else {
      //lo sposto in alto
      y -= _hitDistance;
      FlameAudio.play(Globals.bumpSFX);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Mario) {
      if (intersectionPoints.length == 2) {
        final Vector2 mid = ((intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2);
        //se Mario è qualche pix + su o giu del blocco ma sta salendo (vel neg)
        if ((mid.y > position.y + size.y - 4) &&
            (mid.y < position.y + 4) &&
            other.velocity.y < 0) {
          other.velocity.y = 0; // Mario smette di salire
          hit();
        }
        //in ogni caso faccio controlli sulla posizione di Mario
        other.platformPositionCheck(intersectionPoints);
      }
    }
  }
}
