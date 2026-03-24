import 'package:flutter/material.dart';
import 'package:pocket_union/core/services/util/color_parser.dart';
import 'package:pocket_union/domain/models/category.dart';

IconData resolveTransactionIcon({
  required List<String> categoryIds,
  required Map<String, Category> categoryById,
}) {
  if (categoryIds.isEmpty) return Icons.attach_money;

  final firstCategory = categoryById[categoryIds.first];
  final iconCodePoint = int.tryParse(firstCategory?.icon ?? '');
  if (iconCodePoint == null) return Icons.attach_money;

  return IconData(iconCodePoint, fontFamily: 'MaterialIcons');
}

Color resolveTransactionColor({
  required List<String> categoryIds,
  required Map<String, Category> categoryById,
  required Color fallback,
}) {
  if (categoryIds.isEmpty) return fallback;

  final firstCategory = categoryById[categoryIds.first];
  return parseColorFromHex(firstCategory?.color, fallback: fallback);
}
