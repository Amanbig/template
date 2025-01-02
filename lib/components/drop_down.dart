import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:template/models/MusicModel.dart';
import 'package:template/models/music_provider.dart';

class DropDown extends ConsumerWidget {
  const DropDown({Key? key}) : super(key: key);

  String _generateRandomFileName() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomString = List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
    return 'audio_$randomString.mp3';
  }

  Future<void> _pickFile(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio, // Restrict to audio files
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        return;
      }

      final path = result.files.single.path!;
      debugPrint("Picked file path: $path");

      // Copy file to permanent location
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = result.files.single.name;
      final newPath = '${appDocDir.path}/$fileName';

      try {
        final pickedFile = File(path);
        final newFile = await pickedFile.copy(newPath);

        if (!newFile.existsSync()) {
          throw Exception('Failed to copy file');
        }

        final randomFileName = _generateRandomFileName();
        final newMusic = MusicModel(
          name:  fileName.endsWith('.mp3') ? fileName.substring(0, fileName.length - 4) : fileName, // Use original file name for better UX
          url: newPath,
        );

        // Update state using Riverpod
        final notifier = ref.read(musicStateProvider.notifier);
        notifier
          ..updateAudioPath(newPath)
          ..addMusic(newMusic)
          ..updateSelectedMusic(newMusic)
          ..toggleDropdownVisibility();
      } catch (e) {
        debugPrint('Error copying file: $e');
        // You might want to show an error message to the user here
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      // You might want to show an error message to the user here
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownButton(context, ref, musicState),
        if (musicState.isDropdownVisible)
          _buildDropdownList(context, ref, musicState),
      ],
    );
  }

  Widget _buildDropdownButton(BuildContext context, WidgetRef ref, MusicStateModel musicState) {
    return GestureDetector(
      onTap: () => ref.read(musicStateProvider.notifier).toggleDropdownVisibility(),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                musicState.selectedMusic.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Icon(
              musicState.isDropdownVisible 
                ? Icons.keyboard_arrow_up 
                : Icons.keyboard_arrow_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownList(BuildContext context, WidgetRef ref, MusicStateModel musicState) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 3,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 350,
        child: ListView.builder(
          itemCount: musicState.musicList.length,
          itemBuilder: (context, index) {
            final item = musicState.musicList[index];
            return TextButton(
              onPressed: () async {
                if (index == 0) {
                  await _pickFile(ref);
                } else {
                  ref.read(musicStateProvider.notifier)
                    ..updateSelectedMusic(item)
                    ..toggleDropdownVisibility();
                }
              },
              child: Row(
                children: [
                  Icon(
                    index == 0
                      ? Icons.file_upload_outlined
                      : Icons.play_circle_outlined,
                    color: Colors.black,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: index == 0 ? Colors.green : Colors.black,
                        fontSize: 18,
                        decoration: index == 0
                          ? TextDecoration.underline
                          : TextDecoration.none,
                        decorationColor:
                            index == 0 ? Colors.green : Colors.transparent,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
