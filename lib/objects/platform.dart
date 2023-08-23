import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends PositionComponent {
  Platform({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    debugMode = true;
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox()
      ..collisionType = CollisionType
          .passive); //coll se un hitbox active ci passa sopra (tra passive no)
    return super.onLoad();
  }
}
