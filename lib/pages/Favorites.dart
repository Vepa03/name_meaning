import 'dart:async';
import 'package:flutter/material.dart';
import 'package:name_meaning/pages/model/TurkmenName.dart';

enum FavSortMode { az, za }

class Favorites extends StatefulWidget {
  final List<TurkmenName> items;
  /// Favori durumunu değiştirmek için opsiyonel callback.
  /// Örn: (item) => toggleLike(item)  (SharedPreferences güncelleyen fonksiyonun)
  final ValueChanged<TurkmenName>? onToggleLike;
  /// Boş durumda tüm isimlere gitmek için opsiyonel callback.
  final VoidCallback? onGoToAll;

  const Favorites({
    super.key,
    required this.items,
    this.onToggleLike,
    this.onGoToAll,
  });

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  FavSortMode _sortMode = FavSortMode.az;

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

  List<TurkmenName> get _favoritesVisible {
    // 1) Sadece favoriler
    Iterable<TurkmenName> list = widget.items.where((e) => e.isLiked);

    // 2) Arama (isim + anlam)
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((e) =>
          e.name.toLowerCase().contains(q) ||
          (e.meaning).toLowerCase().contains(q));
    }

    // 3) Sıralama
    final sorted = list.toList();
    int nameCompare(TurkmenName a, TurkmenName b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());

    switch (_sortMode) {
      case FavSortMode.az:
        sorted.sort(nameCompare);
        break;
      case FavSortMode.za:
        sorted.sort((a, b) => nameCompare(b, a));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritesVisible;

    // Üst kontrol barı
    Widget controls = Padding(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Gözle ...',
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
          PopupMenuButton<FavSortMode>(
            tooltip: 'Sırala',
            initialValue: _sortMode,
            onSelected: (mode) => setState(() => _sortMode = mode),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: FavSortMode.az,
                child: Row(
                  children: [Icon(Icons.sort_by_alpha, ), SizedBox(width: 8), Text('A → Z', )],
                ),
              ),
              PopupMenuItem(
                value: FavSortMode.za,
                child: Row(
                  children: [Icon(Icons.sort_by_alpha, ), SizedBox(width: 8), Text('Z → A',  )],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.sort, ),
            ),
          ),
        ],
      ),
    );

    if (favorites.isEmpty) {
      return Column(
        children: [
          controls,
          const SizedBox(height: 80),
          const Text("halanlarym boş"),
          const SizedBox(height: 12),
          if (widget.onGoToAll != null)
            FilledButton(
              onPressed: widget.onGoToAll,
              child: const Text('ähli atlara git'),
            ),
        ],
      );
    }

    return Column(
      children: [
        controls,
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(15.0),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = favorites[index];
              final likeButton = InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onToggleLike == null ? null : () => widget.onToggleLike!(item),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              );

              return ListTile(
                key: ValueKey(item.name),
                title: Text(item.name, ),
                trailing: widget.onToggleLike == null
                    ? Tooltip(message: 'Pasif (onToggleLike ekle)', child: likeButton)
                    : likeButton,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NameDetailPage(item: item)),
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
