import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameSearchBar extends StatefulWidget {
  @override
  _GameSearchBarState createState() => _GameSearchBarState();
}

class _GameSearchBarState extends State<GameSearchBar> {
  TextEditingController _searchTextController = TextEditingController();
  List<Game> _games = [];

  void _searchForGames(String searchText) async {
    try {
      final url = Uri.parse('https://steamcommunity.com/actions/SearchApps/$searchText');
      final response = await http.get(url);
      final responseData = json.decode(response.body);
      List<dynamic> results = responseData['results'];
      List<Game> games = [];
      for (var result in results) {
        Game game = Game(
          id: result['appid'] as int,
          name: result['title'] as String,
          iconUrl: 'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/apps/${result['appid']}/${result['img_logo_url']}.jpg',
        );
        games.add(game);
      }
      setState(() {
        _games = games;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchTextController,
            decoration: InputDecoration(
              hintText: 'Rechercher un jeu',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  String searchText = _searchTextController.text;
                  _searchForGames(searchText);
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
            itemCount: _games.length,
            itemBuilder: (context, index) {
              Game game = _games[index];
              return ListTile(
                leading: Image.network(game.iconUrl),
                title: Text(game.name),
                subtitle: Text(game.id.toString()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Game {
  final int id;
  final String name;
  final String iconUrl;

  Game({
    required this.id,
    required this.name,
    required this.iconUrl,
  });
}
