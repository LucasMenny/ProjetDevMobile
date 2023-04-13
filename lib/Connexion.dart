import 'package:flutter/material.dart';
import 'package:projet_dev_v2/Home.dart';
import 'package:projet_dev_v2/Inscription.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Connexion extends StatefulWidget {
  const Connexion({Key? key}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}


class _ConnexionState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegExp = RegExp(r"[a-z0-9\._-]+@[a-z0-9\._-]+[a-z]+");
  String _email = '';
  String _password = '';
  bool _isSecret = true;

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('utilisateur authentifié avec succès'),
        ),
      );
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => Home()
          )
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucun utilisateur correspondant à cet email.'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mot de passe incorrect.'),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFF1A2025),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/FondPageConnexion.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
                 Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40.0,
                        ),

                        Text( 'Bienvenue!',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(
                          height: 20.0,
                        ),

                        Text("Veuillez vous connecter ou\ncréer un nouveau compte\npour utiliser l'application.",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(
                          height: 20.0,
                        ),

                        Form(
                            key: _formKey,

                            child: Column(

                              children: [
                                SizedBox(height: 10.0,),

                                TextFormField(
                                  onChanged: (value) => setState(() {
                                    _email = value; }),
                                  validator: (value) {
                                    if (value == null || !emailRegExp.hasMatch(value)) {
                                      return 'Entrez une adresse mail valide';
                                    }
                                    return null;
                                  },

                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: 'ex: Jean.Culki@edu.ece.fr',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Color(0xFF1A2025), // Couleur de fond
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF636AF6)),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20.0),

                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  onChanged: (value) => setState(() {
                                    _password = value; }),
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.length < 6) {
                                        return "Votre mot de passe doit contenir au moins 6 caractères";
                                      }
                                      else {
                                        return null ;
                                      }
                                    }
                                    else {
                                      return "Votre mot de passe ne peut pas être vide";
                                    }
                                  },
                                  obscureText: _isSecret,
                                  decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                      onTap: () =>
                                          setState(() {
                                            _isSecret = !_isSecret;}),
                                      child: Icon(
                                        color: Color(0xFF636AF6),
                                        !_isSecret
                                            ?Icons.visibility
                                            :Icons.visibility_off,
                                      ),
                                    ),
                                    labelText: 'Mot de passe',
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintText: 'ex: LaPiniouffe91',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Color(0xFF1A2025), // Couleur de fond
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF636AF6)),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 60.0),

                                ElevatedButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                        horizontal: 140.0,
                                        vertical: 15.0,
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(Color(0xFF636AF6)),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _signInWithEmailAndPassword();
                                    }
                                  },
                                  child: Text('Se connecter'),
                                ),

                                SizedBox(
                                  height: 20.0,
                                ),

                                ElevatedButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                        horizontal: 100.0,
                                        vertical: 15.0,
                                      ),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(Color(0xFF1A2025)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                        side: BorderSide(color: Color(0xFF636AF6), width: 2.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            pageBuilder: (_, __, ___) => SignupPage()
                                        )
                                    );
                                  },
                                  child: Text('Créer un nouveau compte'),
                                ),


                                SizedBox(
                                  height: 170.0,
                                ),

                                Text('Mot de passe oublié',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),

            ],
          ),
        ),
    );
  }
}