import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/service_provider.dart';
import 'package:pocket_union/dto/new_recurrent_income_dto.dart';
import 'package:pocket_union/ui/screens/transactions/recurrent/cron_expression_utils.dart';
import 'package:pocket_union/ui/screens/transactions/transaction_form_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _RecurrenceType { weekly, monthly }

class NewRecurrentIncomeForm extends ConsumerStatefulWidget {
  const NewRecurrentIncomeForm({super.key});

  @override
  ConsumerState<NewRecurrentIncomeForm> createState() =>
      _NewRecurrentIncomeFormState();
}

class _NewRecurrentIncomeFormState
    extends ConsumerState<NewRecurrentIncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool _forMe = true;
  _RecurrenceType _recurrenceType = _RecurrenceType.weekly;
  int _dayOfWeek = 1;
  String _dayOfMonth = '1';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _buildCron() {
    if (_recurrenceType == _RecurrenceType.weekly) {
      return CronExpressionUtils.buildWeekly(dayOfWeek: _dayOfWeek);
    }

    return CronExpressionUtils.buildMonthly(dayOfMonth: _dayOfMonth);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final coupleId = prefs.getString('coupleId');
      final userId = prefs.getString('idUser');

      if (coupleId == null || coupleId.isEmpty) {
        throw Exception(
          'No se encontro coupleId para crear ingreso recurrente',
        );
      }

      if (userId == null || userId.isEmpty) {
        throw Exception('No se encontro idUser para created_by');
      }

      final cron = _buildCron();
      if (!CronExpressionUtils.isValidCron(cron)) {
        throw Exception('Expresion cron invalida: $cron');
      }

      final dto = NewRecurrentIncomeDto(
        name: _nameController.text.trim(),
        amount: TransactionFormUtils.parseAmount(_amountController.text),
        coupleId: coupleId,
        createdBy: userId,
        userRecipientId: _forMe ? userId : null,
        recurrentInfo: cron,
      );

      final service = await ref.read(recurrentIncomeServiceProvider.future);
      await service.createRecurrentIncome(dto);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingreso recurrente programado ($cron)'),
          backgroundColor: Colors.green,
        ),
      );

      _nameController.clear();
      _amountController.clear();
      setState(() {
        _forMe = true;
        _recurrenceType = _RecurrenceType.weekly;
        _dayOfWeek = 1;
        _dayOfMonth = '1';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al programar ingreso recurrente: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cronPreview = _buildCron();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del ingreso programado',
                hintText: 'Ej: Nomina, Freelance mensual',
                prefixIcon: Icon(Icons.label),
              ),
              validator: TransactionFormUtils.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: TransactionFormUtils.validateAmount,
            ),
            const SizedBox(height: 16),
            Text('Frecuencia', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<_RecurrenceType>(
              segments: const [
                ButtonSegment<_RecurrenceType>(
                  value: _RecurrenceType.weekly,
                  label: Text('Semanal'),
                  icon: Icon(Icons.date_range),
                ),
                ButtonSegment<_RecurrenceType>(
                  value: _RecurrenceType.monthly,
                  label: Text('Mensual'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {_recurrenceType},
              onSelectionChanged: (selection) {
                setState(() => _recurrenceType = selection.first);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'La hora se define en backend. Este formulario solo configura periodicidad.',
            ),
            const SizedBox(height: 16),
            if (_recurrenceType == _RecurrenceType.weekly)
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Dia de la semana',
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Domingo (0)')),
                  DropdownMenuItem(value: 1, child: Text('Lunes (1)')),
                  DropdownMenuItem(value: 2, child: Text('Martes (2)')),
                  DropdownMenuItem(value: 3, child: Text('Miercoles (3)')),
                  DropdownMenuItem(value: 4, child: Text('Jueves (4)')),
                  DropdownMenuItem(value: 5, child: Text('Viernes (5)')),
                  DropdownMenuItem(value: 6, child: Text('Sabado (6)')),
                ],
                onChanged: (value) => setState(() => _dayOfWeek = value ?? 1),
              )
            else
              DropdownButtonFormField<String>(
                value: _dayOfMonth,
                decoration: const InputDecoration(labelText: 'Dia del mes'),
                items: [
                  ...List.generate(
                    31,
                    (i) => DropdownMenuItem(
                      value: '${i + 1}',
                      child: Text('Dia ${i + 1}'),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: '\$',
                    child: Text('Ultimo dia del mes (\$)'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _dayOfMonth = value ?? '1'),
              ),
            const SizedBox(height: 16),
            Text(
              'Destino del ingreso',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('YO'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('NOSOTROS'),
                  icon: Icon(Icons.people),
                ),
              ],
              selected: {_forMe},
              onSelectionChanged: (selection) {
                setState(() => _forMe = selection.first);
              },
            ),
            const SizedBox(height: 12),
            SelectableText(
              'Cron preview: $cronPreview',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.schedule),
              label: Text(_isSubmitting ? 'Guardando...' : 'Programar ingreso'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
