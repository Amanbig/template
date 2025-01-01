import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:template/models/MusicModel.dart';
import 'package:template/models/music_provider.dart';

class DropDown extends StatelessWidget {
  const DropDown({Key? key}) : super(key: key);

  // Method to pick a file and update the audio path
  Future<void> pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      String? path = result.files.single.path;
      if (path != null) {
        // Log the original path
        print("Picked file path: $path");

        // Copy the file to a permanent location
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String newPath = '${appDocDir.path}/${result.files.single.name}';
        File pickedFile = File(path);
        File newFile = await pickedFile.copy(newPath);

        // Update the path in the MusicState provider
        context.read<MusicState>().updateAudioPath(newPath);

        // Add the new music dynamically to the list
        MusicModel newMusic = MusicModel(name: 'New Audio', url: newPath);
        context.read<MusicState>().addMusic(newMusic);

        // Update selected music to the new one
        context.read<MusicState>().updateSelectedMusic(newMusic);
        context.read<MusicState>().toggleDropdownVisibility();  // Close dropdown after file pick
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<MusicState>(
      builder: (context, musicState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                musicState.toggleDropdownVisibility();
              },
              child: Container(
                width: double.infinity,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(musicState.selectedMusic.name),
              ),
            ),
            Visibility(
              visible: musicState.isDropdownVisible,
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: SizedBox(
                  height: 250, // Limit the height of the dropdown
                  child: ListView.builder(
                    itemCount: musicState.musicList.length,
                    itemBuilder: (context, index) {
                      final MusicModel item = musicState.musicList[index];
                      return TextButton(
                        onPressed: () async {
                          if (index == 0) {
                            await pickFile(context); // If it's the "Upload your own music", open file picker
                          } else {
                            musicState.updateSelectedMusic(item); // Update selected music
                          }
                          musicState.toggleDropdownVisibility(); // Close dropdown
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              index == 0
                                  ? const Icon(Icons.upload)
                                  : const Icon(Icons.play_circle_outlined),
                              const SizedBox(width: 8),
                              Text(
                                item.name,
                                style: TextStyle(
                                  color: index == 0 ? Colors.green : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
