import 'package:pocket_union/domain/enum/category_host.dart';

class UpdateCategoryDto {
  final String id;
  final String? name;
  final String? icon;
  final String? shortDescription;
  final String? color;
  final CategoryHost? host;

  UpdateCategoryDto({
    required this.id,
    this.name,
    this.icon,
    this.shortDescription,
    this.color,
    this.host,
  });

  /// Convierte solo los campos no-nulos a un Map para SQLite update.
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (icon != null) map['icon'] = icon;
    if (shortDescription != null) map['short_description'] = shortDescription;
    if (color != null) map['color'] = color;
    if (host != null) map['category_host'] = host!.value;
    return map;
  }

  /// Convierte solo los campos no-nulos a un Map para Supabase update.
  Map<String, dynamic> toSupabaseMap() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (icon != null) map['icon'] = icon;
    if (shortDescription != null) map['short_description'] = shortDescription;
    if (color != null) map['color'] = color;
    if (host != null) map['category_host'] = host!.value;
    return map;
  }
}
