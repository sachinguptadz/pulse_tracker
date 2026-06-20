import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pulse_background.dart';
import '../../core/widgets/pulse_logo.dart';
import 'auth_controller.dart';
import 'widgets/pin_dots_painter.dart';
import 'widgets/pin_key_painter.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PulseBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 46),
                  child: Obx(() {
                    final status = controller.status.value;
                    final error = controller.error.value;
                    final pinCount = controller.pinDigits.length;
                    final shake = controller.shakePin.value;
                    final canUseBio = controller.biometricAvailable.value;
                    final bioLabel = controller.biometricLabel.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        const _BrandPill(),
                        const SizedBox(height: 30),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: Text(_titleFor(status, bioLabel), key: ValueKey('title-$status'), style: Theme.of(context).textTheme.displayLarge),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: Text(_subtitleFor(status, bioLabel), key: ValueKey('sub-$status'), style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        const SizedBox(height: 28),
                        _StatusCard(status: status, error: error, biometricLabel: bioLabel),
                        const SizedBox(height: 30),
                        if (status == AuthStatus.askBiometric)
                          _BiometricChoice(controller: controller, biometricLabel: bioLabel)
                        else
                          AnimatedSlide(
                            offset: shake ? const Offset(0.04, 0) : Offset.zero,
                            duration: const Duration(milliseconds: 80),
                            child: _PinPad(controller: controller, pinCount: pinCount, showBio: status == AuthStatus.pinFallback && canUseBio),
                          ),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _titleFor(AuthStatus status, String biometricLabel) {
    return switch (status) {
      AuthStatus.setupPin => 'Create your secure PIN',
      AuthStatus.confirmPin => 'Confirm your PIN',
      AuthStatus.askBiometric => 'Enable $biometricLabel unlock?',
      AuthStatus.checking => 'Checking $biometricLabel',
      _ => 'Unlock your daily pulse',
    };
  }

  String _subtitleFor(AuthStatus status, String biometricLabel) {
    return switch (status) {
      AuthStatus.setupPin => 'Set a 4 digit PIN first. Nothing is pre-filled for you.',
      AuthStatus.confirmPin => 'Enter the same 4 digits once more.',
      AuthStatus.askBiometric => '$biometricLabel is available. You can enable it now or use PIN only.',
      AuthStatus.checking => 'Keep your device ready for secure verification.',
      _ => 'Use your PIN or biometric unlock when enabled.',
    };
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.white70,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulseLogo(size: 30),
          const SizedBox(width: 9),
          Text('PulseTrack', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.error, required this.biometricLabel});

  final AuthStatus status;
  final AuthErrorState? error;
  final String biometricLabel;

  @override
  Widget build(BuildContext context) {
    final checking = status == AuthStatus.checking;
    final setup = status == AuthStatus.setupPin || status == AuthStatus.confirmPin;
    final ask = status == AuthStatus.askBiometric;
    return GlassCard(
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: ask ? const [AppColors.mint, AppColors.blue] : const [AppColors.coral, AppColors.orange]),
            ),
            child: Icon(checking ? Icons.face_retouching_natural_rounded : setup ? Icons.password_rounded : ask ? Icons.verified_user_rounded : Icons.lock_open_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(_headline, key: ValueKey(_headline), style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 4),
                Text(error?.message ?? _body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (checking) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4)),
        ],
      ),
    );
  }

  String get _headline {
    return switch (status) {
      AuthStatus.setupPin => 'New password setup',
      AuthStatus.confirmPin => 'Confirm securely',
      AuthStatus.askBiometric => '$biometricLabel available',
      AuthStatus.checking => 'Waiting for approval',
      _ => 'Secure login',
    };
  }

  String get _body {
    return switch (status) {
      AuthStatus.setupPin => 'Choose any 4 digits you can remember.',
      AuthStatus.confirmPin => 'This keeps the app protected without a default PIN.',
      AuthStatus.askBiometric => 'Enable it for faster unlock next time.',
      AuthStatus.checking => 'Approve the request on your device.',
      _ => 'Enter your own PIN to continue.',
    };
  }
}

class _BiometricChoice extends StatelessWidget {
  const _BiometricChoice({required this.controller, required this.biometricLabel});

  final AuthController controller;
  final String biometricLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 34,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(colors: [AppColors.mint, AppColors.blue]),
            ),
            child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 46),
          ),
          const SizedBox(height: 16),
          Text('Use $biometricLabel for quick unlock', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('PIN will still stay as fallback when biometrics fail or are unavailable.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: () => controller.chooseBiometric(true), icon: const Icon(Icons.verified_rounded), label: Text('Enable $biometricLabel')),
          const SizedBox(height: 10),
          TextButton(onPressed: () => controller.chooseBiometric(false), child: const Text('Use PIN only')),
        ],
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({required this.controller, required this.pinCount, required this.showBio});

  final AuthController controller;
  final int pinCount;
  final bool showBio;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 36,
      child: Column(
        children: [
          SizedBox(
            height: 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: CustomPaint(
                key: ValueKey(pinCount),
                painter: PinDotsPainter(count: pinCount, color: Theme.of(context).colorScheme.onSurface),
                child: const SizedBox(width: 148),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final row in const [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [-1, 0, -2],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: row.map((number) {
                  final hiddenBio = number == -1 && !showBio;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: hiddenBio
                          ? const SizedBox(height: 66)
                          : _PinKey(
                              value: number,
                              label: number == -1 ? 'bio' : number == -2 ? 'del' : '$number',
                              isAction: number < 0,
                              onTap: () {
                                if (number == -1) controller.authenticateWithBiometrics(enableAfterSuccess: true);
                                if (number == -2) controller.backspace();
                                if (number >= 0) controller.inputDigit(number);
                              },
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinKey extends StatefulWidget {
  const _PinKey({required this.value, required this.label, required this.isAction, required this.onTap});

  final int value;
  final String label;
  final bool isAction;
  final VoidCallback onTap;

  @override
  State<_PinKey> createState() => _PinKeyState();
}

class _PinKeyState extends State<_PinKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 66,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: CustomPaint(
            painter: PinKeyPainter(
              pressed: _pressed,
              accent: widget.isAction ? AppColors.blue : AppColors.coral,
              dark: Theme.of(context).brightness == Brightness.dark,
            ),
            child: Center(
              child: widget.value == -1
                  ? const Icon(Icons.fingerprint_rounded)
                  : widget.value == -2
                      ? const Icon(Icons.backspace_outlined)
                      : Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
        ),
      ),
    );
  }
}
