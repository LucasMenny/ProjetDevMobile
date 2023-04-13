import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projet_dev_v2/Pages/pageRecherche.dart';

import '../Pages/Detail_jeu_1.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}


Future<List<int>> getGameIds(String searchText) async {
  final response = await http.get(Uri.parse('https://steamcommunity.com/actions/SearchApps/$searchText'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final List<dynamic> games = json['results'];
    final List<int> gameIds = games.map((game) => int.parse(game['id'].toString())).toList();
    print(gameIds);
    return gameIds;
  } else {
    throw Exception('Failed to load game IDs');
  }
}


//Créé notre classe Game qui va contenir 1 jeu et ses informations.
class Game {
  final int id;
  final String name;
  final String imageUrl;
  final List<dynamic> publisher;
  final String price;

  Game({required this.id, required this.name, required this.publisher, required this.price,required this.imageUrl});
}


//Crée notre fetch qui va aller chercher les informations d'un jeu en fonction de son ID (Récupérée avant)
Future<List<Game>> fetchGames(List<int> gameIds) async {
  final List<Game> games = [];

  for (int id in gameIds) {
    //requête API
    final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$id'));

    if (response.statusCode == 200) {
      //On va aller dans la partie 'Data' de notre jeu
      final Map<String, dynamic>? jsonResponse = json.decode(response.body)[id.toString()]['data'];
      //Pour s'assurer que nos informations ne sont pas null (Au cas ou un jeu ait été retiré ou autre)
      if (jsonResponse != null) {
        //On récupère le nom
        final String name = jsonResponse['name'];
        //On récupère l'image
        final String imageUrl = jsonResponse['header_image'];
        //On récupère le créateur
        final List<dynamic> publisher = jsonResponse['publishers'];

        //On va venir se focaliser sur la partie 'Price' de 'Data' pour pouvoir récupérer le jeu
        final Map<String, dynamic>? jsonResponse2 = json.decode(response.body)[id.toString()]['data']['price_overview'];

        //On créé notre var Prix
        String price;
        //Si le jeu n'est pas gratuit (S'il est gratuit price_overview n'existe pas dans le code)
        if (jsonResponse2 != null) {
          //Si le prix du jeu est correctement renseigné
          if(jsonResponse2['initial_formatted'] != "")
          {
            //On récupère le prix initial (avant réduction)
            price = jsonResponse2['initial_formatted'];
          } else {
            //Sinon on récupère le prix final
            price = jsonResponse2['final_formatted'];
          }
        } else {
          //Sinon on le met gratuit
          price = "Gratuit";
        }

        //On envoie tout dans notre constructeur
        final Game game = Game(id: id, name: name, publisher: publisher, price : price,imageUrl: imageUrl);
        games.add(game);
      }
    } else {
      //Si ca ne fonctionne pas
      throw Exception('Echec du Fetch des informations des Jeux');
    }
  }
  //On renvoie la liste de nos jeux et de leurs informations
  return games;
}


Future<List<Game>> _loadGames(String searchText) async {
  final gameIds = await getGameIds(searchText);
  final games = await fetchGames(gameIds);
  print("Le premier id est: ${gameIds.first}");
  return games;
}


class _SearchBarState extends State<SearchBar> {
  Color searchIconColor = Colors.grey;
  List<Map<String, dynamic>> _gamesList = [];
  TextEditingController _textController = TextEditingController();
  List<dynamic> results = [];
  late Future<List<Game>> _futureGames;

  Future<void> _searchGames(String searchText) async {
    List<Game> games = await _loadGames(searchText);
    setState(() {
      _gamesList = games.cast<Map<String, dynamic>>().toList();
    });
  }


  @override
  void initState() {
    super.initState();
    //_futureGames = _loadGames(_textController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E262C),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Rechercher un jeu...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10.0),
              ),
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) {
              },
            ),
          ),
          GestureDetector(
            onTap: () async {
              // action à effectuer lorsque l'utilisateur appuie sur l'icône de recherche
              _loadGames(_textController.text);
            },
            child: Icon(
              Icons.search,
              color: Color(0xFF626AF6),
            ),
          ),
          SizedBox(width: 10.0),
        ],
      ),
    );

  }
}
