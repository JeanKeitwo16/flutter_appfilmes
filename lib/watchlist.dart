class Watchlist {
  final int id;
  final String imdbID;

  Watchlist({required this.id, required this.imdbID});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imdbID': imdbID,
    };
  }

  factory Watchlist.fromMap(Map<String, dynamic> map) {
    return Watchlist(
      id: map['id'],
      imdbID: map['imdbID'],
    );
  }
}
