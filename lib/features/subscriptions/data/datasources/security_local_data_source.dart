import '../daos/settings_dao.dart';

/// Contract for PIN security state at the local data source level.
abstract class SecurityLocalDataSource {
  /// Whether PIN locking is currently enabled.
  Future<bool> isPinEnabled();

  /// Retrieves the stored SHA-256 PIN hash, or null if not set.
  Future<String?> getPinHash();

  /// Persists a new SHA-256 PIN hash and enables PIN locking.
  Future<void> setPinHash(String hash);

  /// Disables PIN locking and purges the stored hash.
  Future<void> disablePin();
}

/// Concrete implementation of [SecurityLocalDataSource] backed by [SettingsDao].
class SecurityLocalDataSourceImpl implements SecurityLocalDataSource {
  final SettingsDao _settingsDao;

  const SecurityLocalDataSourceImpl(this._settingsDao);

  @override
  Future<bool> isPinEnabled() async {
    final settings = await _settingsDao.getSettings();
    return settings?.isPinEnabled ?? false;
  }

  @override
  Future<String?> getPinHash() async {
    final settings = await _settingsDao.getSettings();
    return settings?.pinHash;
  }

  @override
  Future<void> setPinHash(String hash) async {
    await _settingsDao.updatePinSecurity(isPinEnabled: true, pinHash: hash);
  }

  @override
  Future<void> disablePin() async {
    await _settingsDao.updatePinSecurity(isPinEnabled: false, pinHash: null);
  }
}
