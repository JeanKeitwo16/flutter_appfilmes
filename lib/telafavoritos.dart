import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/filme.dart';
import 'package:flutter_appfilmes/filmecurtido.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'package:flutter_appfilmes/telafilme.dart';
import 'telafilme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaFavoritos extends StatefulWidget {
  const TelaFavoritos({super.key});

  @override
  _TelaFavoritosState createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Filme> _favoriteMovies = [];
  bool _isLoading = true; // Variável para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  Future<void> _loadFavoriteMovies() async {
    try {
      List<FilmeCurtido> likedMovies = await _databaseHelper.getFilmes();
      List<Filme> movies = [];

      for (var likedMovie in likedMovies) {
        final response = await http.get(
          Uri.parse('https://www.omdbapi.com/?i=${likedMovie.imdbID}&apikey=94a7ea1'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['Response'] == "True") {
            movies.add(Filme.fromJson(data));
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 56, 36, 80)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(backgroundColor: Colors.transparent,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) // Exibe o indicador de carregamento
            : _favoriteMovies.isEmpty
                ? const Center(child: Text('Nenhum filme favoritado encontrado.')) // Mensagem se não houver filmes
                : ListView.builder(
                    itemCount: _favoriteMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _favoriteMovies[index];
                      return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.network(
                                              movie.poster,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    movie.poster,
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${movie.titulo} (${movie.ano})",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => telaFilme(
                                                    imdbID: movie.imdbID,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(Icons.line_style,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(width: 16.0),
                                          TextButton(
                                            onPressed: () async {
                                              await DatabaseHelper()
                                                  .favoritarFilme(
                                                      movie.imdbID);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '${movie.titulo} adicionado aos favoritos!')),
                                              );
                                            },
                                            child: const Icon(Icons.favorite_border,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(width: 16.0),
                                          TextButton(
                                            onPressed: () {},
                                            child: const Icon(Icons.visibility,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                    },
                  ),
      ),
    );
  }
}
