import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/filme.dart';
import 'package:flutter_appfilmes/filmecurtido.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'package:flutter_appfilmes/telafilme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaFavoritos extends StatefulWidget {
  const TelaFavoritos({super.key});

  @override
  _TelaFavoritosState createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Filme> filmesFavoritos = [];
  bool _isLoading = true;
  bool favoritado = false;
  bool marcarAssistir = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  Future<void> verificarFavorito(String imdbID) async {
    favoritado = await DatabaseHelper().verificarFavorito(imdbID);
    setState(() {});
  }

  Future<void> verificarWatchList(String imdbID) async {
    marcarAssistir = await DatabaseHelper().verificarWatch(imdbID);
    setState(() {});
  }

  Future<void> _loadFavoriteMovies() async {
    try {
      List<FilmeCurtido> filmesCurtidos = await _databaseHelper.getFilmesFavoritos();
      List<Filme> filmes = [];

      for (var filmeCurtido in filmesCurtidos) {
        final resposta = await http.get(
          Uri.parse('https://www.omdbapi.com/?i=${filmeCurtido.imdbID}&apikey=94a7ea1'),
        );

        if (resposta.statusCode == 200) {
          final data = json.decode(resposta.body);
          if (data['Response'] == "True") {
            filmes.add(Filme.fromJson(data));
            await verificarFavorito(filmeCurtido.imdbID);
            await verificarWatchList(filmeCurtido.imdbID);
          }
        } else {
          throw Exception('Falha ao carregar o filme com ID: ${filmeCurtido.imdbID}');
        }
      }

      setState(() {
        filmesFavoritos = filmes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
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
            ? const Center(child: CircularProgressIndicator())
            : filmesFavoritos.isEmpty
                ? const Center(child: Text('Nenhum filme favoritado encontrado.'))
                : ListView.builder(
                    itemCount: filmesFavoritos.length,
                    itemBuilder: (context, index) {
                      final filme = filmesFavoritos[index];
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
                                              filme.poster,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    filme.poster,
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
                                        "${filme.titulo} (${filme.ano})",
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
                                                builder: (context) => TelaFilme(
                                                  imdbID: filme.imdbID,
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
                                            if (favoritado) {
                                              await DatabaseHelper()
                                                  .removerFilmeFavorito(
                                                      filme.imdbID);
                                              setState(() {
                                                favoritado = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${filme.titulo} removido dos favoritos!'),
                                                ),
                                              );
                                            } else {
                                              await DatabaseHelper()
                                                  .favoritarFilme(filme.imdbID);
                                              setState(() {
                                                favoritado = true;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${filme.titulo} adicionado aos favoritos!'),
                                                ),
                                              );
                                            }
                                          },
                                          child: Icon(
                                            favoritado
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        TextButton(
                                          onPressed: () async {
                                            if (marcarAssistir) {
                                              await DatabaseHelper()
                                                  .removerWatch(filme.imdbID);
                                              setState(() {
                                                marcarAssistir = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${filme.titulo} removido da WatchList!'),
                                                ),
                                              );
                                            } else {
                                              await DatabaseHelper()
                                                  .adicionarWatch(filme.imdbID);
                                              setState(() {
                                                marcarAssistir = true;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${filme.titulo} adicionado à WatchList!'),
                                                ),
                                              );
                                            }
                                          },
                                          child: Icon(
                                            marcarAssistir
                                                ? Icons.visibility
                                                : Icons.visibility_outlined,
                                            color: Colors.white,
                                          ),
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
