class TurkmenName {
  final String name;
  final String meaning;
  final String gender;
  bool isLiked;

  TurkmenName({required this.name, required this.meaning, required this.gender, this.isLiked = false});

  factory TurkmenName.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] ?? '';
    final formatted = rawName.isNotEmpty ? rawName[0].toUpperCase() + rawName.substring(1).toLowerCase() : rawName;
    return TurkmenName(
      name: formatted,
      meaning: json['meaning'] as String,
      gender: json['gender'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'meaning': meaning,
        'gender' : gender,
        'isliked': isLiked
      };
}
