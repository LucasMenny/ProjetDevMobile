import 'package:flutter/material.dart';
import '../Composent/SearchBar.dart';


class searchPage extends StatefulWidget {
  const searchPage({Key? key}) : super(key: key);

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF1A2025),
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: Color(0xFF1A2025),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Recherche'),
        ),

        body: Column(
          children : [
            SearchBar(),
          ],
        ),
      ),
    );
  }
}
