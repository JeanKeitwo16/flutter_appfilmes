import 'package:flutter_appfilmes/telapesquisa.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _tela1State();
}

class _tela1State extends State<TelaLogin> {
  bool passwordVisible = false;
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(
            "https://static.vecteezy.com/system/resources/thumbnails/001/840/618/small/picture-profile-icon-male-icon-human-or-people-sign-and-symbol-free-vector.jpg",
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 320,
          child: Column(
            children: [
              TextField(
                controller: usuarioController,
                //TextFieldUsuario
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  labelText: 'Usuário',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: senhaController,
                obscureText: passwordVisible, //TextFieldUsuario
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              String usuario = usuarioController.text;
              String senha = senhaController.text;
              if (usuario == "Jean" && senha == "jean123") {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return TelaPesquisa();
                }));
              } else {
                final snackBar = SnackBar(backgroundColor: const Color.fromARGB(255, 37, 136, 123),
                    content: const Text("Senha incorreta!"),
                    action: SnackBarAction(backgroundColor: Colors.white,
                      label: 'Undo',
                      onPressed: () {},
                    ));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Login", style: TextStyle(fontSize: 20.0))))
      ],
    ));
  }
}
