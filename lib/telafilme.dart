import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class telaFilme extends StatefulWidget {
  final String imdbID;

  telaFilme({required this.imdbID});

  @override
  _telaFilmeState createState() => _telaFilmeState();
}

class _telaFilmeState extends State<telaFilme> {
  late String titulo;
  late String ano;
  late String poster;
  String sinopse = '';
  String genero = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    final response = await http.get(
      Uri.parse('https://www.omdbapi.com/?i=${widget.imdbID}&apikey=94a7ea1'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        titulo = data['Title'] ?? 'N/A';
        ano = data['Year'] ?? 'N/A';
        poster = data['Poster'] ?? '';
        genero = data['Genre'] ?? 'N/A';
        sinopse = data['Plot'] ?? 'Sinopse não carregada.';
        isLoading = false;
      });
    } else {
      setState(() {
        sinopse = 'Falha ao carregar a sinopse.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? 'Carregando...' : titulo,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromARGB(255, 56, 36, 80),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  poster,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        poster,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "$titulo ($ano)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          genero,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Icon(Icons.favorite_border, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Icon(Icons.visibility, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Sinopse:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    sinopse,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ],
              ),
            ),
    );
  }
}
