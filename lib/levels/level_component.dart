// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:supermario_flutter/actors/goomba.dart';

import 'package:supermario_flutter/games/super_mario_bros_game.dart';
import 'package:supermario_flutter/levels/level_option.dart';
import 'package:supermario_flutter/objects/platform.dart';

import '../actors/mario.dart';
import '../constants/globals.dart';

class LevelComponent extends Component with HasGameRef<SuperMarioBrosGame> {
  final LevelOption option;

  late Rectangle _levelBounds; //rett che definisce il livello dentro una mappa
  late Mario _mario; //Actor component che rappresenta il player

  LevelComponent({
    required this.option,
  }) : super();
  @override
  FutureOr<void> onLoad() async {
    TiledComponent level = await TiledComponent.load(
        option.pathName, Vector2.all(Globals.tileSize));

    gameRef.world.add(level);
    _levelBounds = Rectangle.fromPoints(
        Vector2(0, 0),
        Vector2(level.tileMap.map.width.toDouble(),
                level.tileMap.map.height.toDouble()) *
            Globals.tileSize);
    createPlatform(
        level.tileMap); //creo gli oggetti con cui posso avere collisioni
    createActors(level.tileMap);
    _setupCamera();
    return super.onLoad();
  }

  void _setupCamera() {
    gameRef.cameraComponent.follow(_mario, maxSpeed: 1000);
    gameRef.cameraComponent.setBounds(
        Rectangle.fromPoints(_levelBounds.topRight, _levelBounds.topLeft));
  }

  void createActors(RenderableTiledMap tiledMap) {
    //recupero il layer di oggetti (sul tiled l'ho chiamato 'Platforms')
    ObjectGroup? platformsLayer = tiledMap.getLayer<ObjectGroup>('Actors');
    if (platformsLayer == null) {
      throw Exception('Actors layer not found in the tiledMap');
    }
    //loop su ogni oggetto nel layer
    for (final TiledObject obj in platformsLayer.objects) {
      //creo un'istanza di tipo  actor a seconda del nome (nel file tmx)
      switch (obj.name) {
        case 'Mario':
          _mario =
              Mario(position: Vector2(obj.x, obj.y), levelBounds: _levelBounds);
          //la aggiungo al mondo tramite gameRef
          gameRef.world.add(_mario);
          break;
        case 'Goomba':
          Goomba goomba = Goomba(position: Vector2(obj.x, obj.y));
          gameRef.world.add(
              goomba); //sono TRE perché tre erano nella mappa con lo stesso nome
        default:
          break;
      }
    }
  }

  //crea un'istanza di ogni piattaforma che passiamo fornendone la tiledMap
  void createPlatform(RenderableTiledMap tiledMap) {
    //recupero il layer di oggetti (sul tiled l'ho chiamato 'Platforms')
    ObjectGroup? platformsLayer = tiledMap.getLayer<ObjectGroup>('Platforms');
    if (platformsLayer == null) {
      throw Exception('Platforms layer not found in the tiledMap');
    }
    //loop su ogni oggetto nel layer
    for (final TiledObject obj in platformsLayer.objects) {
      //creo un'istanza di tipo Platform
      final platform = Platform(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
      );
      //la aggiungo al mondo tramite gameRef
      gameRef.world.add(platform);
    }
  }
}
