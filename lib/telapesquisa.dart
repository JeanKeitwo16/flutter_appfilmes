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
  bool favoritado = false;
  bool marcarAssistir = false;
  TextEditingController pesquisa = TextEditingController();

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
              .map((movie) => Filme.fromJson({
                    ...movie,
                    'Genre': movie['Genre'] ?? 'N/A',
                  }))
              .toList();
          isLoading = false;
        });
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
                      final movie = listaFilmes[index];
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
                                                builder: (context) => TelaFilme(
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
                                            if (favoritado) {
                                              await DatabaseHelper()
                                                  .removerFilmeFavorito(
                                                      movie.imdbID);
                                              setState(() {
                                                favoritado = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${movie.titulo} removido dos favoritos!'),
                                                ),
                                              );
                                            } else {
                                              await DatabaseHelper()
                                                  .favoritarFilme(movie.imdbID);
                                              setState(() {
                                                favoritado = true;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${movie.titulo} adicionado aos favoritos!'),
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
                                                  .removerWatch(movie.imdbID);
                                              setState(() {
                                                marcarAssistir = false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${movie.titulo} removido da WatchList!'),
                                                ),
                                              );
                                            } else {
                                              await DatabaseHelper()
                                                  .adicionarWatch(movie.imdbID);
                                              setState(() {
                                                marcarAssistir = true;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${movie.titulo} adicionado à WatchList!'),
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
        ],
      ),
    );
  }
}
