import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class InternetWarning extends StatelessWidget {
  const InternetWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(80)),
      ),
      child: const Row(
        children: [
          Icon(TablerIcons.wifi, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Conexión a internet requerida para este paso.',
              style: TextStyle(color: Colors.amber, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
