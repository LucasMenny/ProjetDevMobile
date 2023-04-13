import 'package:flutter/material.dart';
import '../Home.dart';

class GameCard extends StatefulWidget {
  final Game game;

  GameCard({required this.game, required name, required image, required price, required developer, required Null Function() onTap});

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(widget.game.id),
      child: Column(
        children: [
          Image.network(widget.game.imageUrl),
          ListTile(
            title: Text(widget.game.name),
            subtitle: Text(widget.game.publisher as String),
          ),
          Text(
            '\$${widget.game.price}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
