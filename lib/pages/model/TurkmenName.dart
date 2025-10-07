class TurkmenName {
  final String name;
  final String meaning;
  final String gender;
  bool isLiked;

  TurkmenName({required this.name, required this.meaning, required this.gender, this.isLiked = false});

  factory TurkmenName.fromJson(Map<String, dynamic> json) {
    return TurkmenName(
      name: json['name'] as String,
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
