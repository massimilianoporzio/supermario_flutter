import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:supermario_flutter/levels/level_component.dart';
import 'package:supermario_flutter/levels/level_option.dart';

class SuperMarioBrosGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late CameraComponent cameraComponent;
  final World world = World(); //contenitore di TUTTI gli oggetti
  LevelComponent? _currentLevel;
  @override
  FutureOr<void> onLoad() async {
    cameraComponent = CameraComponent(world: world)
          ..viewfinder.visibleGameSize =
              Vector2(450, 50) //VEDO QUELLA PARTE DI MAPPA
          ..viewfinder.position = Vector2(0, 0) //in quella posizione
          ..viewfinder.anchor =
              Anchor.topLeft //riferim della posi è alto a sin (0,0)
          ..viewport.position = Vector2(
              500, 0) //posiz della TELECAMERA (50 px + in là dell'inizio)
        ;

    addAll([world, cameraComponent]); //agg il tutto al GAME
    loadLevel(LevelOption.lv_1_1);
    return super.onLoad();
  }

  void loadLevel(LevelOption option) {
    //tolgo dal game e rimetto
    _currentLevel?.removeFromParent();
    _currentLevel = LevelComponent(option: option);
    add(_currentLevel!); //riaggiungo al game
  }
}
