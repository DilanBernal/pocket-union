import 'package:flutter/material.dart';

class ListMenu extends StatelessWidget {
  const ListMenu({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromRGBO(46, 0, 76, 0.75),
          ),
          child: Text(
            "Nuestras finanzas ❤️",
            style: TextStyle(
              fontSize: 27,
            ),
          ),
        ),
        // Opciones del menú
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () {
            // Cerrar el menú lateral
            Navigator.pop(context);
            // Navegar a la pantalla de inicio
            // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Configuración'),
          onTap: () {
            // Cerrar el menú lateral
            Navigator.pop(context);
            // Navegar a la pantalla de configuración
            // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
          },
        )
      ],
    );
  }
}
