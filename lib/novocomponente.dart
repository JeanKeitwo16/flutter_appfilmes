import 'package:flutter_appfilmes/tela2.dart';
import 'package:flutter/material.dart';

class minhaTela1 extends StatefulWidget {
  const minhaTela1({super.key});

  @override
  State<minhaTela1> createState() => _tela1State();
}

class _tela1State extends State<minhaTela1> {
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
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(
            "https://static.vecteezy.com/system/resources/thumbnails/001/840/618/small/picture-profile-icon-male-icon-human-or-people-sign-and-symbol-free-vector.jpg",
          ),
        ),
        SizedBox(height: 10),
        Container(
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
              SizedBox(height: 10),
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
        SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              String usuario = usuarioController.text;
              String senha = senhaController.text;
              if (usuario == "Jean" && senha == "jean123") {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return minhaTela2();
                }));
              } else {
                final snackBar = SnackBar(backgroundColor: Color.fromARGB(255, 37, 136, 123),
                    content: const Text("Senha incorreta!"),
                    action: SnackBarAction(backgroundColor: Colors.white,
                      label: 'Undo',
                      onPressed: () {},
                    ));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Login", style: TextStyle(fontSize: 20.0))))
      ],
    ));
  }
}
