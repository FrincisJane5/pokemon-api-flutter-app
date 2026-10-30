class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> abilities;
  final List<String> types;
  final String image;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.types,
    required this.image,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final abilitiesData = json['abilities'];
    final typesData = json['types'];
    final spritesData = json['sprites'];

    if (json['id'] is! int ||
        json['name'] is! String ||
        json['height'] is! int ||
        json['weight'] is! int ||
        abilitiesData is! List ||
        typesData is! List ||
        spritesData is! Map) {
      throw const FormatException('Unexpected Pokémon response structure.');
    }

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      abilities: abilitiesData.map((item) {
        if (item is! Map || item['ability'] is! Map) {
          throw const FormatException('Invalid ability information.');
        }
        return item['ability']['name'] as String;
      }).toList(),
      types: typesData.map((item) {
        if (item is! Map || item['type'] is! Map) {
          throw const FormatException('Invalid type information.');
        }
        return item['type']['name'] as String;
      }).toList(),
      image: (spritesData['other']?['official-artwork']?['front_default'] ??
              spritesData['front_default'] ??
              '') as String,
    );
  }
}
