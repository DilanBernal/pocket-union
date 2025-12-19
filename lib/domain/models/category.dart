import 'package:flutter/cupertino.dart';

class Category {
  final String id;
  String name;
  var icon;
  bool inCloud;

  Category(
      {required this.id,
      required this.name,
      required this.icon,
      required this.inCloud});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'inCloud': inCloud == true ? 1 : 0
    };
  }

  Icon get iconCode => Icon(IconData(
        icon,
        fontFamily: 'MaterialIcons'
      ));

  IconData get iconData => IconData(icon, fontFamily: 'MaterialIcons');
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
        id: map['id'],
        name: map['name'],
        icon: map['icon'],
        inCloud: map['inCloud'] == 1);
  }
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        inCloud: json['inCloud'] == 1);
  }
}
