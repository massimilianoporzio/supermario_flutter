import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:supermario_flutter/constants/sprite_sheets.dart';
import 'package:supermario_flutter/games/super_mario_bros_game.dart';

import 'constants/globals.dart';

final _superMarioBrosGame = SuperMarioBrosGame(); //unico!
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //load sprites
  await SpriteSheets.load();
  await FlameAudio.audioCache.loadAll([
    Globals.jumpSmallSFX,
    Globals.pauseSFX,
    Globals.bumpSFX,
    Globals.powerUpAppearsSFX,
    Globals.breakBlockSFX,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: GameWidget(game: _superMarioBrosGame));
  }
}
