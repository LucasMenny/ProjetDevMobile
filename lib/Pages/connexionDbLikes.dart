//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
/*
class GamesInformation extends StatefulWidget {
  const GamesInformation({Key? key}) : super(key: key);

  @override
  State<GamesInformation> createState() => _GamesInformationState();
}*/
/*
class _GamesInformationState extends State<GamesInformation> {
  final Stream<QuerySnapshot> gameStream = FirebaseFirestore.instance
      .collection('Likes').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: gameStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        List movieList = snapshot.data!.docs.map((
            DocumentSnapshot document) {
          Map<String, dynamic> movie = document.data()! as Map<String, dynamic>;
          return ListTile(
            title: Text(gameStream['Id']),
          );
        }).toList();

        return ListView(
          children: movieList,
        );
      },
    );
  }
}*/