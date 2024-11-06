import 'package:flutter/material.dart';
import 'package:flutter_appfilmes/telapesquisa.dart';
import 'package:flutter_appfilmes/telafavoritos.dart';
import 'package:flutter_appfilmes/telawatchlist.dart';

void main() {
  runApp(const AppCustoViagem());
}

class AppCustoViagem extends StatefulWidget {
  const AppCustoViagem({super.key});

  @override
  State<AppCustoViagem> createState() => _AppCustoViagemState();
}

class _AppCustoViagemState extends State<AppCustoViagem> {
  int telaSelecionada = 1;

  void opcaoSelecionada(int opcao) {
    setState(() {
      telaSelecionada = opcao;
    });
  }

  @override
  Widget build(BuildContext context) {
     final List<Widget> listaTelas = <Widget>[
    TelaPesquisa(), TelaFavoritos(), TelaWatchList()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "App Custo Viagem",
      home: Scaffold(
        body: Center(child: listaTelas[telaSelecionada]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          fixedColor: const Color.fromARGB(255, 117, 116, 116),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
            backgroundColor: Color.fromARGB(255, 56, 36, 80),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
            backgroundColor: Color.fromARGB(255, 114, 81, 151),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Assistir',
            backgroundColor: Color.fromARGB(255, 130, 96, 172),
          ),
        ],
        currentIndex: telaSelecionada,
        onTap: opcaoSelecionada,
      ),
    )
    );
  }
}