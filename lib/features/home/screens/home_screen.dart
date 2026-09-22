import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/features/home/controllers/home_controller.dart';
import 'package:pocket_union/features/home/screens/new_entry_screen.dart';
import 'package:pocket_union/features/home/widgets/list_menu.dart';

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
                child: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    final homeController = ref.watch(
                      homeControllerProvider.notifier,
                    );
                    final user = homeController.getActualUser();
                    final partnerUser = homeController.getActualPartnerUser();
                    final future = Future.wait([user, partnerUser]);

                    return Stack(
                      children: [
                        FutureBuilder(
                          future: future,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                snapshot.data?.first?.fullName ??
                                    'No user found',
                              );
                            }
                            return (snapshot.data?.first?.fullName != null)
                                ? Text(
                                    '$snapshot.data!.first!.fullName and ${snapshot.data!.last!.fullName}',
                                  )
                                : const Text('No user found');
                          },
                        ),
                        const Placeholder(),
                      ],
                    );
                  },
                ),
              ),
              2 => Expanded(child: Text('Agregar una salida')),
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
        elevation: 10,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            indexScreen = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(TablerIcons.circle_dashed_plus),
            activeIcon: Icon(TablerIcons.circle_plus_filled),
            label: 'Agregar una entrada',
          ),
          BottomNavigationBarItem(
            icon: Icon(TablerIcons.home),
            label: 'Inicio',
            activeIcon: Icon(TablerIcons.home_filled),
          ),
          BottomNavigationBarItem(
            icon: Icon(TablerIcons.circle_dashed_minus),
            activeIcon: Icon(TablerIcons.circle_minus),
            label: 'Agregar una salida',
          ),
        ],
      ),
    );
  }
}
