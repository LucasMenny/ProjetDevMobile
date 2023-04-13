import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projet_dev_v2/Pages/pageRecherche.dart';

import '../Pages/Detail_jeu_1.dart';

class SearchBar1 extends StatefulWidget {
  const SearchBar1({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar1> {
  Color searchIconColor = Colors.grey;
  bool _isSearchActivated = false;
  List<Map<String, dynamic>> _gamesList = [];
  TextEditingController _textController = TextEditingController();
  List<dynamic> results = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> searchForGame(String searchText) async {
    try {
      final url = Uri.parse(
          'https://steamcommunity.com/actions/SearchApps/$searchText');
      final response = await http.get(url);
      final responseData = json.decode(response.body);

      _gamesList.clear();
      for (var result in responseData) {
        if (result is Map<String, dynamic>) {
          Map<String, dynamic> game = {
            'id': result['appid'] is int ? result['appid'] : int.parse(
                result['appid'] as String),
            // modifier la valeur de 'id' en un entier
            'name': result['name'] as String?,
            'icon': result['icon'] as String? ?? '',
          };
          _gamesList.add(game);
        } else if (result is String) {
          int? appId = int.tryParse(result);
          if (appId != null) {
            Map<String, dynamic> game = {
              'id': appId,
              'name': '',
              'icon': '',
            };
            _gamesList.add(game);
          }
        }
      }
      setState(() {});
    } catch (error) {
      debugPrint(error.toString()); // imprimer l'erreur
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => searchPage()),
        );
      },
      child : PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un jeu...',
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF1E262C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: InkWell(
                    onTap: () async {
                      setState(() {
                        _isSearchActivated = !_isSearchActivated;
                      });
                      String searchText = _textController.text;
                      await searchForGame(searchText);
                    },
                    child: IconTheme(
                      data: IconThemeData(
                          color: _isSearchActivated ? Color(0xFF626AF6) : Colors
                              .grey),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              if (_isSearchActivated && _gamesList.isNotEmpty)
                Container(
                  color: Color(0xFF1A2025),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.6,
                  child: ListView.builder(
                    itemCount: _gamesList.length,
                    itemExtent: 60.0,
                    itemBuilder: (context, index) {
                      final id = _gamesList[index]['id'];
                      final icon = _gamesList[index]['icon'];
                      final name = _gamesList[index]['name'];
                      return GestureDetector(
                        onTap: () {
                          // action à effectuer lorsque le conteneur est cliqué
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detail_jeu_1(gameId: id),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 3.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A2025),
                            //border: Border.all(color: , width: 2.0),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                id != null && icon != null
                                    ? SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                      child: Image.network(icon),
                                )
                                    : SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                      child: Container(color: Colors.grey),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    name != null ? name : '',
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
