class MiniMaxConfig {
  final String id;
  final String name;
  final String apiKey;
  final String model;

  MiniMaxConfig({
    required this.id,
    required this.name,
    required this.apiKey,
    this.model = 'MiniMax-M2.7',
  });

  factory MiniMaxConfig.fromJson(Map<String, dynamic> json) {
    return MiniMaxConfig(
      id: json['id'],
      name: json['name'],
      apiKey: json['apiKey'],
      model: json['model'] ?? 'MiniMax-M2.7',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'apiKey': apiKey,
      'model': model,
    };
  }

  MiniMaxConfig copyWith({
    String? id,
    String? name,
    String? apiKey,
    String? model,
  }) {
    return MiniMaxConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }
}
