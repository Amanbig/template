import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AudioCropperPage extends StatefulWidget {
  final String url;
  final String name;
  var setAudio;

  AudioCropperPage({super.key, required this.url, required this.name, required this.setAudio});

  @override
  State<AudioCropperPage> createState() => _AudioCropperPageState();
}

class _AudioCropperPageState extends State<AudioCropperPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<double> _currentTimeNotifier = ValueNotifier(0);
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool isPlaying = false;
  double currentTime = 0;
  double totalDuration = 1;
  double start = 0;
  double end = 300;
  bool isDraggingStart = false;
  bool isDraggingEnd = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _startController.text = _formatTime(start);
    _endController.text = _formatTime(end);
  }

  void _initAudioPlayer() async {
    _audioPlayer.onPositionChanged.listen((Duration p) {
      _currentTimeNotifier.value = p.inMilliseconds.toDouble() / 1000;
      currentTime = _currentTimeNotifier.value;

      if (_currentTimeNotifier.value >= end) {
        _audioPlayer.pause();
        setState(() => isPlaying = false);
        _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        totalDuration = d.inMilliseconds.toDouble() / 1000;
        end = min(totalDuration, end);
        _endController.text = _formatTime(end);
      });
    });
  }

  void _updateTimeFromText(bool isStart) {
    try {
      final text = isStart ? _startController.text : _endController.text;
      final timeValue = double.parse(text);

      setState(() {
        if (isStart) {
          start = timeValue.clamp(0, end - 1);
          _startController.text = _formatTime(start);
          if (isPlaying) {
            _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
          }
        } else {
          end = timeValue.clamp(start + 1, totalDuration);
          _endController.text = _formatTime(end);
        }
      });
    } catch (e) {
      if (isStart) {
        _startController.text = _formatTime(start);
      } else {
        _endController.text = _formatTime(end);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _currentTimeNotifier.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _playPauseMusic() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      final fileUri = Uri.file(widget.url).toString();
      await _audioPlayer.play(DeviceFileSource(fileUri));
      await _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
    }
    setState(() => isPlaying = !isPlaying);
  }

  String _formatTime(double time) {
    final seconds = time.toInt();
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Song Name: ${widget.name}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWaveformDisplay(),
                    const SizedBox(height: 10),
                    _buildTimeLabels(),
                    const SizedBox(height: 30),
                    _buildTimeControls(),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatTime(start),
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            _formatTime(end),
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformDisplay() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, 150),
                painter: WaveformPainter(
                  currentTime: _currentTimeNotifier.value,
                  totalDuration: totalDuration,
                  start: start,
                  end: end,
                ),
              ),
              _buildCropHandles(constraints.maxWidth),
              ValueListenableBuilder<double>(
                valueListenable: _currentTimeNotifier,
                builder: (context, currentTime, _) {
                  return Positioned(
                    left: (currentTime / totalDuration) * constraints.maxWidth,
                    child: Container(
                      width: 2,
                      height: 50,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildCropHandles(double containerWidth) {
    return Stack(
      children: [
        // Left-side overlay
        Positioned(
          left: 0,
          width: (start / totalDuration) * containerWidth,
          child: Container(
            height: 50,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // Right-side overlay
        Positioned(
          right: 0,
          width: ((totalDuration - end) / totalDuration) * containerWidth,
          child: Container(
            height: 50,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // Start handle
        Positioned(
          left: (start / totalDuration) * containerWidth,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newStart = start +
                    (details.primaryDelta! / containerWidth) * totalDuration;
                start = newStart.clamp(0, end - 1);
                _startController.text = _formatTime(start);
              });
            },
            child: Container(
              width: 5,
              height: 50,
              color: Colors.black,
            ),
          ),
        ),
        // End handle
        Positioned(
          left: ((end / totalDuration) * containerWidth) - 5,  // Subtract handle width
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newEnd = end +
                    (details.primaryDelta! / containerWidth) * totalDuration;
                end = newEnd.clamp(start + 1, totalDuration);
                _endController.text = _formatTime(end);
              });
            },
            child: Container(
              width: 5,
              height: 50,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 300;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTimeInput('Start', _startController, true, isSmallScreen),
                  _buildTimeInput('End', _endController, false, isSmallScreen),
                  if(!isSmallScreen)_buildTimeDisplay('Duration', _formatTime(end - start)),
                  if(!isSmallScreen)_buildPlaybackControls(),
                ],
              ),
              const SizedBox(height: 10),
              if(isSmallScreen)_buildTimeDisplay('Duration', _formatTime(end - start)),
              const SizedBox(height: 10),
              if(isSmallScreen)_buildPlaybackControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeInput(
      String label, TextEditingController controller, bool isStart, bool isSmallScreen) {
    final double width = isSmallScreen ? 50 : 70; // Adjust width for smaller screens
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$label:',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onSubmitted: (_) => _updateTimeFromText(isStart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _playPauseMusic,
          child: Row(
            children: [
              Icon(
                isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                size: 30,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(
                !isPlaying ? 'Play' : 'Pause',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 14,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            fixedSize: MaterialStateProperty.all(Size(250, 45)),
            maximumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3, 45)),
            side: MaterialStateProperty.all(
              BorderSide(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: Colors.grey[800]),
              SizedBox(width: 4,),
              Text('Back',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                  )),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
            fixedSize: MaterialStateProperty.all(Size(250, 45)),
            maximumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 3, 45)),
          ),
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double currentTime;
  final double totalDuration;
  final double start;
  final double end;

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
      ..strokeWidth = 2.5;

    final random = Random();
    final lineCount = 100; // Number of vertical lines (waveform resolution)
    final lineWidth = size.width / lineCount;
    final centerY = size.height / 2;

    for (int i = 0; i < lineCount; i++) {
      final x = i * lineWidth;

      // Generate a random "frequency" for the line (simulate waveform)
      final frequency = random.nextDouble() * 2 - 1; // Random value between -1 and 1

      // Calculate the height of the line based on frequency, but keep it centered
      final lineHeight = frequency * size.height / 2;

      // Draw the waveform line centered around the middle of the canvas
      canvas.drawLine(
        Offset(x, centerY - lineHeight), // Start point (above center)
        Offset(x, centerY + lineHeight), // End point (below center)
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
