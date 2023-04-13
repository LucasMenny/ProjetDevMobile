import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Detail_jeu_1 extends StatefulWidget {
  final int gameId;

  const Detail_jeu_1({Key? key, required this.gameId}) : super(key: key);

  @override
  State<Detail_jeu_1> createState() => _Detail_jeu_1State();
}

//Créé notre classe Game qui va contenir 1 jeu et ses informations.
class Game {
  final int id;
  final String name;
  final String imageUrl;
  final List<dynamic> publisher;
  final String price;
  final String desc;

  Game({required this.id, required this.name, required this.publisher, required this.price,required this.imageUrl, required this.desc});
}


Future<List<Game>> fetchGames(List<int> gameIds) async {
  final List<Game> games = [];

  for (int id in gameIds) {
    final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$id&supported=french'));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? jsonResponse = json.decode(response.body)[id.toString()]['data'];
      if (jsonResponse != null) {
        final String name = jsonResponse['name'];
        final String imageUrl = jsonResponse['header_image'];
        final List<dynamic> publisher = jsonResponse['publishers'];
        final String desc = jsonResponse['detailed_description'];

        final Map<String, dynamic>? jsonResponse2 = json.decode(response.body)[id.toString()]['data']['price_overview'];

        String price;

        if (jsonResponse2 != null) {
          if(jsonResponse2['initial_formatted'] != "")
          {
            price = jsonResponse2['initial_formatted'];
          } else {
            price = jsonResponse2['final_formatted'];
          }
        } else {
          price = "Gratuit";
        }
        final Game game = Game(id: id, name: name, publisher: publisher, price : price,imageUrl: imageUrl, desc: desc,);
        games.add(game);
      }
    } else {
      throw Exception('Echec du Fetch des informations des Jeux');
    }
  }
  return games;
}


class _Detail_jeu_1State extends State<Detail_jeu_1> {
  bool isFavorited = false;
  bool isLiked = false;
  int _selectedButton = 0;
  List<dynamic> _reviews = [];
  bool isDescLoaded = false;
  bool isReviewLoaded = false;
  String _description = '';
  String _imageUrl = '';
  String _name = '';
  String description = '';
  String? _firstScreenshotUrl;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Game>> _futureGames;
  bool showDescription = false;
  bool showReview = false;

  @override
  void initState() {
    super.initState();
    _futureGames = _loadGames();
    DefaultCacheManager().emptyCache(); // Ajouter cette ligne pour vider le cache
    _fetchFirstScreenshot();
    _fetchDatagame().then((_) {
      setState(() {
        // Mettre à jour la variable _name avec la valeur récupérée
        _name = _name.isNotEmpty ? _name : 'No name available';
      });
    });
    // Attendre 5 secondes avant de masquer l'indicateur de chargement
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchDatagame() async {
    final url = Uri.parse('https://store.steampowered.com/api/appdetails?appids=${widget.gameId}&supported=french');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey(widget.gameId.toString())) {
        dynamic gameData = data[widget.gameId.toString()]['data'];
        setState(() {
          _name = gameData['name'] ?? 'No name available';
        });
      }
    } else {
      throw Exception('Failed to fetch game data');
    }
  }


  //On va venir charger les Ids des jeux, puis leurs informations
  Future<List<Game>> _loadGames() async {
    List<int>gameId=[widget.gameId];
    final games = await fetchGames(gameId);
    return games;
  }

  Future<List<String>> _fetchScreenshots() async {
    final url = Uri.parse('https://store.steampowered.com/api/appdetails?appids=${widget.gameId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey(widget.gameId.toString())) {
        dynamic gameData = data[widget.gameId.toString()]['data'];
        List<dynamic> screenshots = gameData['screenshots'] ?? [];
        return screenshots.map((screenshot) => screenshot['path_full']).toList().cast<String>();
      }
    }

    return []; // Add this line to return an empty list if the if conditions are not met
  }

  Future<void> _fetchFirstScreenshot() async {
    final url = Uri.parse('https://store.steampowered.com/api/appdetails?appids=${widget.gameId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey(widget.gameId.toString())) {
        dynamic gameData = data[widget.gameId.toString()]['data'];
        List<dynamic> screenshots = gameData['screenshots'] ?? [];
        if (screenshots.isNotEmpty) {
          setState(() {
            _firstScreenshotUrl = screenshots.first['path_full'];
          });
        }
      }
    }
  }

  Future<void> _fetchDescription() async {
    final url = Uri.parse('https://store.steampowered.com/api/appdetails?appids=${widget.gameId}&supported=french');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey(widget.gameId.toString())) {
        dynamic gameData = data[widget.gameId.toString()]['data'];
        setState(() {
          _description = gameData['detailed_description'] ?? 'No description available';
          _imageUrl = gameData['header_image'] ?? '';
          isDescLoaded = true;
        });
      }
    } else {
      throw Exception('Failed to fetch game data');
    }
  }

  String removeHtmlTags(String htmlString) {
    htmlString = htmlString.replaceAll("<br>", "\n");
    htmlString = htmlString.replaceAll("&quot;", "\"");
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String newString = htmlString.replaceAll(exp, "");
    newString = newString.replaceAll("<br>", "\n");
    return newString;
  }


  Future<void> _fetchReviews() async {
    debugPrint("${widget.gameId}");
    final url = Uri.parse('https://store.steampowered.com/appreviews/${widget.gameId}?json=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('reviews')) {
        setState(() {
          _reviews = List<dynamic>.from(data['reviews']);
          isReviewLoaded = true;
        });
      }
    } else {
      throw Exception('Failed to fetch reviews');
    }
  }

  Future<List<dynamic>> getPlayerData() async {
    List<dynamic> playerDataList = [];

    for (var review in _reviews) {
      String? playerId = review['author']['steamid']?.toString();
      String url = 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=B59328D8532DFD75D31C1DB81F52007F&format=json&steamids=$playerId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var playerData = json.decode(response.body)['response']['players'][0];
        playerDataList.add(playerData);
      } else {
        throw Exception('Failed to load player data');
      }
    }

    return playerDataList;
  }

  Widget _buildReviewsWidget() {
    return FutureBuilder(
      future: getPlayerData(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            List<dynamic> playerDataList = snapshot.data!;

            return Expanded(
              child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (BuildContext context, int index) {
                  var review = _reviews[index];
                  var playerData = playerDataList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                      color: Color(0xFF1A2025).withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.network(
                                  playerData['avatar'] ?? '',
                                  height: 40.0,
                                  width: 40.0,
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    playerData['personaname'] ?? 'Auteur inconnu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              review['review']?.toString() ?? 'Aucun avis disponible',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.thumb_up, color: Colors.white),
                                SizedBox(width: 8.0),
                                Text(
                                  review['votes_up']?.toString() ?? 'Aucune note disponible',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(child: Text('Aucune donnée disponible'));
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1A2025),
        appBar: AppBar(
          titleSpacing: 0.0,
        backgroundColor: Color(0xFF1A2025),
          title: Text(_name),
          actions: [
            IconButton(
              icon: isFavorited ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_outline),
              onPressed: () {
                setState(() {
                  isFavorited = !isFavorited;
                });
              },
            ),
            IconButton(
              icon: isLiked ? Icon(Icons.star, color: Colors.yellowAccent) : Icon(Icons.star_outline),
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
              },
            ),
          ],
        ),
        body: _isLoading // check the value of isLoading to determine whether to show the indicator or the content
            ? Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            FutureBuilder<List<String>>(
              future: _fetchScreenshots(),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final List<String> screenshots = snapshot.data!;
                    return CarouselSlider.builder(
                      itemCount: screenshots.length,
                      itemBuilder: (BuildContext context, int index, int i) {
                        return CachedNetworkImage(
                          imageUrl: screenshots[index],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.cover,
                          height: 220,
                          width: double.infinity,
                        );
                      },
                      options: CarouselOptions(
                        height: 220,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                        enlargeCenterPage: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 7),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                }
                return const CircularProgressIndicator();
              },
            ),
            Column(
              children: [
                SizedBox(height: 200), // Hauteur de l'image
                Stack(
                  children: [
                    Container(
                      width: 380,
                      height: 130,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_firstScreenshotUrl!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      width: 380,
                      height: 130,
                      decoration: BoxDecoration(
                        color:  Color(0xFF1A2025).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              child: Image.network(
                                _imageUrl,
                                height: 100,
                                width: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Po',//'Publisher(s): ${_publisher.isNotEmpty ? _publisher.join(", ") : "No publisher available"}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),



                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            print("Name: $_name");
                            setState(() {
                              _selectedButton = 1;
                              if (!isDescLoaded) {
                                _fetchDescription();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: _selectedButton == 1 ? Color(0xFF626AF6) : Colors.grey,
                          ),
                          child: Text('DESCRIPTION'),
                        ),
                      ),
                    ),
                    SizedBox(width: 0), // Largeur nulle pour supprimer l'espace entre les deux boutons
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedButton = 2;
                              _fetchReviews();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: _selectedButton == 2 ? Color(0xFF626AF6) : Colors.grey,
                          ),
                          child: Text('AVIS'),
                        ),
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 10),

                if (_selectedButton == 1 || _selectedButton == 0)
                  Expanded(
                    child:Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xFF1A2025).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 2.0),
                      ),
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: SingleChildScrollView(
                        child: Text(
                          removeHtmlTags(_description),
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),



                if (_selectedButton == 2)
                  FutureBuilder(
                    future: getPlayerData(),
                    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          List<dynamic> playerDataList = snapshot.data!;

                          return Expanded(
                            child: ListView.builder(
                              itemCount: _reviews.length,
                              itemBuilder: (BuildContext context, int index) {
                                var review = _reviews[index];
                                var playerData = playerDataList[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Card(
                                    color: Color(0xFF1A2025).withOpacity(0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Image.network(
                                                playerData['avatar'] ?? '',
                                                height: 40.0,
                                                width: 40.0,
                                              ),
                                              SizedBox(width: 10.0),
                                              Expanded(
                                                child: Text(
                                                  playerData['personaname'] ?? 'Auteur inconnu',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            review['review']?.toString() ?? 'Aucun avis disponible',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Row(
                                            children: [
                                              Icon(Icons.thumb_up, color: Colors.white),
                                              SizedBox(width: 8.0),
                                              Text(
                                                review['votes_up']?.toString() ?? 'Aucune note disponible',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(child: Text('Aucune donnée disponible'));
                        }
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}