import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/models/MusicModel.dart';

// Define the provider
final musicStateProvider = StateNotifierProvider<MusicState, MusicStateModel>((ref) {
  return MusicState();
});

// Immutable state model
class MusicStateModel {
  final List<MusicModel> musicList;
  final MusicModel selectedMusic;
  final bool isDropdownVisible;
  final String audioPath;

  MusicStateModel({
    required this.musicList,
    required this.selectedMusic,
    required this.isDropdownVisible,
    required this.audioPath,
  });

  // Copy with method for immutable state updates
  MusicStateModel copyWith({
    List<MusicModel>? musicList,
    MusicModel? selectedMusic,
    bool? isDropdownVisible,
    String? audioPath,
  }) {
    return MusicStateModel(
      musicList: musicList ?? this.musicList,
      selectedMusic: selectedMusic ?? this.selectedMusic,
      isDropdownVisible: isDropdownVisible ?? this.isDropdownVisible,
      audioPath: audioPath ?? this.audioPath,
    );
  }
}

// StateNotifier class to manage the state
class MusicState extends StateNotifier<MusicStateModel> {
  MusicState()
      : super(
          MusicStateModel(
            musicList: [
              MusicModel(name: 'Upload your own music', url: 'url_to_upload_music'),
              MusicModel(name: 'Music 1', url: 'url_to_music_1'),
              MusicModel(name: 'Music 2', url: 'url_to_music_2'),
              MusicModel(name: 'Music 3', url: 'url_to_music_3'),
              MusicModel(name: 'Music 4', url: 'url_to_music_4'),
              MusicModel(name: 'Music 5', url: 'url_to_music_5'),
            ],
            selectedMusic: MusicModel(name: 'Music 1', url: 'url_to_music_1'),
            isDropdownVisible: false,
            audioPath: '',
          ),
        );

  // Toggle dropdown visibility
  void toggleDropdownVisibility() {
    state = state.copyWith(
      isDropdownVisible: !state.isDropdownVisible,
    );
  }

  // Update selected music
  void updateSelectedMusic(MusicModel music) {
    state = state.copyWith(
      selectedMusic: music,
    );
  }

  // Update audio path
  void updateAudioPath(String path) {
    state = state.copyWith(
      audioPath: path,
    );
  }

  // Add new music
  void addMusic(MusicModel music) {
    // Check if the music is already in the list using the custom equality
    if (!state.musicList.contains(music)) {
      final updatedList = List<MusicModel>.from(state.musicList)..insert(1, music);
      state = state.copyWith(
        musicList: updatedList,
      );
    }
  }



  // Remove music
  void removeMusic(MusicModel music) {
    final updatedList = List<MusicModel>.from(state.musicList)..remove(music);
    state = state.copyWith(
      musicList: updatedList,
    );
  }
}
