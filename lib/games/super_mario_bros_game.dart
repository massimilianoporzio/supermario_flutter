import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../constants/globals.dart';

class SuperMarioBrosGame extends FlameGame {
  late CameraComponent cameraComponent;
  final World world = World(); //contenitore di TUTTI gli oggetti
  @override
  FutureOr<void> onLoad() async {
    TiledComponent map = await TiledComponent.load(
        Globals.lv_1_1, Vector2.all(Globals.tileSize));

    world.add(map);
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
    return super.onLoad();
  }
}
