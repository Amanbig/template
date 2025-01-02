import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import provider
import 'package:template/components/drop_down.dart';
import 'package:template/components/home_page_buttons.dart';
// Import your MusicModel class
import 'package:template/models/music_provider.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the MusicState using ref.watch to get selected music and dropdown visibility
    final selectedMusic = ref.watch(musicStateProvider.select((state) => state.selectedMusic));
    final isDropdownVisible = ref.watch(musicStateProvider.select((state) => state.isDropdownVisible));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back,size: 32,),
                Text(
                  'Video Music Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Times New Roman',
                  ),
                ),
                SizedBox(
                  width: 22,
                ),
              ],
            ),
          ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 25,
                    children: [
                      Text(
                        'Total Video Duration: 3:45',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Total Music Duration: 3:45',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Selected Music: ${selectedMusic.name}',  // Access selected music from provider
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 23,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropDown(),
                ),
                // Conditionally display HomePageButtons based on dropdown visibility
                if(!isDropdownVisible)
                  HomePageButtons(
                        setAudio: (url) {
                          ref.read(musicStateProvider.notifier).updateAudioPath(url);  // Update audio path using the provider
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
