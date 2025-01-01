class MusicModel {
  String name;
  String url;

  MusicModel({
    required this.name,
    required this.url,
  });

  // Convert MusicModel to a map (for saving to databases or storage)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
    };
  }

  // Convert a map to MusicModel (for loading from databases or storage)
  factory MusicModel.fromMap(Map<String, dynamic> map) {
    return MusicModel(
      name: map['name'],
      url: map['url'],
    );
  }
}
