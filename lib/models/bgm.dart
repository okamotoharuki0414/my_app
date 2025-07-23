class Bgm {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String genre;
  final String imageUrl;
  final String? audioUrl; // 実際の音声ファイルURL

  Bgm({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.genre,
    required this.imageUrl,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'genre': genre,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  factory Bgm.fromJson(Map<String, dynamic> json) {
    return Bgm(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      duration: json['duration'] ?? '',
      genre: json['genre'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      audioUrl: json['audioUrl'],
    );
  }

  @override
  String toString() {
    return 'Bgm(id: $id, title: $title, artist: $artist, duration: $duration, genre: $genre)';
  }
}