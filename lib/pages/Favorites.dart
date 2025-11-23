import 'dart:async';
import 'package:flutter/material.dart';
import 'package:name_meaning/pages/model/TurkmenName.dart';
import 'package:share_plus/share_plus.dart';

enum FavSortMode { az, za }

class Favorites extends StatefulWidget {
  final List<TurkmenName> items;
  /// Favori durumunu değiştirmek için callback.
  final ValueChanged<TurkmenName> onToggleLike;
  /// Boş durumda tüm isimlere gitmek için opsiyonel callback.
  final VoidCallback? onGoToAll;

  const Favorites({
    super.key,
    required this.items,
    required this.onToggleLike,  // ✅ artık guaranteed var
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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Temizle',
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear),
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
              const PopupMenuItem(
                value: FavSortMode.az,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('A → Z'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: FavSortMode.za,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Z → A'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sort),
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
                onTap: () => widget.onToggleLike(item), // ✅ direkt çağır
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              );

              return ListTile(
                key: ValueKey(item.name),
                title: Text(item.name),
                trailing: likeButton,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NameDetailPage(
                        item: item,
                        onToggleLike: widget.onToggleLike, // ✅ non-null
                        allItems: widget.items,
                      ),
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

// ------------------------------------------------------
// NameDetailPage
// ------------------------------------------------------

class NameDetailPage extends StatefulWidget {
  final TurkmenName item;
  final ValueChanged<TurkmenName> onToggleLike;
  final List<TurkmenName> allItems;

  const NameDetailPage({
    super.key,
    required this.item,
    required this.onToggleLike,
    required this.allItems,
  });

  @override
  State<NameDetailPage> createState() => _NameDetailPageState();
}

class _NameDetailPageState extends State<NameDetailPage> {
  late List<TurkmenName> _suggestions;

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  // 3 rastgele öneri üret
  void _generateSuggestions() {
    final others = widget.allItems
        .where((e) => e.name != widget.item.name)
        .toList();

    others.shuffle();
    _suggestions = others.take(3).toList();
  }

  void _shareName() {
    final text = '''
${widget.item.name} (${widget.item.gender})

${widget.item.meaning}

— Türkmen atlary sözlügi app
''';

    Share.share(
      text,
      subject: 'Isim manysy: ${widget.item.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          IconButton(
            tooltip: 'Paýlaş',
            icon: const Icon(Icons.ios_share),
            onPressed: _shareName,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          widget.item.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.item.isLiked ? Colors.red : null,
        ),
        onPressed: () {
          widget.onToggleLike(widget.item);
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// İsim + Cinsiyet
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(widget.item.name, style: theme.textTheme.titleLarge),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      widget.item.gender,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Anlam Kartı
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: const Color(0xFFE4E2E2),
                ),
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.item.meaning,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 🔥 Önerilen İsimler Başlığı
              Text(
                'Başgada:',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),

              /// 🔥 3 RASTGELE ÖNERİ
              Column(
                children: _suggestions.map((e) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0xFFE4E2E2),
                    ),
                    padding: const EdgeInsets.only(
                      top: 2.0,
                      bottom: 2.0,
                      left: 7.0,
                      right: 7.0,
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.name),
                      subtitle: Text(
                        e.meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NameDetailPage(
                              item: e,
                              onToggleLike: widget.onToggleLike,
                              allItems: widget.allItems,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
