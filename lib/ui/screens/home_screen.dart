import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/new_entry_screen.dart';
import 'package:pocket_union/ui/screens/new_out_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _actualPage = 0;

  final List<Widget> _screens = [NewEntryScreen(), NewOutScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Expanded(child: _screens[_actualPage])],
      )),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromRGBO(128, 128, 204, 1.0),
        unselectedItemColor: Color.fromRGBO(163, 0, 0, 1.0),
        onTap: (index) {
          setState(() {
            _actualPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Agregar una entrada'),
          BottomNavigationBarItem(
              icon: Icon(Icons.remove_circle_outline),
              label: 'Agregar una salida'),
        ],
      ),
    );
  }
}
