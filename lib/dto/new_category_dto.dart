import 'package:pocket_union/domain/enum/category_host.dart';

class NewCategoryDto {
  final String name;
  String? icon;
  String? shortDescription;
  String? color;
  CategoryHost host;

  NewCategoryDto({
    required this.name,
    required this.host,
    this.icon,
    this.shortDescription,
    this.color,
  });
}
