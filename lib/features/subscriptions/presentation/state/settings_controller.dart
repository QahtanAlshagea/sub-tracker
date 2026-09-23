import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/backup_preview.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/usecases/disable_pin_usecase.dart';
import '../../domain/usecases/export_backup_usecase.dart';
import '../../domain/usecases/import_backup_usecase.dart';
import '../../domain/usecases/is_pin_enabled_usecase.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import 'view_state.dart';

/// State representation for application settings and data management.
class SettingsState {
  final String themeMode;
  final String defaultCurrency;
  final bool isPinEnabled;
  final bool isBusy;
  final String? notificationMessage;
  final String? errorMessage;

  const SettingsState({
    required this.themeMode,
    required this.defaultCurrency,
    this.isPinEnabled = false,
    this.isBusy = false,
    this.notificationMessage,
    this.errorMessage,
  });

  SettingsState copyWith({
    String? themeMode,
    String? defaultCurrency,
    bool? isPinEnabled,
    bool? isBusy,
    String? notificationMessage,
    String? errorMessage,
    bool clearNotification = false,
    bool clearError = false,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBusy: isBusy ?? this.isBusy,
      notificationMessage: clearNotification
          ? null
          : (notificationMessage ?? this.notificationMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// MVVM state controller for application preferences and data operations.
///
/// Complies with [FR-20], [US-38], [US-39], [EC-38-1]..[EC-38-3], [EC-39-1].
class SettingsController extends ChangeNotifier {
  final ExportBackupUseCase _exportBackupUseCase;
  final ImportBackupUseCase _importBackupUseCase;
  final BackupRepository _backupRepository;
  final IsPinEnabledUseCase? isPinEnabledUseCase;
  final SetPinUseCase? setPinUseCase;
  final DisablePinUseCase? disablePinUseCase;
  final VerifyPinUseCase? verifyPinUseCase;
  final Duration? autoDismissDuration;
  Timer? _dismissTimer;
  bool _disposed = false;

  SettingsController({
    required ExportBackupUseCase exportBackupUseCase,
    required ImportBackupUseCase importBackupUseCase,
    required BackupRepository backupRepository,
    this.isPinEnabledUseCase,
    this.setPinUseCase,
    this.disablePinUseCase,
    this.verifyPinUseCase,
    this.autoDismissDuration,
  }) : _exportBackupUseCase = exportBackupUseCase,
       _importBackupUseCase = importBackupUseCase,
       _backupRepository = backupRepository;

  @override
  void dispose() {
    _disposed = true;
    _dismissTimer?.cancel();
    _dismissTimer = null;
    super.dispose();
  }

  ViewState<SettingsState> _state = const ViewStateData(
    SettingsState(themeMode: 'system', defaultCurrency: 'USD'),
  );
  ViewState<SettingsState> get state => _state;

  void clearNotificationAndError() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    final current = _state.dataOrNull;
    if (current == null) return;
    if (current.notificationMessage != null || current.errorMessage != null) {
      _state = ViewStateData(
        current.copyWith(clearNotification: true, clearError: true),
      );
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  void _scheduleAutoDismiss() {
    if (autoDismissDuration == null) return;
    _dismissTimer?.cancel();
    _dismissTimer = Timer(autoDismissDuration!, () {
      if (!_disposed) {
        clearNotificationAndError();
      }
    });
  }

  void updateThemeMode(String mode) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(current.copyWith(themeMode: mode));
    notifyListeners();
  }

  void updateDefaultCurrency(String currency) {
    final current = _state.dataOrNull;
    if (current == null) return;
    _state = ViewStateData(current.copyWith(defaultCurrency: currency));
    notifyListeners();
  }

  Future<void> loadPinStatus() async {
    if (isPinEnabledUseCase == null) return;
    final res = await isPinEnabledUseCase!(const NoParams());
    if (res.isSuccess) {
      final current = _state.dataOrNull;
      if (current != null) {
        _state = ViewStateData(
          current.copyWith(isPinEnabled: res.dataOrNull ?? false),
        );
        notifyListeners();
      }
    }
  }

  Future<bool> setPin(String pin) async {
    if (setPinUseCase == null) return false;
    final res = await setPinUseCase!(pin);
    if (res.isSuccess) {
      final current = _state.dataOrNull;
      if (current != null) {
        _state = ViewStateData(
          current.copyWith(
            isPinEnabled: true,
            notificationMessage: 'تم تفعيل قفل التطبيق بنجاح',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
      }
      return true;
    }
    return false;
  }

  Future<bool> disablePin(String currentPin) async {
    if (verifyPinUseCase == null || disablePinUseCase == null) return false;
    final verifyRes = await verifyPinUseCase!(currentPin);
    if (verifyRes.isSuccess && verifyRes.dataOrNull == true) {
      final res = await disablePinUseCase!(const NoParams());
      if (res.isSuccess) {
        final current = _state.dataOrNull;
        if (current != null) {
          _state = ViewStateData(
            current.copyWith(
              isPinEnabled: false,
              notificationMessage: 'تم إلغاء قفل التطبيق',
            ),
          );
          notifyListeners();
          _scheduleAutoDismiss();
        }
        return true;
      }
    }
    return false;
  }

  Future<String?> exportBackup() async {
    final current = _state.dataOrNull;
    if (current == null || current.isBusy) return null;

    _state = ViewStateData(
      current.copyWith(isBusy: true, clearError: true, clearNotification: true),
    );
    notifyListeners();

    try {
      final result = await _exportBackupUseCase();
      if (result.isSuccess) {
        _state = ViewStateData(
          current.copyWith(
            isBusy: false,
            notificationMessage: 'تم تصدير النسخة الاحتياطية بنجاح',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
        return result.valueOrNull;
      } else {
        _state = ViewStateData(
          current.copyWith(
            isBusy: false,
            errorMessage:
                result.failureOrNull?.message ?? 'فشل تصدير النسخة الاحتياطية',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
        return null;
      }
    } finally {
      if (_state.dataOrNull?.isBusy ?? false) {
        _state = ViewStateData(_state.dataOrNull!.copyWith(isBusy: false));
        notifyListeners();
      }
    }
  }

  Future<bool> importBackup(
    String jsonContent, {
    ImportStrategy strategy = ImportStrategy.merge,
  }) async {
    final current = _state.dataOrNull;
    if (current == null || current.isBusy) return false;

    _state = ViewStateData(
      current.copyWith(isBusy: true, clearError: true, clearNotification: true),
    );
    notifyListeners();

    try {
      final result = await _importBackupUseCase(
        jsonContent: jsonContent,
        strategy: strategy,
      );

      if (result.isSuccess) {
        _state = ViewStateData(
          current.copyWith(
            isBusy: false,
            notificationMessage: 'تم استيراد النسخة الاحتياطية بنجاح',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
        return true;
      } else {
        _state = ViewStateData(
          current.copyWith(
            isBusy: false,
            errorMessage:
                result.failureOrNull?.message ??
                'فشل استيراد النسخة الاحتياطية',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
        return false;
      }
    } finally {
      if (_state.dataOrNull?.isBusy ?? false) {
        _state = ViewStateData(_state.dataOrNull!.copyWith(isBusy: false));
        notifyListeners();
      }
    }
  }

  /// Wipes all application database data permanently ([US-39]).
  Future<bool> wipeAllData() async {
    final current = _state.dataOrNull;
    if (current == null || current.isBusy) return false;

    _state = ViewStateData(
      current.copyWith(isBusy: true, clearError: true, clearNotification: true),
    );
    notifyListeners();

    try {
      final wipeResult = await _backupRepository.wipeDatabase();
      if (wipeResult.isSuccess) {
        _state = ViewStateData(
          current.copyWith(
            isBusy: false,
            notificationMessage: 'تم مسح جميع البيانات بنجاح',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
        return true;
      } else {
        _state = ViewStateData(
          current.copyWith(
            isBusy: false,
            errorMessage:
                wipeResult.failureOrNull?.message ?? 'تعذر مسح البيانات',
          ),
        );
        notifyListeners();
        _scheduleAutoDismiss();
        return false;
      }
    } catch (e) {
      _state = ViewStateData(
        current.copyWith(isBusy: false, errorMessage: e.toString()),
      );
      notifyListeners();
      _scheduleAutoDismiss();
      return false;
    }
  }
}
