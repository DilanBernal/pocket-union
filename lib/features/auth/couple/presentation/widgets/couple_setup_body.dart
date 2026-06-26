import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/common/app_response.dart';
import 'package:pocket_union/features/auth/couple/presentation/controllers/couple_setup_controller.dart';
import 'package:pocket_union/features/auth/couple/presentation/widgets/option_card.dart';
import 'package:pocket_union/features/auth/ui/widgets/form_title.dart';
import 'package:pocket_union/ui/router.dart';
import 'internet_warning.dart';

class CoupleSetupBody extends ConsumerStatefulWidget {
  const CoupleSetupBody({super.key});

  @override
  ConsumerState<CoupleSetupBody> createState() => _CoupleSetupBodyState();
}

class _CoupleSetupBodyState extends ConsumerState<CoupleSetupBody> {
  String? _generatedCode;
  bool _showInviteSection = false;
  bool _showJoinSection = false;
  final _joinCodeController = TextEditingController();

  static const _colorFocusBorder = Color.fromRGBO(56, 49, 70, 1);
  static const _colorEnabledBorder = Color.fromRGBO(45, 41, 53, 1);

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateCouple() async {
    final controller = ref.read(coupleSetupControllerProvider.notifier);
    final response = await controller.createCouple();

    switch (response) {
      case Failure():
        final error = response.error;
        if (error.code == 'couple_setup_user_missing') {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
          return;
        }
        _showError(
          'Error al crear la pareja. Verifica tu conexión a internet.',
        );
        return;
      case Success(value: final inviteCode):
        if (!mounted) return;
        setState(() {
          _generatedCode = inviteCode;
          _showInviteSection = true;
        });
    }
  }

  Future<void> _handleJoinCouple() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 6) {
      _showError('Ingresa un código de invitación válido (6 caracteres)');
      return;
    }

    final controller = ref.read(coupleSetupControllerProvider.notifier);
    final response = await controller.joinCoupleByCode(code);

    switch (response) {
      case Failure():
        _showError(
          'Error al unirte a la pareja. Verifica tu conexión a internet.',
        );
        return;
      case Success():
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _checkPartnerJoined() async {
    final controller = ref.read(coupleSetupControllerProvider.notifier);
    final response = await controller.checkPartnerJoined();

    switch (response) {
      case Failure():
        _showError('Error al verificar: no se pudo obtener la pareja.');
        return;
      case Success(value: true):
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      case Success():
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu pareja aún no se ha unido. Comparte el código!'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(coupleSetupControllerProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormTitle(
            title: 'Sincroniza con tu pareja',
            shadowColor: Colors.deepPurple,
            textColor: Colors.white,
            gradientColors: [
              Color.fromARGB(255, 116, 11, 218),
              Color.fromRGBO(251, 0, 204, 1),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Para usar Pocket Union necesitas estar conectado con tu pareja. '
            'Este paso requiere conexión a internet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          InternetWarning(),
          const SizedBox(height: 32),

          // Show main options or invite/join sections
          if (!_showInviteSection && !_showJoinSection) ...[
            OptionCard(
              icon: Icons.person_add,
              title: 'Invitar a mi pareja',
              description:
                  'Genera un código de invitación para que tu pareja se una.',
              onTap: isLoading ? null : _handleCreateCouple,
              color: const Color.fromARGB(255, 116, 11, 218),
            ),
            const SizedBox(height: 16),
            OptionCard(
              icon: Icons.link,
              title: 'Tengo un código',
              description:
                  'Ingresa el código que te compartió tu pareja para unirte.',
              onTap: isLoading
                  ? null
                  : () => setState(() => _showJoinSection = true),
              color: const Color.fromRGBO(251, 0, 204, 1),
            ),
          ],

          // Invite section — show generated code
          if (_showInviteSection) _buildInviteSection(isLoading),

          // Join section — enter code
          if (_showJoinSection) _buildJoinSection(isLoading),

          if (isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteSection(bool isLoading) {
    return Column(
      children: [
        const Icon(Icons.celebration, color: Colors.amber, size: 48),
        const SizedBox(height: 16),
        Text(
          '¡Pareja creada!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Comparte este código con tu pareja para que se una:',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Code display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(22, 17, 30, 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(255, 116, 11, 218).withAlpha(100),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _generatedCode ?? '',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedCode ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código copiado al portapapeles'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, color: Colors.white60),
                tooltip: 'Copiar código',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Check if partner joined
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _checkPartnerJoined,
            icon: const Icon(Icons.refresh),
            label: const Text('Verificar si mi pareja se unió'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color.fromARGB(255, 116, 11, 218),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _showInviteSection = false;
            _generatedCode = null;
          }),
          child: const Text(
            '← Volver a las opciones',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinSection(bool isLoading) {
    return Column(
      children: [
        const Icon(Icons.link, color: Color.fromRGBO(251, 0, 204, 1), size: 48),
        const SizedBox(height: 16),
        Text(
          'Únete a tu pareja',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa el código de 6 caracteres que te compartió tu pareja:',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Code input
        TextFormField(
          controller: _joinCodeController,
          textAlign: TextAlign.center,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            fillColor: const Color.fromRGBO(22, 17, 30, 1),
            filled: true,
            hintText: 'ABC123',
            hintStyle: TextStyle(
              color: Colors.white.withAlpha(30),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
            ),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _colorFocusBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _colorEnabledBorder, width: 1.5),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleJoinCouple,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.group_add),
            label: Text(isLoading ? 'Uniéndose...' : 'Unirme a la pareja'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color.fromRGBO(251, 0, 204, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _showJoinSection = false),
          child: const Text(
            '← Volver a las opciones',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }
}
