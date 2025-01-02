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
                      Row(
                        children: [
                          Expanded(
                            flex:2,
                            child: Text(
                              'Total Video Duration:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 4,),
                          Expanded(
                            flex:2,
                            child: Text(
                              '3:45',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex:2,
                            child: Text(
                              'Total Music Duration:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 4,),
                          Expanded(
                            flex: 2,
                            child: Text(
                            '3:45',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2, // Adjust flex values as needed
                            child: Text(
                              'Selected Music:',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: 3, // Adjust flex values as needed
                            child: Text(
                              selectedMusic.name, // Access selected music from provider
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis, // Ensures long text doesn't overflow
                            ),
                          ),
                        ],
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
