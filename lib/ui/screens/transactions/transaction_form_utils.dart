import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFormUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es requerido';
    }

    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Ingresa un monto válido mayor a 0';
    }
    return null;
  }

  static double parseAmount(String rawAmount) {
    return double.parse(rawAmount.trim());
  }

  static Future<DateTime?> pickTransactionDate(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      helpText: 'Selecciona una fecha',
    );
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
}
