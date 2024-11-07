import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/filme.dart';
import 'package:flutter_appfilmes/watchlist.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'package:flutter_appfilmes/telafilme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaWatchList extends StatefulWidget {
  const TelaWatchList({super.key});

  @override
  _TelaWatchListState createState() => _TelaWatchListState();
}

class _TelaWatchListState extends State<TelaWatchList> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Filme> watchListFilmes = [];
  bool _isLoading = true;

  Map<String, bool> filmesFavoritados = {};
  Map<String, bool> filmesWatchlist = {};

  @override
  void initState() {
    super.initState();
    _loadWatchList();
  }

  Future<void> verificarFavorito(String imdbID) async {
    filmesFavoritados[imdbID] = await DatabaseHelper().verificarFavorito(imdbID);
  }

  Future<void> verificarWatchList(String imdbID) async {
    filmesWatchlist[imdbID] = await DatabaseHelper().verificarWatch(imdbID);
  }

  Future<void> _loadWatchList() async {
    try {
      List<Watchlist> listaAssistir = await _databaseHelper.getWatchList();
      List<Filme> filmes = [];

      for (var filmeAssistir in listaAssistir) {
        final response = await http.get(
          Uri.parse('https://www.omdbapi.com/?i=${filmeAssistir.imdbID}&apikey=94a7ea1'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['Response'] == "True") {
            filmes.add(Filme.fromJson(data));
            await verificarFavorito(filmeAssistir.imdbID);
            await verificarWatchList(filmeAssistir.imdbID);
          }
        } else {
          throw Exception('Falha ao carregar o filme com ID: ${filmeAssistir.imdbID}');
        }
      }

      setState(() {
        watchListFilmes = filmes;
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
            : watchListFilmes.isEmpty
                ? const Center(child: Text('Nenhum filme favoritado encontrado.'))
                : ListView.builder(
                    itemCount: watchListFilmes.length,
                    itemBuilder: (context, index) {
                      final filme = watchListFilmes[index];
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
                                            if (filmesFavoritados[filme.imdbID] ?? false) {
                                              await DatabaseHelper()
                                                  .removerFilmeFavorito(filme.imdbID);
                                              setState(() {
                                                filmesFavoritados[filme.imdbID] = false;
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
                                                filmesFavoritados[filme.imdbID] = true;
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
                                            filmesFavoritados[filme.imdbID] ?? false
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        TextButton(
                                          onPressed: () async {
                                            if (filmesWatchlist[filme.imdbID] ?? false) {
                                              await DatabaseHelper()
                                                  .removerWatch(filme.imdbID);
                                              setState(() {
                                                filmesWatchlist[filme.imdbID] = false;
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
                                                filmesWatchlist[filme.imdbID] = true;
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
                                            filmesWatchlist[filme.imdbID] ?? false
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
