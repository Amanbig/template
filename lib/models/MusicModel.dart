class MusicModel {
  final String name;
  final String url;
  final String? base64Data; // Optional field to store base64-encoded data

  const MusicModel({
    required this.name,
    required this.url,
    this.base64Data, // Allow base64Data to be null if not provided
  });

  // Convert MusicModel to a map (include base64Data)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'base64Data': base64Data,
    };
  }

  // Create from map (handle base64Data)
  factory MusicModel.fromMap(Map<String, dynamic> map) {
    return MusicModel(
      name: map['name'] as String,
      url: map['url'] as String,
      base64Data: map['base64Data'] as String?, // Handle optional base64Data
    );
  }

  // Copy with method for immutable updates (support base64Data)
  MusicModel copyWith({
    String? name,
    String? url,
    String? base64Data,
  }) {
    return MusicModel(
      name: name ?? this.name,
      url: url ?? this.url,
      base64Data: base64Data ?? this.base64Data,
    );
  }

  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicModel && 
           other.name == name && 
           other.url == url &&
           other.base64Data == base64Data; // Include base64Data in equality check
  }

  @override
  int get hashCode => name.hashCode ^ url.hashCode ^ (base64Data?.hashCode ?? 0); // Include base64Data in hash

  // ToString for debugging (include base64Data if available)
  @override
  String toString() {
    return 'MusicModel(name: $name, url: $url, base64Data: $base64Data)';
  }
}
