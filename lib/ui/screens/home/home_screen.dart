import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/home/widgets/start_hero_widget.dart';
import 'package:pocket_union/ui/screens/transactions/in/new_entry_screen.dart';
import 'package:pocket_union/ui/widgets/list_menu.dart';
import '../transactions/out/new_out_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int indexScreen = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(190, 0, 0, 0),
        elevation: 0,
      ),
      drawer: const Drawer(child: ListMenu()),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            switch (indexScreen) {
              0 => Expanded(child: NewEntryScreen()),
              1 => Expanded(
                child: StartHeroWidget(name1: "1", name2: "2"),
              ),
              2 => Expanded(child: NewOutScreen()),
              int() => throw UnimplementedError(),
            },
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: Color.fromRGBO(128, 128, 204, 1.0),
        unselectedItemColor: Color.fromRGBO(255, 17, 203, 1),
        currentIndex: indexScreen,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            indexScreen = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Agregar una entrada',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_circle_outline),
            activeIcon: Icon(Icons.remove_circle),
            label: 'Agregar una salida',
          ),
        ],
      ),
    );
  }
}
