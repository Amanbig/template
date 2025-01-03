import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:template/components/waveform.dart';
import 'package:template/models/MusicModel.dart';
import 'package:template/models/music_provider.dart';

class AudioCropperPage extends ConsumerStatefulWidget {
  AudioCropperPage({super.key});

  @override
  ConsumerState<AudioCropperPage> createState() => _AudioCropperPageState();
}

class _AudioCropperPageState extends ConsumerState<AudioCropperPage> {
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
    final fileUri = Uri.file(
            ref.read(musicStateProvider).selectedMusic.url)
        .toString();

    // Preload the audio to get the duration
    await _audioPlayer.setSource(DeviceFileSource(fileUri));

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        totalDuration = d.inMilliseconds.toDouble() / 1000;
        end = min(totalDuration, end);
        _endController.text = _formatTime(end);
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      _currentTimeNotifier.value = p.inMilliseconds.toDouble() / 1000;
      currentTime = _currentTimeNotifier.value;

      if (_currentTimeNotifier.value >= end) {
        _audioPlayer.pause();
        setState(() => isPlaying = false);
        _audioPlayer.seek(Duration(milliseconds: (start * 1000).toInt()));
      }
    });

    // Fetch and set the total duration after preloading
    final duration = await _audioPlayer.getDuration();
    if (duration != null) {
      setState(() {
        totalDuration = duration.inMilliseconds.toDouble() / 1000;
        end = totalDuration;
        _startController.text = _formatTime(start);
        _endController.text = _formatTime(end);
      });
    }
  }

  void _cropAndSaveAudio() async {
    try {
      final musicState = ref.read(musicStateProvider.notifier);
      final selectedMusic = ref.read(musicStateProvider).selectedMusic;

      if (selectedMusic.url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio file selected')),
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/cropped_${timestamp}.mp3';

      // Ensure input file exists
      final inputFile = File(selectedMusic.url);
      if (!await inputFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Input file not found')),
        );
        return;
      }

      // Create FFmpeg command with escaped paths
      final command = '-i "${selectedMusic.url}" -ss $start -to $end -c copy "$outputPath"';

      await FFmpegKit.execute(command).then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          final outputFile = File(outputPath);
          if (await outputFile.exists()) {
            final bytes = await outputFile.readAsBytes();
            final base64String = base64Encode(bytes);

            final updatedMusic = MusicModel(
              name: selectedMusic.name.contains('(cropped)')
                  ? selectedMusic.name
                  : selectedMusic.name+'(cropped)', // Only append "(cropped)" if not already present
              url: outputPath,
              base64Data: base64String, // Include base64-encoded data
            );

            musicState.updateAudioPath(outputPath);
            musicState.updateSelectedMusic(updatedMusic);
            musicState.addMusic(updatedMusic);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Audio cropped successfully')),
            );

            Navigator.pop(context);
          } else {
            throw Exception('Output file not created');
          }
        } else {
          final logs = await session.getLogsAsString();
          throw Exception('FFmpeg failed: $logs');
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
      final fileUri = Uri.file(
              ref.read(musicStateProvider).selectedMusic.url)
          .toString();
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
    final musicState = ref.watch(musicStateProvider);
    final selectedMusic = musicState.selectedMusic;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Song Name: ${selectedMusic.name}',
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
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
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
                  currentTime: 0.0,
                  totalDuration: 100.0,
                  start: 0.0,
                  end: 100.0,
                ),
              ),
              _buildCropHandles(constraints.maxWidth),
              ValueListenableBuilder<double>(
                valueListenable: _currentTimeNotifier,
                builder: (context, currentTime, _) {
                  return Positioned(
                    left: (currentTime / totalDuration) * constraints.maxWidth,
                    child: Container(
                      width: 4,
                      height: 70,
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
            height: 70,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // Right-side overlay
        Positioned(
          right: 0,
          width: ((totalDuration - end) / totalDuration) * containerWidth,
          child: Container(
            height: 70,
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
              width: 8,
              height: 70,
              color: Colors.black,
            ),
          ),
        ),
        // End handle
        Positioned(
          left: ((end / totalDuration) * containerWidth) -
              5, // Subtract handle width
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
              width: 8,
              height: 70,
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
                  _buildTimeInput(
                      'Start', _startController, true, isSmallScreen),
                  _buildTimeInput('End', _endController, false, isSmallScreen),
                  if (!isSmallScreen)
                    _buildTimeDisplay('Duration', _formatTime(end - start)),
                  if (!isSmallScreen) _buildPlaybackControls(),
                ],
              ),
              const SizedBox(height: 10),
              if (isSmallScreen)
                _buildTimeDisplay('Duration', _formatTime(end - start)),
              const SizedBox(height: 10),
              if (isSmallScreen) _buildPlaybackControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeInput(String label, TextEditingController controller,
      bool isStart, bool isSmallScreen) {
    final double width =
        isSmallScreen ? 50 : 70; // Adjust width for smaller screens
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
                fontSize: 16,
              ),
            ),
            TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
              SizedBox(
                width: 4,
              ),
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
          onPressed: () => _cropAndSaveAudio(),
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

