import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/auth_service_provider.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/core/services/auth/couple_service.dart';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoupleSetupBody extends ConsumerStatefulWidget {
  const CoupleSetupBody({super.key});

  @override
  ConsumerState<CoupleSetupBody> createState() => _CoupleSetupBodyState();
}

class _CoupleSetupBodyState extends ConsumerState<CoupleSetupBody> {
  bool _isLoading = false;
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

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idUser');
  }

  Future<void> _handleCreateCouple() async {
    final userId = await _getUserId();
    if (userId == null) {
      _showError('No se encontró tu sesión. Inicia sesión de nuevo.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final inviteCode = CoupleService.generateInviteCode();
      final coupleService = await ref.read(coupleServiceProvider.future);
      final couple = await coupleService.createCouple(userId, inviteCode);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('coupleId', couple.id);
      await prefs.setString('inviteCode', couple.inviteCode ?? inviteCode);

      if (!mounted) return;
      setState(() {
        _generatedCode = couple.inviteCode ?? inviteCode;
        _showInviteSection = true;
      });
    } catch (e) {
      if (!mounted) return;
      _showError(
        'Error al crear la pareja. Verifica tu conexión a internet.\n$e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleJoinCouple() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 6) {
      _showError('Ingresa un código de invitación válido (6 caracteres)');
      return;
    }

    final userId = await _getUserId();
    if (userId == null) {
      _showError('No se encontró tu sesión. Inicia sesión de nuevo.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final coupleService = await ref.read(coupleServiceProvider.future);
      final couple = await coupleService.joinCoupleByCode(code, userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('coupleId', couple.id);
      await prefs.setBool('isInSession', true);

      ref.invalidate(currentCoupleProvider);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkPartnerJoined() async {
    setState(() => _isLoading = true);

    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final coupleService = await ref.read(coupleServiceProvider.future);
      final couple = await coupleService.getCoupleByUserId(userId);

      if (couple != null && couple.isUsable == CoupleUsableState.ready) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('coupleId', couple.id);
        await prefs.setBool('isInSession', true);

        ref.invalidate(currentCoupleProvider);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu pareja aún no se ha unido. Comparte el código!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error al verificar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _buildInternetWarning(),
          const SizedBox(height: 32),

          // Show main options or invite/join sections
          if (!_showInviteSection && !_showJoinSection) ...[
            _buildOptionCard(
              icon: Icons.person_add,
              title: 'Invitar a mi pareja',
              description:
                  'Genera un código de invitación para que tu pareja se una.',
              onTap: _isLoading ? null : _handleCreateCouple,
              color: const Color.fromARGB(255, 116, 11, 218),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              icon: Icons.link,
              title: 'Tengo un código',
              description:
                  'Ingresa el código que te compartió tu pareja para unirte.',
              onTap: _isLoading
                  ? null
                  : () => setState(() => _showJoinSection = true),
              color: const Color.fromRGBO(251, 0, 204, 1),
            ),
          ],

          // Invite section — show generated code
          if (_showInviteSection) _buildInviteSection(),

          // Join section — enter code
          if (_showJoinSection) _buildJoinSection(),

          if (_isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildInternetWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(80)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi, color: Colors.amber, size: 20),
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

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(100)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(30), color.withAlpha(10)],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withAlpha(150),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteSection() {
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
            onPressed: _isLoading ? null : _checkPartnerJoined,
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

  Widget _buildJoinSection() {
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
            onPressed: _isLoading ? null : _handleJoinCouple,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.group_add),
            label: Text(_isLoading ? 'Uniéndose...' : 'Unirme a la pareja'),
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
