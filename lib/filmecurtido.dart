class FilmeCurtido {
  final int id;
  final String imdbID;

  FilmeCurtido({required this.id, required this.imdbID});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imdbID': imdbID,
    };
  }

  factory FilmeCurtido.fromMap(Map<String, dynamic> map) {
    return FilmeCurtido(
      id: map['id'],
      imdbID: map['imdbID'],
    );
  }
}
