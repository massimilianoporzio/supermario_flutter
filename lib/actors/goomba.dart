import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:supermario_flutter/actors/mario.dart';
import 'package:supermario_flutter/constants/animation_configs.dart';
import 'package:supermario_flutter/constants/globals.dart';
import 'package:supermario_flutter/games/super_mario_bros_game.dart';

class Goomba extends SpriteAnimationComponent
    with HasGameRef<SuperMarioBrosGame>, CollisionCallbacks {
  final double _speed = 50;
  Goomba({required Vector2 position})
      : super(
            position: position,
            size: Vector2.all(Globals.tileSize),
            anchor: Anchor.topCenter,
            animation: AnimationConfigs.goomba.walking()) {
    Vector2 targetPosition = position;
    targetPosition.x -=
        100; //dico ai goomba che la target pos è a sinistra di 100
    //poi faccio sequenza di avanti indietro
    final SequenceEffect effect = SequenceEffect(
      [
        MoveToEffect(targetPosition, EffectController(speed: _speed)),
        MoveToEffect(position, EffectController(speed: _speed)),
      ],
      alternate: true, //avanti e indietro a ripetizione
      infinite: true,
    );
    add(effect); //agg effetto ai goomba
    add(CircleHitbox());
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Mario) {
      if (!other.isOnGround) {
        other.jump(); //rimbalza!
        animation = AnimationConfigs.goomba.dead();
        position.y += 0.5; //lo schiaccio un po' verso il terreno
        //aspetto mezzo secondo
        await Future.delayed(const Duration(milliseconds: 500));
        //RIMUOVO il GOOMBA
        add(RemoveEffect());
      }
    }
  }
}
