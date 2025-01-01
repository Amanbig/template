import 'package:flutter/material.dart';
import 'package:template/models/MusicModel.dart';

class MusicState with ChangeNotifier {
  // List of available music items
  List<MusicModel> _musicList = [
    MusicModel(name: 'Upload your own music', url: 'url_to_upload_music'),
    MusicModel(name: 'Music 1', url: 'url_to_music_1'),
    MusicModel(name: 'Music 2', url: 'url_to_music_2'),
    MusicModel(name: 'Music 3', url: 'url_to_music_3'),
    MusicModel(name: 'Music 4', url: 'url_to_music_4'),
    MusicModel(name: 'Music 5', url: 'url_to_music_5'),
  ];

  // Selected music item and dropdown visibility
  MusicModel _selectedMusic = MusicModel(name: 'Music 1', url: 'url_to_music_1');
  bool _isDropdownVisible = false;
  String _audioPath = '';

  // Getters for state variables
  List<MusicModel> get musicList => _musicList;
  MusicModel get selectedMusic => _selectedMusic;
  bool get isDropdownVisible => _isDropdownVisible;
  String get audioPath => _audioPath;

  // Method to toggle the visibility of the dropdown
  void toggleDropdownVisibility() {
    _isDropdownVisible = !_isDropdownVisible;
    notifyListeners(); // Notify listeners to rebuild
  }

  // Method to update selected music
  void updateSelectedMusic(MusicModel music) {
    _selectedMusic = music;
    notifyListeners(); // Notify listeners to rebuild
  }

  // Method to update the audio path (e.g., from file picker or cropping)
  void updateAudioPath(String path) {
    _audioPath = path;
    notifyListeners(); // Notify listeners to rebuild
  }

  // Method to add new music to the list
  void addMusic(MusicModel music) {
    _musicList.add(music);
    notifyListeners(); // Notify listeners to rebuild
  }

  // Method to remove music from the list
  void removeMusic(MusicModel music) {
    _musicList.remove(music);
    notifyListeners(); // Notify listeners to rebuild
  }
}
