import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/models/music_provider.dart';
import 'package:template/pages/crop_page.dart';

class HomePageButtons extends ConsumerWidget {
  final Function setAudio;

  HomePageButtons({
    super.key,
    required this.setAudio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access selected music from MusicState provider
    final selectedMusic =
        ref.watch(musicStateProvider.select((state) => state.selectedMusic));

    return Column(
      children: [
        // Crop Music Button
        Container(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Pass selected music data to AudioCropperPage
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AudioCropperPage(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note,
                  size: 32,
                  color: Colors.black,
                ),
                Text(
                  'Crop Music',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 84), // Adds space between the buttons

        // Save Video Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey[800]),
                    fixedSize: MaterialStateProperty.all(Size(300, 55)),
                  ),
                  child: Text(
                    'Save Video',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                SizedBox(height: 34), // Adds space between buttons

                // Save Button
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    fixedSize: MaterialStateProperty.all(Size(300, 55)),
                    side: MaterialStateProperty.all(
                      BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
