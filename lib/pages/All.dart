import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:name_meaning/pages/model/TurkmenName.dart';

class All extends StatefulWidget {
  const All({super.key});

  @override
  State<All> createState() => _AllState();
}

class _AllState extends State<All> {
  List<TurkmenName> _items = [];
  Set<String> _likedNames = {};

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final String response =
        await rootBundle.loadString('assets/data/names.json');
    final List data = jsonDecode(response);
    setState(() {
      _items = data.map((e) => TurkmenName.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (_items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.name),
            trailing: GestureDetector(
              onTap: (){
                setState(() {
                  item.isLiked = !item.isLiked;
                });
              },
              child: Image.asset(item.isLiked? "assets/icons/like_red.png" : "assets/icons/like.png", width: width*0.065,)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NameDetailPage(item: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




class NameDetailPage extends StatelessWidget {
  final TurkmenName item;
  const NameDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(item.name, style: TextStyle(fontSize: 22, ),),
                SizedBox(width: 20.0,),
                Container(
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.black
                ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 4, bottom: 4),
                    child: Text(item.gender, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white )),
                  ))
              ],
            ),
            SizedBox(height: 15.0,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: const Color.fromARGB(255, 228, 226, 226) 
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(item.meaning, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
              ))
          ],
        ),
      )
    );
  }
}

