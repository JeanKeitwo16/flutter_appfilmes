class MovieLiked {
  final int id;
  final String imdbID;

  MovieLiked({required this.id, required this.imdbID});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imdbID': imdbID,
    };
  }

  // Adicione este método para converter um Map em MovieLiked
  factory MovieLiked.fromMap(Map<String, dynamic> map) {
    return MovieLiked(
      id: map['id'],
      imdbID: map['imdbID'],
    );
  }
}
