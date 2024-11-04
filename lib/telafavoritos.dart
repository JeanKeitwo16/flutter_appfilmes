import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/movie.dart';
import 'package:flutter_appfilmes/movieliked.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaFavoritos extends StatefulWidget {
  @override
  _TelaFavoritosState createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Movie> _favoriteMovies = [];
  bool _isLoading = true; // Variável para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  Future<void> _loadFavoriteMovies() async {
    try {
      List<MovieLiked> likedMovies = await _databaseHelper.getFavoriteMovies();
      List<Movie> movies = [];

      for (var likedMovie in likedMovies) {
        final response = await http.get(
          Uri.parse('https://www.omdbapi.com/?i=${likedMovie.imdbID}&apikey=94a7ea1'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['Response'] == "True") {
            movies.add(Movie.fromJson(data));
          }
        } else {
          throw Exception('Falha ao carregar o filme com ID: ${likedMovie.imdbID}');
        }
      }

      setState(() {
        _favoriteMovies = movies;
        _isLoading = false; // Atualiza o estado para indicar que o carregamento foi concluído
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Atualiza o estado mesmo em caso de erro
      });
      // Mostra um SnackBar ou alerta para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar filmes: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filmes Favoritados'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Exibe o indicador de carregamento
          : _favoriteMovies.isEmpty
              ? Center(child: Text('Nenhum filme favoritado encontrado.')) // Mensagem se não houver filmes
              : ListView.builder(
                  itemCount: _favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _favoriteMovies[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        leading: Image.network(movie.poster, width: 50),
                        title: Text(
                          movie.titulo,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(movie.ano),
                        onTap: () {
                          // Aqui você pode navegar para uma tela de detalhes se desejar
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
