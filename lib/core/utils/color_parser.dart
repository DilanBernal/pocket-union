import 'package:flutter/material.dart';

Color parseColorFromHex(String? value, {Color fallback = Colors.grey}) {
  if (value == null) return fallback;

  final sanitized = value.trim();
  if (sanitized.isEmpty) return fallback;

  final hex = sanitized.replaceFirst('#', '').replaceFirst('0x', '');

  if (hex.length != 6 && hex.length != 8) {
    return fallback;
  }

  final withAlpha = hex.length == 6 ? 'FF$hex' : hex;

  try {
    return Color(int.parse(withAlpha, radix: 16));
  } catch (_) {
    return fallback;
  }
}
