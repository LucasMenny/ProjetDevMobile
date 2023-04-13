import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_dev_v2/Composent/BarreDeRecherche.dart';
import 'package:projet_dev_v2/test2.dart';
import 'Composent/Carousel.dart';
import 'Composent/SearchBar.dart';
import 'Pages/Detail_jeu_1.dart';
import 'Pages/Likes.dart';
import 'Pages/WhishList.dart';
import 'Pages/pageRecherche.dart';

//permet de venir récupérer les IDs du top 100 des jeux sur Steam et les renvoient sous forme de tableau de int
Future<List<int>> getGameIds() async {
  //Requête API
  final response = await http.get(Uri.parse('https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> ranks = jsonResponse['response']['ranks'];
    final List<int> ids = ranks.map((rank) => rank['appid'] as int).toList();
    return ids;
  } else {
    throw Exception('Echec de la récuppération des Ids');
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

Future<List<String>> _fetchScreenshots(List<int> gameIds) async {
  final url = Uri.parse('https://store.steampowered.com/api/appdetails?appids=${gameIds}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    dynamic data = json.decode(response.body);
    if (data is Map<String, dynamic> && data.containsKey(gameIds.toString())) {
      dynamic gameData = data[gameIds.toString()]['data'];
      List<dynamic> screenshots = gameData['screenshots'] ?? [];
      return screenshots.map((screenshot) => screenshot['path_full']).toList().cast<String>();
    }
  }

  return []; // Add this line to return an empty list if the if conditions are not met
}

Future<List<String>> _getFirstScreenshot(List<int> gameIds) async {
  List<String> firstScreenshots = [];

  for (int id in gameIds) {
    List<String> screenshots = await _fetchScreenshots([id]);
    if (screenshots.isNotEmpty) {
      firstScreenshots.add(screenshots[0]);
    } else {
      firstScreenshots.add('');
    }
  }

  return firstScreenshots;
}

//Crée notre fetch qui va aller chercher les informations d'un jeu en fonction de son ID (Récupérée avant)
Future<List<Game>> fetchGames(List<int> gameIds) async {
  final List<Game> games = [];

  for (int id in gameIds) {
    //requête API
    final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$id&supported=french'));

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


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {

  List<CarouselItem> _carouselItems = [];

  late Future<List<Game>> _futureGames;

//Initialisation
  @override
  void initState() {
    super.initState();
    _futureGames = _loadGames();
  }

//On va venir charger les Ids des jeux, puis leurs informations
  Future<List<Game>> _loadGames() async {
    _carouselItems = [];
    final gameIds = await getGameIds();
    final games = await fetchGames(gameIds);

    if (games.isNotEmpty) {
      // Ajouter les images des 5 premiers jeux à la liste carouselItems
      for (int i = 0; i < 5; i++) {
        final game = games[i];
        final carouselItem = CarouselItem(
          imageUrl: game.imageUrl,
          title: game.name,
          description: game.publisher.join(', ') + '\n' + game.price,
          buttonText: 'En savoir plus',
        );
        _carouselItems.add(carouselItem);
      }
    }

    return games;
  }



//Affichage de l'interface
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1A2025),
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: Color(0xFF1A2025),
          title: const Text('Acceuil'),
          actions: [
            IconButton(
              icon: Icon(Icons.favorite_outline),
              onPressed: () { // Ajoutez le traitement pour le clic sur l'icône de coeur
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => Likes(),
                    )
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.star_outline),
              onPressed: () {
                // Ajoutez ici votre logique de traitement pour le clic sur l'icône d'étoile
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => WhishList(),
                    )
                );
              },
            ),
          ],
        ),

        //On vient afficher le reste de la page
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligner les enfants sur l'axe horizontal à gauche
              children: [
                SizedBox(height: 70),
                ImageCarousel(items: _carouselItems), // Utilisation de la classe ImageCarousel
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    'Les meilleures ventes',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 7),


                Expanded(
                  //La liste des jeux
                  child: FutureBuilder<List<Game>>(
                    future: _futureGames,
                    builder: (context, snapshot) {
                      //Si notre snapshot à de l'information concernant le jeu
                      if (snapshot.hasData) {
                        final games = snapshot.data!;
                        return ListView.builder(
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            //On vient créer une carte pour notre jeu
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Ajouter un bord arrondi
                              ),
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              // Ajouter une marge autour de la carte
                              child: Container(
                                height: 125,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(game.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFF1A2025).withOpacity(0.9),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ClipRRect(
                                          child: Image.network(
                                            game.imageUrl,
                                            height: 100, width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(17),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(game.name,
                                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white,overflow: TextOverflow.ellipsis,)
                                              ),
                                              SizedBox(height: 2),
                                              Text(game.publisher.first,
                                                  style: TextStyle(fontSize: 15, color: Colors.white,overflow: TextOverflow.ellipsis,)
                                              ),
                                              SizedBox(height: 9),
                                              Row(
                                                children: [
                                                  if (game.price != "Gratuit")
                                                    Text(
                                                      "Prix: ",
                                                      style: TextStyle(fontSize: 12, color: Colors.white, decoration: TextDecoration.underline,overflow: TextOverflow.ellipsis,),
                                                    ),
                                                  Text(
                                                      game.price,
                                                      style: TextStyle(
                                                        fontSize: 12, color: Colors.white,
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (_, __, ___) => Detail_jeu_1(gameId: game.id),
                                              )
                                          );
                                        },
                                        child: Container(
                                          height: double.infinity,
                                          width: 115,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF626AF6),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Text( "En savoir plus",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('${snapshot.error}'),
                        );
                      }
                      return Center(
                        //L'indicateur de Progrssion
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SearchBar1(),
            ),
          ],
        ),
      ),
    );
  }
}



