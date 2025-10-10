import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:name_meaning/pages/model/TurkmenName.dart';

import 'package:name_meaning/pages/All.dart';        // All(items:..., onToggleLike:...)
import 'package:name_meaning/pages/Favorites.dart';  // Favorites(items:..., onToggleLike:...)

class MainPage extends StatefulWidget {
  
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  final List<TurkmenName> _items = [];
  Set<String> _likedNames = {};
  SharedPreferences? _prefs;
  bool _loading = true;
  

  

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    _prefs ??= await SharedPreferences.getInstance();
    _likedNames = (_prefs!.getStringList('liked_names') ?? []).toSet();

    final String response = await rootBundle.loadString('assets/data/names.json');
    final List data = jsonDecode(response);

    _items
      ..clear()
      ..addAll(data.map<TurkmenName>((e) {
        final item = TurkmenName.fromJson(e);
        item.isLiked = _likedNames.contains(item.name);
        return item;
      }));

    setState(() => _loading = false);
  }

  Future<void> _toggleLike(TurkmenName item) async {
    setState(() {
      item.isLiked = !item.isLiked;
      if (item.isLiked) {
        _likedNames.add(item.name);
      } else {
        _likedNames.remove(item.name);
      }
    });
    await _prefs!.setStringList('liked_names', _likedNames.toList());
  }

  @override
  Widget build(BuildContext context) {
    
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Türkmen atlar", style: TextStyle(fontFamily: "Lucky", fontSize: 25
          )),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: TextStyle( fontFamily: "Roboto"),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "ähli atlar"),
              Tab(text: "halanlarym"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // AYNI LİSTEYİ ve toggle fonksiyonunu veriyoruz
            All(items: _items, onToggleLike: _toggleLike),
            Favorites(items: _items, onToggleLike: _toggleLike),
          ],
        ),
      ),
    );
  }
}
