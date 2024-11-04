import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/telafilme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appfilmes/filme.dart';
import 'package:flutter_appfilmes/DatabaseHelper.dart';
import 'dart:convert';

class telaFilme extends StatefulWidget {
  final String imdbID;

  const telaFilme({super.key, required this.imdbID});

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
  bool favoritado = false;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
    verificarFavorito();
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

  Future<void> verificarFavorito() async {
    favoritado = await DatabaseHelper().verificarFavorito(widget.imdbID);
    setState(() {});
  }

   
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
),
  body: isLoading
      ? const Center(child: CircularProgressIndicator())
      : Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      poster,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Color.fromARGB(255, 56, 36, 80),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$titulo ($ano)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        genero,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          TextButton(
                                onPressed: () async {
                                  if (favoritado) {
                                    await DatabaseHelper().removerFilme(widget.imdbID);
                                    setState(() {
                                      favoritado = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${titulo} removido dos favoritos!'),
                                      ),
                                    );
                                  } else {
                                    await DatabaseHelper().favoritarFilme(widget.imdbID);
                                    setState(() {
                                      favoritado = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${titulo} adicionado aos favoritos!'),
                                      ),
                                    );
                                  }
                                },
                                child: Icon(
                                  favoritado ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.white,
                                ),
                              ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        "Sinopse:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        sinopse,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
);

  }
}