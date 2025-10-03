import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:name_meaning/pages/model/TurkmenName.dart';

class Boys extends StatefulWidget {
  const Boys({super.key});

  @override
  State<Boys> createState() => _BoysState();
}

class _BoysState extends State<Boys> {
  List<TurkmenName> _items = [];

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final String response =
        await rootBundle.loadString('assets/data/boys.json');
    final List data = jsonDecode(response);
    setState(() {
      _items = data.map((e) => TurkmenName.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            trailing: const Icon(Icons.chevron_right),
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
        padding: const EdgeInsets.all(16.0),
        child: Text(
          item.meaning,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}

