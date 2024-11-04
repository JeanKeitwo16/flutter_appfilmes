import 'package:flutter/material.dart';

class Movie {
  final String titulo;
  final String ano;
  final String poster;
  final String sinopse;
  final String imdbID;
  final String genero;

  Movie({required this.titulo, required this.ano, required this.poster, this.sinopse = "", required this.imdbID, required this.genero});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      titulo: json['Title'],
      ano: json['Year'],
      poster: json['Poster'],
      sinopse: json['Plot'] ?? "",
      imdbID: json['imdbID'],
      genero: json['Genre'],
    );
  }
}

