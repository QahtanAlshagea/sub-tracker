import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../domain/entities/backup_preview.dart';
import '../state/settings_controller.dart';
import '../state/view_state.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';

/// Screen for managing application preferences, backup import/export, and data wipe.
///
/// Implements [FR-20], [US-38], [US-39], [EC-38-1]..[EC-38-3], [EC-39-1]:
/// - Theme mode selection (System, Light, Dark).
/// - Default currency selection.
/// - Backup export with localized feedback.
/// - Backup import dialog with strategy options.
/// - Defensive data wipe requiring exact keyword confirmation ("مسح").
/// - Version information display.
class SettingsScreen extends StatefulWidget {
  final SettingsController controller;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.controller,
    this.onThemeModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settingsTitle ?? 'الإعدادات العامة')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;

          return switch (state) {
            ViewStateLoading() => AppLoadingView(
              message: l10n?.settingsTab ?? 'جاري تحميل الإعدادات...',
            ),
            ViewStateError(message: final msg, onRetry: final retry) =>
              AppErrorView(
                message: msg,
                onRetry: retry,
                retryLabel: l10n?.retry ?? 'إعادة المحاولة',
              ),
            ViewStateEmpty(title: final t, subtitle: final sub) => AppEmptyView(
              title: t,
              subtitle: sub,
            ),
            ViewStateData(data: final settings) => _buildSettingsList(
              context,
              settings,
              l10n,
            ),
          };
        },
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    SettingsState settings,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Notifications or Errors
        if (settings.notificationMessage != null) ...[
          _buildBanner(
            context,
            message: settings.notificationMessage!,
            color: isDark ? AppColors.emerald800 : AppColors.emerald100,
            textColor: isDark ? AppColors.white : AppColors.emerald700,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (settings.errorMessage != null) ...[
          _buildBanner(
            context,
            message: settings.errorMessage!,
            color: theme.colorScheme.errorContainer,
            textColor: theme.colorScheme.onErrorContainer,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 1. Appearance Section
        _buildSectionHeader(theme, l10n?.appearance ?? 'المظهر والسمة'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.cardRadius,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  key: const Key('settings_theme_segmented_button'),
                  segments: [
                    ButtonSegment(
                      value: 'system',
                      label: Text(l10n?.themeSystem ?? 'تلقائي'),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: 'light',
                      label: Text(l10n?.themeLight ?? 'فاتح'),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: 'dark',
                      label: Text(l10n?.themeDark ?? 'داكن'),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selected) {
                    final mode = selected.first;
                    widget.controller.updateThemeMode(mode);
                    if (widget.onThemeModeChanged != null) {
                      final themeMode = switch (mode) {
                        'light' => ThemeMode.light,
                        'dark' => ThemeMode.dark,
                        _ => ThemeMode.system,
                      };
                      widget.onThemeModeChanged!(themeMode);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 2. Default Currency Section
        _buildSectionHeader(
          theme,
          l10n?.defaultCurrency ?? 'العملة الافتراضية',
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.cardRadius,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: DropdownButtonFormField<String>(
              key: const Key('settings_currency_dropdown'),
              initialValue: settings.defaultCurrency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                prefixIcon: const Icon(Icons.monetization_on_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD - Dollar (\$)'),
                ),
                DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro (€)')),
                DropdownMenuItem(value: 'GBP', child: Text('GBP - Pound (£)')),
                DropdownMenuItem(
                  value: 'SAR',
                  child: Text('SAR - ريال سعودي (ر.س)'),
                ),
                DropdownMenuItem(
                  value: 'AED',
                  child: Text('AED - درهم إماراتي (د.إ)'),
                ),
                DropdownMenuItem(
                  value: 'YER',
                  child: Text('YER - ريال يمني (ر.ي)'),
                ),
                DropdownMenuItem(
                  value: 'JPY',
                  child: Text('JPY - Japanese Yen (¥)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) widget.controller.updateDefaultCurrency(val);
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 3. Data Management Section
        _buildSectionHeader(
          theme,
          l10n?.dataManagement ?? 'إدارة البيانات والنسخ الاحتياطي',
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.cardRadius,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              MinTouchTarget(
                child: ListTile(
                  key: const Key('settings_export_backup_tile'),
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n?.exportBackup ?? 'تصدير نسخة احتياطية'),
                  trailing: settings.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: settings.isBusy
                      ? null
                      : () => widget.controller.exportBackup(),
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              MinTouchTarget(
                child: ListTile(
                  key: const Key('settings_import_backup_tile'),
                  leading: const Icon(Icons.download),
                  title: Text(l10n?.importBackup ?? 'استيراد نسخة احتياطية'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: settings.isBusy
                      ? null
                      : () => _showImportBackupDialog(context, l10n),
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              MinTouchTarget(
                child: ListTile(
                  key: const Key('settings_wipe_data_tile'),
                  leading: const Icon(
                    Icons.delete_forever,
                    color: AppColors.rose600,
                  ),
                  title: Text(
                    l10n?.wipeData ?? 'مسح جميع البيانات نهائياً',
                    style: const TextStyle(color: AppColors.rose600),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.rose600,
                  ),
                  onTap: settings.isBusy
                      ? null
                      : () => _showWipeDataConfirmationDialog(context, l10n),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // 4. Version and Info
        Center(
          child: Column(
            children: [
              Text(
                l10n?.appVersionInfo ?? 'إصدار التطبيق: 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n?.schemaVersionInfo ?? 'إصدار قاعدة البيانات: V2',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
        right: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required String message,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportBackupDialog(
    BuildContext context,
    AppLocalizations? l10n,
  ) async {
    final textController = TextEditingController();
    ImportStrategy selectedStrategy = ImportStrategy.merge;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n?.importBackup ?? 'استيراد نسخة احتياطية'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('settings_import_json_field'),
                  controller: textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'محتوى النسخة الاحتياطية (JSON)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('استراتيجية الاستيراد:'),
                RadioGroup<ImportStrategy>(
                  groupValue: selectedStrategy,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedStrategy = val);
                  },
                  child: Column(
                    children: const [
                      RadioListTile<ImportStrategy>(
                        title: Text('دمج البيانات (Merge)'),
                        value: ImportStrategy.merge,
                      ),
                      RadioListTile<ImportStrategy>(
                        title: Text('استبدال شامل (Replace)'),
                        value: ImportStrategy.replace,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n?.cancel ?? 'إلغاء'),
            ),
            FilledButton(
              key: const Key('settings_confirm_import_button'),
              onPressed: () async {
                final content = textController.text.trim();
                if (content.isNotEmpty) {
                  Navigator.of(ctx).pop();
                  await widget.controller.importBackup(
                    content,
                    strategy: selectedStrategy,
                  );
                }
              },
              child: Text(l10n?.confirm ?? 'تأكيد الاستيراد'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWipeDataConfirmationDialog(
    BuildContext context,
    AppLocalizations? l10n,
  ) async {
    final keyword = l10n?.wipeDataKeyword ?? 'مسح';
    final textController = TextEditingController();
    bool isMatch = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(
            l10n?.wipeDataConfirmTitle ?? 'تأكيد مسح البيانات نهائياً',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.wipeDataConfirmPrompt ??
                    'اكتب كلمة «$keyword» لتأكيد الحذف النهائي لكافة البيانات:',
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('settings_wipe_keyword_field'),
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: keyword,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() {
                    isMatch = val.trim() == keyword;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n?.cancel ?? 'إلغاء'),
            ),
            FilledButton(
              key: const Key('settings_confirm_wipe_button'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: isMatch
                  ? () async {
                      Navigator.of(ctx).pop();
                      await widget.controller.wipeAllData();
                    }
                  : null,
              child: Text(l10n?.wipeData ?? 'مسح نهائي'),
            ),
          ],
        ),
      ),
    );
  }
}
