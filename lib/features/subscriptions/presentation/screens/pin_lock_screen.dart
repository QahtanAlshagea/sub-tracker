import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../domain/usecases/disable_pin_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import '../../domain/value_objects/pin_code.dart';

/// Screen mode for PIN lock interactions.
enum PinScreenMode { unlock, create, disable }

/// Offline-only PIN Security Screen for app protection and PIN setup.
///
/// Features:
/// - 4-digit numeric keypad with haptic feedback.
/// - Dot indicator representing entered digits.
/// - Lockout defense: 5 failed attempts trigger a 30-second lockout timer.
/// - Two-step confirmation for PIN creation.
/// - Verification before disabling PIN.
class PinLockScreen extends StatefulWidget {
  final PinScreenMode mode;
  final VerifyPinUseCase? verifyPinUseCase;
  final SetPinUseCase? setPinUseCase;
  final DisablePinUseCase? disablePinUseCase;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const PinLockScreen({
    super.key,
    required this.mode,
    this.verifyPinUseCase,
    this.setPinUseCase,
    this.disablePinUseCase,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  String? _firstEnteredPin;
  String? _errorMessage;
  int _failedAttempts = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;
  bool _isProcessing = false;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_lockoutSeconds > 0 || _isProcessing) return;
    if (_enteredPin.length >= PinCode.requiredLength) return;

    AppHaptics.lightImpact();
    setState(() {
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == PinCode.requiredLength) {
      _processCompletePin();
    }
  }

  void _onBackspacePressed() {
    if (_lockoutSeconds > 0 || _isProcessing || _enteredPin.isEmpty) return;
    AppHaptics.selectionClick();
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _processCompletePin() async {
    setState(() => _isProcessing = true);

    switch (widget.mode) {
      case PinScreenMode.unlock:
        await _handleUnlock();
        break;
      case PinScreenMode.create:
        await _handleCreate();
        break;
      case PinScreenMode.disable:
        await _handleDisable();
        break;
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleUnlock() async {
    if (widget.verifyPinUseCase == null) {
      widget.onSuccess?.call();
      return;
    }

    final res = await widget.verifyPinUseCase!(_enteredPin);
    if (res.isSuccess && res.dataOrNull == true) {
      AppHaptics.mediumImpact();
      widget.onSuccess?.call();
    } else {
      _onFailedAttempt('رمز PIN غير صحيح');
    }
  }

  Future<void> _handleCreate() async {
    if (_firstEnteredPin == null) {
      // Step 1 done, move to confirmation step
      setState(() {
        _firstEnteredPin = _enteredPin;
        _enteredPin = '';
      });
      AppHaptics.lightImpact();
    } else {
      // Step 2: Confirm PIN
      if (_enteredPin == _firstEnteredPin) {
        if (widget.setPinUseCase != null) {
          final res = await widget.setPinUseCase!(_enteredPin);
          if (res.isSuccess) {
            AppHaptics.mediumImpact();
            widget.onSuccess?.call();
          } else {
            setState(() {
              _firstEnteredPin = null;
              _enteredPin = '';
              _errorMessage = 'فشل حفظ الرمز، حاول مجدداً';
            });
          }
        } else {
          widget.onSuccess?.call();
        }
      } else {
        AppHaptics.heavyImpact();
        setState(() {
          _firstEnteredPin = null;
          _enteredPin = '';
          _errorMessage = 'الرمزان غير متطابقين، أعد المحاولة';
        });
      }
    }
  }

  Future<void> _handleDisable() async {
    if (widget.verifyPinUseCase == null || widget.disablePinUseCase == null) {
      widget.onSuccess?.call();
      return;
    }

    final verifyRes = await widget.verifyPinUseCase!(_enteredPin);
    if (verifyRes.isSuccess && verifyRes.dataOrNull == true) {
      final disableRes = await widget.disablePinUseCase!(const NoParams());
      if (disableRes.isSuccess) {
        AppHaptics.mediumImpact();
        widget.onSuccess?.call();
      } else {
        setState(() {
          _enteredPin = '';
          _errorMessage = 'تعذر إلغاء القفل، حاول ثانية';
        });
      }
    } else {
      _onFailedAttempt('رمز PIN غير صحيح');
    }
  }

  void _onFailedAttempt(String message) {
    AppHaptics.heavyImpact();
    _failedAttempts++;

    if (_failedAttempts >= 5) {
      _startLockout(30);
      setState(() {
        _enteredPin = '';
        _errorMessage = 'تم قفل الإدخال لمدة 30 ثانية لكثرة المحاولات';
      });
    } else {
      setState(() {
        _enteredPin = '';
        _errorMessage = '$message (المحاولة $_failedAttempts من 5)';
      });
    }
  }

  void _startLockout(int seconds) {
    setState(() => _lockoutSeconds = seconds);
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutSeconds <= 1) {
        timer.cancel();
        setState(() {
          _lockoutSeconds = 0;
          _failedAttempts = 0;
          _errorMessage = null;
        });
      } else {
        setState(() => _lockoutSeconds--);
      }
    });
  }

  String get _title {
    if (_lockoutSeconds > 0) return 'التطبيق مقفل مؤقتاً';
    switch (widget.mode) {
      case PinScreenMode.unlock:
        return 'قفل التطبيق';
      case PinScreenMode.create:
        return _firstEnteredPin == null ? 'تعيين رمز PIN' : 'تأكيد رمز PIN';
      case PinScreenMode.disable:
        return 'إلغاء قفل PIN';
    }
  }

  String get _subtitle {
    if (_lockoutSeconds > 0) {
      return 'انتظر $_lockoutSeconds ثانية للمحاولة مجدداً';
    }
    switch (widget.mode) {
      case PinScreenMode.unlock:
        return 'أدخل رمز PIN المكون من 4 أرقام للمتابعة';
      case PinScreenMode.create:
        return _firstEnteredPin == null
            ? 'اختر رمز PIN مكوناً من 4 أرقام لحماية بياناتك'
            : 'أعد إدخال نفس الرمز للتأكيد';
      case PinScreenMode.disable:
        return 'أدخل رمز PIN الحالي لتعطيل القفل';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: widget.mode != PinScreenMode.unlock,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: widget.onCancel != null
              ? IconButton(
                  key: const Key('pin_cancel_button'),
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                )
              : null,
          title: Text(_title),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Lock Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _lockoutSeconds > 0
                      ? AppColors.rose500.withValues(alpha: 0.15)
                      : theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _lockoutSeconds > 0
                      ? Icons.timer_outlined
                      : Icons.lock_outline_rounded,
                  size: 36,
                  color: _lockoutSeconds > 0
                      ? AppColors.rose500
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title & Subtitle
              Text(
                _title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  _subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4 Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(PinCode.requiredLength, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: isFilled ? 18 : 14,
                    height: isFilled ? 18 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? (_errorMessage != null
                                ? AppColors.rose500
                                : theme.colorScheme.primary)
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      border: Border.all(
                        color: isFilled
                            ? Colors.transparent
                            : theme.colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.rose500,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(flex: 1),

              // Numeric Keypad (1 to 9, then empty, 0, backspace)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: AppSpacing.md),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: AppSpacing.md),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 72, height: 72),
                        _buildKeypadButton('0'),
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: IconButton(
                            key: const Key('pin_keypad_backspace'),
                            icon: const Icon(Icons.backspace_outlined),
                            iconSize: 26,
                            onPressed:
                                _enteredPin.isNotEmpty && _lockoutSeconds == 0
                                ? _onBackspacePressed
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildKeypadButton).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: isDark
            ? AppColors.darkSurface
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('pin_keypad_$digit'),
          onTap: _lockoutSeconds == 0 ? () => _onDigitPressed(digit) : null,
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _lockoutSeconds > 0
                    ? theme.disabledColor
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
