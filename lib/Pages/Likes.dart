import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Likes extends StatefulWidget {
  const Likes({Key? key}) : super(key: key);

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFF1A2025),
          appBar: AppBar(
            titleSpacing: 0.0,
            backgroundColor: Color(0xFF1A2025),
            title: const Text('Mes Likes'),
          ),

          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'images/empty_likes.svg',
                ),
                SizedBox(height: 20),
                Text(
                  "Vous n'avez pas encore liké de contenu.",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10,),
                Text(
                  "Cliquez sur le coeur pour en rajouter.",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),

        ),
    );
  }
}
