import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/features/home/controllers/home_controller.dart';
import 'package:pocket_union/features/home/screens/new_expense_screen.dart';
import 'package:pocket_union/features/home/screens/new_income_screen.dart';
import 'package:pocket_union/features/home/widgets/balance_card.dart';
import 'package:pocket_union/features/home/widgets/couple_header.dart';
import 'package:pocket_union/features/home/widgets/empty_transactions.dart';
import 'package:pocket_union/features/home/widgets/list_menu.dart';
import 'package:pocket_union/features/home/widgets/transaction_tile.dart';

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
              0 => Expanded(child: NewIncomeScreen()),
              1 => Expanded(
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                        final dashboardAsync = ref.watch(homeDashboardProvider);
                        return dashboardAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No se pudo cargar el resumen financiero.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          data: (dashboard) => RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(homeDashboardProvider);
                              await ref.read(homeDashboardProvider.future);
                            },
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                24,
                              ),
                              children: [
                                CoupleHeader(
                                  userName: dashboard.user?.fullName,
                                  partnerName: dashboard.partner?.fullName,
                                  userAvatarUrl: dashboard.user?.avatarUrl,
                                  partnerAvatarUrl:
                                      dashboard.partner?.avatarUrl,
                                ),
                                const SizedBox(height: 16),
                                BalanceCard(
                                  personalBalance:
                                      dashboard.personalBalance.balance,
                                  coupleBalance:
                                      dashboard.coupleBalance.balance,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Ultimas transacciones',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (dashboard.recentTransactions.isEmpty)
                                  const EmptyTransactions()
                                else
                                  ...dashboard.recentTransactions.map(
                                    (transaction) => TransactionTile(
                                      transaction: transaction,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                ),
              ),
              2 => Expanded(child: NewExpenseScreen()),
              int() => throw UnimplementedError(),
            },
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedItemColor: const Color.fromRGBO(128, 128, 204, 1.0),
        unselectedItemColor: const Color.fromRGBO(255, 17, 203, 1),
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
            label: 'Entrada',
          ),
          BottomNavigationBarItem(
            icon: Icon(TablerIcons.home),
            label: 'Inicio',
            activeIcon: Icon(TablerIcons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(TablerIcons.circle_dashed_minus),
            activeIcon: Icon(TablerIcons.circle_minus),
            label: 'Gasto',
          ),
        ],
      ),
    );
  }
}
