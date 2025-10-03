import 'package:flutter/material.dart';
import 'package:name_meaning/pages/All.dart';
import 'package:name_meaning/pages/Favorites.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Turkmen Names"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(onPressed: (){

              }, icon: Icon(Icons.search_rounded))
            )
          ],
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: "All Names"),
              Tab(text: "Favorites",),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(child: All()),
            Center(child: Favorites()),
          ]),
      ),
    );
  }
}