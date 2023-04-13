import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Home.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

Future<bool> isEmailAlreadyInUse(String email) async {
  List<String> signInMethods =
  await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
  return signInMethods.isNotEmpty;
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegExp = RegExp(r"[a-z0-9\._-]+@[a-z0-9\._-]+[a-z]+");

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSecret = true;
  bool _isSecret2 = true;
  String e = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A2025),

      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: Color(0xFF1A2025),
        title: const Text('Inscription'),
        /*leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => {},
        ),*/
      ),

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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ///Affichage texte début///
                  Text(
                    'Inscription',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Text(
                    "Veuillez saisir ces différentes\ninformations, afin que vos\nlistes soient sauvegardées.",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.0,),
                  //////////////////////////////////////////////////////////////////
                  /// Formulaire///
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Nom d'utilisateur",
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: 'ex: JeanCulki',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color(0xFF1A2025), // Couleur de fond
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF636AF6)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Entrez un nom d'utilisateur";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10.0,),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: 'ex: Jean.Culki@edu.ece.fr',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color(0xFF1A2025), // Couleur de fond
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF636AF6)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || !emailRegExp.hasMatch(value)) {
                              return 'Entrez une adresse mail valide';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10.0,),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Color(0xFF1A2025), // Couleur de fond
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF636AF6)),
                            ),
                            suffixIcon: InkWell(
                              onTap: () => setState(() {
                                _isSecret = !_isSecret;
                              }),
                              child: Icon(
                                color: Color(0xFF636AF6),
                                !_isSecret
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: _isSecret,
                          validator: (value) {
                            if (value != null) {
                              if (value.length < 6) {
                                return "Votre mot de passe doit contenir au moins 6 caractères";
                              } else {
                                return null;
                              }
                            } else {
                              return "Votre mot de passe ne peut pas être vide";
                            }
                          },
                        ),

                        SizedBox(height: 10.0,),

                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Vérification mot de passe',
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Color(0xFF1A2025), // Couleur de fond
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF636AF6)),
                            ),
                            suffixIcon: InkWell(
                              onTap: () => setState(() {
                                _isSecret2 = !_isSecret2;
                              }),
                              child: Icon(
                                color: Color(0xFF636AF6),
                                !_isSecret2
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: _isSecret2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirmer votre mot de passe';
                            } else if (value != _passwordController.text) {
                              return 'Votre mot de passe doit être le même que précédemment';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 50.0),

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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool emailAlreadyInUse = await isEmailAlreadyInUse(_emailController.text);
                              if (emailAlreadyInUse) {
                                setState(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Cette email est déjà associé à un compte ! Veuillez vous connectez ou changer d'email."),
                                    ),
                                  );
                                });
                              }else{
                                try {
                                  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('An error occurred while signing up: $e'),
                                    ),
                                  );
                                  debugPrint(e.toString());
                                  debugPrint(FirebaseAuth.instance.tenantId);
                                }
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => Home()
                                    )
                                );
                              }
                            }
                          },
                          child: Text("S'inscrire"),
                        ),
                      ],
                    ),
                  ),
                  ////////////// Fin formulaire ////////////////////////////////////////
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
