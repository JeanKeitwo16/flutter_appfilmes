import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/telafilme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appfilmes/filme.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'dart:convert';

void main() => runApp(TelaPesquisa());

class TelaPesquisa extends StatelessWidget {
  const TelaPesquisa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MovieListScreen(),
      ),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Filme> listaFilmes = [];
  bool isLoading = false;
  
  Map<String, bool> filmesFavoritados = {};
  Map<String, bool> filmesWatchlist = {};

  TextEditingController pesquisa = TextEditingController();

  Future<void> verificarFavorito(String imdbID) async {
    filmesFavoritados[imdbID] = await DatabaseHelper().verificarFavorito(imdbID);
  }

  Future<void> verificarWatchList(String imdbID) async {
    filmesWatchlist[imdbID] = await DatabaseHelper().verificarWatch(imdbID);
  }

  Future<void> fetchMovies(String query) async {
    setState(() {
      isLoading = true;
    });

    final response = await http
        .get(Uri.parse('https://www.omdbapi.com/?s=$query&apikey=94a7ea1'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == "True") {
        setState(() {
          listaFilmes = (data['Search'] as List)
              .map((filme) => Filme.fromJson({
                    ...filme,
                    'Genre': filme['Genre'] ?? 'N/A',
                  }))
              .toList();
          isLoading = false;
        });
        for (var filme in listaFilmes) {
          await verificarFavorito(filme.imdbID);
          await verificarWatchList(filme.imdbID);
        }
      } else {
        setState(() {
          listaFilmes = [];
          isLoading = false;
        });
      }
    } else {
      throw Exception('Falha ao carregar filmes');
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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pesquisa,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Pesquise um filme ou série...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    fetchMovies(pesquisa.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: listaFilmes.length,
                    itemBuilder: (context, index) {
                      final filme = listaFilmes[index];
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
                                                  .removerFilmeFavorito(
                                                      filme.imdbID);
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
        ],
      ),
    );
  }
}
