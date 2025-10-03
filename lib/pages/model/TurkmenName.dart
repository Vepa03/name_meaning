class TurkmenName {
  final String name;
  final String meaning;

  TurkmenName({required this.name, required this.meaning});

  factory TurkmenName.fromJson(Map<String, dynamic> json) {
    return TurkmenName(
      name: json['name'] as String,
      meaning: json['meaning'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'meaning': meaning,
      };
}
