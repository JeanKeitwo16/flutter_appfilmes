
class Filme {
  final String titulo;
  final String ano;
  final String poster;
  final String sinopse;
  final String imdbID;
  final String genero;

  Filme({required this.titulo, required this.ano, required this.poster, this.sinopse = "", required this.imdbID, required this.genero});

  factory Filme.fromJson(Map<String, dynamic> json) {
    return Filme(
      titulo: json['Title'],
      ano: json['Year'],
      poster: json['Poster'],
      sinopse: json['Plot'] ?? "",
      imdbID: json['imdbID'],
      genero: json['Genre'],
    );
  }
}

