import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<Category> defaultCategories = [
    Category(
      id: 'alimentacao',
      name: 'Alimentação',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    Category(
      id: 'transporte',
      name: 'Transporte',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    Category(
      id: 'moradia',
      name: 'Moradia',
      icon: Icons.home,
      color: Colors.green,
    ),
    Category(
      id: 'saude',
      name: 'Saúde',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    Category(
      id: 'educacao',
      name: 'Educação',
      icon: Icons.school,
      color: Colors.purple,
    ),
    Category(
      id: 'lazer',
      name: 'Lazer',
      icon: Icons.movie,
      color: Colors.pink,
    ),
    Category(
      id: 'outros',
      name: 'Outros',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      // Convert normalized channel components (a, r, g, b in 0..1) to ARGB 32-bit int
      'color': (color.a * 255).round() << 24 |
          (color.r * 255).round() << 16 |
          (color.g * 255).round() << 8 |
          (color.b * 255).round(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color.fromARGB(
        (map['color'] >> 24) & 0xFF,
        (map['color'] >> 16) & 0xFF,
        (map['color'] >> 8) & 0xFF,
        map['color'] & 0xFF,
      ),
    );
  }
}
