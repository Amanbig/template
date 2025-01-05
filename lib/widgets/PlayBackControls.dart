import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  bool isPlaying;
  var playPauseMusic;
  
  PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.playPauseMusic,
  });

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
                  isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  key: ValueKey<bool>(isPlaying),
                  size: 32, // Ensure consistent size
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: 46, // Fixed width to avoid layout shifts
                  child: Text(
                    isPlaying ? 'Pause' : 'Play',
                    key: ValueKey<bool>(isPlaying),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
