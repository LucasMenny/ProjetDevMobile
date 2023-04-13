import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WhishList extends StatefulWidget {
  const WhishList({Key? key}) : super(key: key);

  @override
  State<WhishList> createState() => _WhishListState();
}

class _WhishListState extends State<WhishList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1A2025),
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: Color(0xFF1A2025),
          title: const Text('WhishList'),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'images/empty_whishlist.svg',
              ),
              SizedBox(height: 20),
              Text(
                "Vous n'avez pas encore liké de contenu.",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10,),
              Text(
                "Cliquez sur l'étoile pour en rajouter.",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
