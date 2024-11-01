import 'package:flutter/material.dart';

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

class MovieListScreen extends StatelessWidget {
  final List<Map<String, String>> movies = [
    {
      'title': 'Fight CLub',
      'year': '1999',
      'director': 'David Fincher',
      'image': 'https://via.placeholder.com/100x150'
    },
    {
      'title': 'Dune',
      'year': '1984',
      'director': 'David Lynch',
      'image': 'https://via.placeholder.com/100x150'
    },
    {
      'title': 'Goodfellas',
      'year': '1993',
      'director': 'Martin Scorsese',
      'image': 'https://via.placeholder.com/100x150'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 56, 36, 80)], // Define o degradê
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Card(
            color: Colors.transparent,
            elevation: 0,
            margin: EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.network(
                    movie['image']!,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${movie['title']} (${movie['year']})",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          "Diretor: ${movie['director']}",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            TextButton(onPressed: () {},child: Icon(Icons.favorite_border, color: Colors.white)),
                            SizedBox(width: 16.0),
                            TextButton(onPressed: () {},child: Icon(Icons.visibility, color: Colors.white)),
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
    );
  }
}
