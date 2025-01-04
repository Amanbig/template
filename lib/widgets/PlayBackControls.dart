import 'package:flutter/material.dart';

class Playbackcontrols extends StatelessWidget {
  bool isPlaying = false;
  var playPauseMusic;
  Playbackcontrols({super.key, required this.isPlaying, required this.playPauseMusic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: playPauseMusic,
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  key: ValueKey<bool>(isPlaying),
                  size: 32, // Ensure consistent size
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  !isPlaying ? 'Play' : 'Pause',
                  key: ValueKey<bool>(isPlaying),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}