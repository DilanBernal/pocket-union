import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:pocket_union/features/transaction/application/services/income_service.dart';
import 'package:pocket_union/features/transaction/domain/entities/income_entity.dart';
import 'package:pocket_union/features/transaction/income/presentation/controllers/income_history.controller.dart';

class IncomeHistoryList extends ConsumerWidget {
  const IncomeHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(incomeHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de ingresos')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(incomeHistoryControllerProvider.notifier).refresh(),
        child: incomesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: Center(
                  child: Text(
                    'No se pudo cargar el historial: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          data: (incomes) => incomes.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Icon(TablerIcons.receipt_off, size: 48),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        'No hay ingresos registrados',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: incomes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) =>
                      _IncomeHistoryTile(income: incomes[index]),
                ),
        ),
      ),
    );
  }
}

class _IncomeHistoryTile extends StatelessWidget {
  final IncomeEntity income;

  const _IncomeHistoryTile({required this.income});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'es');
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Dismissible(
      key: ValueKey(income.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Eliminar ingreso'),
          content: Text('¿Deseas eliminar "${income.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        final container = ProviderScope.containerOf(context);
        final service = await container.read(incomeServiceProvider.future);
        await service.deleteIncome(income.id);
        container.invalidate(incomeHistoryControllerProvider);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color.fromRGBO(
              53,
              145,
              94,
              1,
            ).withValues(alpha: 0.12),
            child: const Icon(
              TablerIcons.arrow_up,
              color: Color.fromRGBO(53, 145, 94, 1),
            ),
          ),
          title: Text(
            income.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            income.description?.isNotEmpty == true
                ? '${dateFormat.format(income.transactionDate)} · ${income.description}'
                : dateFormat.format(income.transactionDate),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${currencyFormat.format(income.amount)}',
                style: const TextStyle(
                  color: Color.fromRGBO(53, 145, 94, 1),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!income.isReceived)
                const Text(
                  'Pendiente',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
