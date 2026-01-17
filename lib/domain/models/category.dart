import 'package:pocket_union/domain/enum/category_host.dart';

class Category {
  final String id;
  final String coupleId;
  String name;
  String? icon;
  String? shortDescription;
  String? color;
  final DateTime createdAt;
  final CategoryHost categoryHost;
  bool inCloud;

  Category({
    required this.id,
    required this.coupleId,
    required this.name,
    this.icon,
    this.shortDescription,
    this.color,
    required this.createdAt,
    required this.categoryHost,
    required this.inCloud,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'icon': icon,
      'short_description': shortDescription,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'category_host': categoryHost.value,
      'inCloud': inCloud ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      coupleId: map['couple_id'],
      name: map['name'],
      icon: map['icon'],
      shortDescription: map['short_description'],
      color: map['color'],
      createdAt: DateTime.parse(map['created_at']),
      categoryHost: CategoryHost.fromString(map['category_host']),
      inCloud: map['inCloud'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'icon': icon,
      'short_description': shortDescription,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'category_host': categoryHost.value,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      coupleId: json['couple_id'],
      name: json['name'],
      icon: json['icon'],
      shortDescription: json['short_description'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      categoryHost: CategoryHost.fromString(json['category_host']),
      inCloud: json['inCloud'] == 1,
    );
  }
}
