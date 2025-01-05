import 'dart:math';

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final double currentTime;
  final double totalDuration;
  final double start;
  final double end;

  // Fixed waveform values to create a static pattern
  final List<double> _waveformValues = [
    0.1, 0.7, 0.2, 0.6, 0.5, 0.8, 0.4, 0.3, 0.7, 0.1, // First wave
    0.5, 0.6, 0.4, 0.8, 0.2, 0.3, 0.7, 0.5, 0.4, 0.2, // Second wave
    0.8, 0.6, 0.3, 0.5, 0.7, 0.2, 0.4, 0.1, 0.6, 0.3, // Third wave
    0.4, 0.7, 0.1, 0.5, 0.6, 0.8, 0.3, 0.2, 0.7, 0.5, // Fourth wave
    0.3, 0.6, 0.8, 0.2, 0.4, 0.5, 0.7, 0.1, 0.3, 0.6, // Fifth wave
    0.2, 0.8, 0.5, 0.4, 0.3, 0.7, 0.1, 0.6, 0.2, 0.5, // Sixth wave
    0.4, 0.7, 0.3, 0.6, 0.8, 0.2, 0.5, 0.4, 0.7, 0.1, // Seventh wave
    0.6, 0.2, 0.8, 0.5, 0.3, 0.4, 0.7, 0.1, 0.6, 0.5, // Eighth wave
    0.3, 0.7, 0.4, 0.8, 0.2, 0.6, 0.5, 0.3, 0.7, 0.1, // Ninth wave
    0.4, 0.6, 0.8, 0.2, 0.5, 0.3, 0.7, 0.1, 0.6, 0.4, // Tenth wave
  ].expand((x) => [x, x]).take(100).toList();

  WaveformPainter({
    required this.currentTime,
    required this.totalDuration,
    required this.start,
    required this.end,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;

    final lineCount = 50; // Number of vertical lines
    final lineWidth = size.width / lineCount;
    final centerY = size.height / 2;

    // Draw the waveform using the fixed pattern
    for (int i = 0; i < lineCount; i++) {
      final x = i * lineWidth;

      // Use the pre-defined static height factor
      final amplitude = _waveformValues[i];

      // Calculate the height of the line
      final lineHeight = amplitude * size.height / 2;

      // Draw the waveform line
      canvas.drawLine(
        Offset(x, centerY - lineHeight),
        Offset(x, centerY + lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}