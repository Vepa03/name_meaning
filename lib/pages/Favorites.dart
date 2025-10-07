import 'package:flutter/material.dart';
import 'package:name_meaning/pages/model/TurkmenName.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Favorites"),
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
