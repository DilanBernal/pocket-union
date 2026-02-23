import 'package:pocket_union/domain/enum/category_host.dart';

class NewCategoryDto {
  final String name;
  String? coupleId;
  String? icon;
  String? shortDescription;
  String? color;
  CategoryHost host;

  NewCategoryDto({
    required this.name,
    required this.host,
    this.coupleId,
    this.icon,
    this.shortDescription,
    this.color,
  });
}
