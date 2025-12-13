class Exercise {
  final String name;
  final double weight;

  Exercise({
    required this.name,
    required this.weight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
    };
  }
}
