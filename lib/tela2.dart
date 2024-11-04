import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/telafilme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appfilmes/movie.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'dart:convert';

void main() => runApp(minhaTela2());

class minhaTela2 extends StatelessWidget {
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
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Movie> listaFilmes = [];
  bool isLoading = false;
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
              .map((movie) => Movie.fromJson({
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
      decoration: BoxDecoration(
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
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pesquisa,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Pesquise um filme ou série...",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    fetchMovies(pesquisa.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: listaFilmes.length,
                    itemBuilder: (context, index) {
                      final movie = listaFilmes[index];
                      return Card(
                        color: Colors.transparent,
                        elevation: 0,
                        margin: EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
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
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${movie.titulo} (${movie.ano})",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
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
                                          child: Icon(Icons.line_style,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 16.0),
                                        TextButton(
                                          onPressed: () async {
                                            await DatabaseHelper()
                                                .addMovieToFavorites(
                                                    movie.imdbID);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      '${movie.titulo} adicionado aos favoritos!')),
                                            );
                                          },
                                          child: Icon(Icons.favorite_border,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 16.0),
                                        TextButton(
                                          onPressed: () {},
                                          child: Icon(Icons.visibility,
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
        ],
      ),
    );
  }
}
