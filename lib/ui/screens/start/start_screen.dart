import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/start/widgets/background_image.dart';
import 'package:pocket_union/ui/screens/start/widgets/central_card.dart';
import 'package:pocket_union/ui/screens/start/widgets/enter_button.dart';
import 'package:pocket_union/ui/screens/start/widgets/gradient_overlay_background.dart';
import 'package:pocket_union/ui/screens/start/widgets/header.dart';
import 'package:pocket_union/ui/screens/start/widgets/subtititle.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          const GradientOverlay(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Header(),
                CentralCard(),
                Subtitle(),
                EnterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
