import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Pages/Detail_jeu_1.dart';


class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}


class _SearchBarState extends State<SearchBar> {
  Color searchIconColor = Colors.grey;
  TextEditingController _textController = TextEditingController();
  List<dynamic> gamesList = [];
  List<int> gameIds = [];



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<List<String>> getGameIds(String searchText) async {
    final response = await http.get(Uri.parse('https://steamcommunity.com/actions/SearchApps/$searchText'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> games = json['results'];
      final List<String> gameIds = games.map((game) => game['id'].toString()).toList();
      return gameIds;
    } else {
      throw Exception('Failed to load game IDs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E262C),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Rechercher un jeu...',
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: searchIconColor,
                  ),
                  onPressed: () async {
                    List<String> ids = await getGameIds(_textController.text);
                    print(ids);
                    setState(() {
                      gameIds = ids.map((id) => int.parse(id)).toList();
                    });
                  },

                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: searchIconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _textController.clear();
                    });
                  },
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),

        ],
      ),
    );
  }
}
