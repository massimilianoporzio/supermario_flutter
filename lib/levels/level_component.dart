// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:supermario_flutter/games/super_mario_bros_game.dart';
import 'package:supermario_flutter/levels/level_option.dart';

import '../constants/globals.dart';

class LevelComponent extends Component with HasGameRef<SuperMarioBrosGame> {
  final LevelOption option;
  late Rectangle _levelBounds; //rett che definisce il livello dentro una mappa
  LevelComponent({
    required this.option,
  }) : super();
  @override
  FutureOr<void> onLoad() async {
    TiledComponent level = await TiledComponent.load(
        Globals.lv_1_1, Vector2.all(Globals.tileSize));

    gameRef.add(level);
    _levelBounds = Rectangle.fromPoints(
        Vector2(0, 0),
        Vector2(level.tileMap.map.width.toDouble(),
            level.tileMap.map.height.toDouble()));
    return super.onLoad();
  }
}
