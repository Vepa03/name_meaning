// All.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:name_meaning/pages/model/TurkmenName.dart';

enum SortMode { az, za, favoritesFirst }

class All extends StatefulWidget {
  final List<TurkmenName> items;
  final ValueChanged<TurkmenName> onToggleLike;

  const All({
    super.key,
    required this.items,
    required this.onToggleLike,
  });

  @override
  State<All> createState() => _AllState();
}

class _AllState extends State<All> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _genderFilter = 'Tümü';
  SortMode _sortMode = SortMode.az;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = _searchCtrl.text.trim());
    });
  }

  List<TurkmenName> get _visibleItems {
    Iterable<TurkmenName> list = widget.items.where((e) {
      if (_genderFilter == 'Tümü') return true;
      final g = e.gender.toLowerCase();
      if (_genderFilter == 'Erkek') {
        return g.startsWith('e') || g.contains('erkek') || g.startsWith('m');
      }
      if (_genderFilter == 'Kadın') {
        return g.startsWith('k') || g.contains('kad') || g.startsWith('f');
      }
      return true;
    });

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((e) =>
          e.name.toLowerCase().contains(q) ||
          e.meaning.toLowerCase().contains(q));
    }

    final sorted = list.toList();
    int cmp(TurkmenName a, TurkmenName b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    switch (_sortMode) {
      case SortMode.az:
        sorted.sort(cmp);
        break;
      case SortMode.za:
        sorted.sort((a, b) => cmp(b, a));
        break;
      case SortMode.favoritesFirst:
        sorted.sort((a, b) {
          if (a.isLiked != b.isLiked) return a.isLiked ? -1 : 1;
          return cmp(a, b);
        });
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;

    return Column(
      children: [
        // Üst Kontroller
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Gözle...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Temizle',
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            icon: Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // (İstersen cinsiyet filtre dropdown’unu geri aç)
              const SizedBox(width: 8),
              PopupMenuButton<SortMode>(
                tooltip: 'Sırala',
                initialValue: _sortMode,
                onSelected: (mode) => setState(() => _sortMode = mode),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SortMode.az,
                    child: Row(
                      children: [Icon(Icons.sort_by_alpha), SizedBox(width: 8), Text('A → Z', )],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortMode.za,
                    child: Row(
                      children: [Icon(Icons.sort_by_alpha), SizedBox(width: 8), Text('Z → A', )],
                    ),
                  ),
                  PopupMenuItem(
                    value: SortMode.favoritesFirst,
                    child: Row(
                      children: [Icon(Icons.favorite, color: Colors.red, ), SizedBox(width: 8), Text('ilki halanlarym')],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sort),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Liste
        Expanded(
          child: items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('Tapylmady')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(15.0),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      key: ValueKey(item.name),
                      title: Text(item.name,),
                      trailing: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => widget.onToggleLike(item),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            item.isLiked ? Icons.favorite  : Icons.favorite_border,
                            color: item.isLiked ? Colors.red : null,
                          ),
                        ),
                      ),
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
        ),
      ],
    );
  }
}

class NameDetailPage extends StatelessWidget {
  final TurkmenName item;
  const NameDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(item.name, style: theme.textTheme.titleLarge),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    item.gender,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: const Color(0xFFE4E2E2),
              ),
              padding: const EdgeInsets.all(15.0),
              child: Text(
                item.meaning,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
