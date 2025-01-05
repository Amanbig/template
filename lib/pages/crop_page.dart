import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:template/models/MusicModel.dart';
import 'package:template/models/music_provider.dart';

import 'package:template/widgets/waveform_painter.dart';
import 'package:template/widgets/PlayBackControls.dart';
import 'package:template/widgets/action_buttons.dart';
import 'package:template/widgets/time_display.dart';
import 'package:template/widgets/time_input.dart';
import 'package:template/widgets/time_labels.dart';

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
  double startDragX = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _startController.text = _formatTime(start);
    _endController.text = _formatTime(end);
  }

  void _initAudioPlayer() async {
    final fileUri =
        Uri.file(ref.read(musicStateProvider).selectedMusic.url).toString();

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
      final command = '-i "${selectedMusic.url.replaceAll('"', '\\"')}" -ss $start -to $end -c copy "$outputPath"';


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
                  : selectedMusic.name +
                      '(cropped)', // Only append "(cropped)" if not already present
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
      final fileUri =
          Uri.file(ref.read(musicStateProvider).selectedMusic.url).toString();
      await _audioPlayer.play(DeviceFileSource(fileUri));
      await _audioPlayer.seek(Duration(
          milliseconds:
              (!isDragging ? start * 1000 : startDragX >= currentTime?startDragX * 1000 : currentTime * 1000).toInt()));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
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
                    TimeLabels(
                      start: _formatTime(start),
                      end: _formatTime(end),
                    ),
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
                  // _buildActionButtons(),
                  ActionButtons(
                    cropAndSaveAudio: _cropAndSaveAudio,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformDisplay() {
    return GestureDetector(
      onTapDown: (details) {
        final tapPosition = details.localPosition.dx;
        final waveformWidth = context.size!.width - 32;
        final newTime = (tapPosition / waveformWidth) * totalDuration;
        setState(() {
          currentTime = newTime.clamp(0, totalDuration);
          _currentTimeNotifier.value = currentTime;
          startDragX = currentTime;
          isDragging = start <= startDragX && startDragX <= end;
          _audioPlayer
              .seek(Duration(milliseconds: (currentTime * 1000).toInt()));
        });
      },
      child: Container(
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
            final waveformWidth = constraints.maxWidth;
            return Stack(
              children: [
                CustomPaint(
                  size: Size(waveformWidth, 150),
                  painter: WaveformPainter(
                    currentTime: currentTime,
                    totalDuration: totalDuration,
                    start: start,
                    end: end,
                  ),
                ),
                _buildCropHandles(waveformWidth),
                ValueListenableBuilder<double>(
                  valueListenable: _currentTimeNotifier,
                  builder: (context, currentTime, _) {
                    final leftPosition =
                        (currentTime / totalDuration) * waveformWidth;
                    return Positioned(
                      left: leftPosition.clamp(
                          0, waveformWidth - 4), // Prevent overflow
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
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newStart = start +
                    (details.primaryDelta! / containerWidth) * totalDuration;
                start = newStart.clamp(0, end - 1);
                _startController.text = _formatTime(start);
                if(start>startDragX){
                  isDragging = false;
                }
              });
            },
            child: Container(
              width: 10,
              height: 70,
              color: Colors.black,
            ),
          ),
        ),
        // End handle
        Positioned(
          left: ((end / totalDuration) * containerWidth) -
              10, // Subtract handle width
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newEnd = end +
                    (details.primaryDelta! / containerWidth) * totalDuration;
                end = newEnd.clamp(start + 1, totalDuration);
                _endController.text = _formatTime(end);
                if(startDragX>end){
                  isDragging = false;
                }
              });
            },
            child: Container(
              width: 10,
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
                  TimeInput(
                      controller: _startController,
                      label: 'Start',
                      isStart: true,
                      isSmallScreen: isSmallScreen,
                      updateTimeFromText: _updateTimeFromText),
                  TimeInput(
                      controller: _endController,
                      label: 'End',
                      isStart: false,
                      isSmallScreen: isSmallScreen,
                      updateTimeFromText: _updateTimeFromText),
                  if (!isSmallScreen)
                    TimeDisplay(
                      label: 'Duration',
                      time: _formatTime(end - start),
                    ),
                  if (!isSmallScreen)
                    PlaybackControls(
                        isPlaying: isPlaying, playPauseMusic: _playPauseMusic),
                ],
              ),
              const SizedBox(height: 10),
              if (isSmallScreen)
                TimeDisplay(
                  label: 'Duration',
                  time: _formatTime(end - start),
                ),
              const SizedBox(height: 10),
              if (isSmallScreen)
                PlaybackControls(
                    isPlaying: isPlaying, playPauseMusic: _playPauseMusic)
            ],
          );
        },
      ),
    );
  }
}
