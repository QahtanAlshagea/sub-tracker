import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/accessibility/accessibility_widgets.dart';
import '../../../../core/theme/tokens/app_colors.dart';
import '../../../../core/theme/tokens/app_radii.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/utils/backup_file_manager.dart';
import '../../domain/entities/backup_preview.dart';
import '../state/settings_controller.dart';
import '../state/view_state.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading_view.dart';
import 'pin_lock_screen.dart';

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
  final bool showAppBar;

  const SettingsScreen({
    super.key,
    required this.controller,
    this.onThemeModeChanged,
    this.showAppBar = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadPinStatus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(l10n?.settingsTitle ?? 'الإعدادات العامة'))
          : null,
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

        // 3. Security Section
        _buildSectionHeader(theme, 'الأمان وقفل التطبيق'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.cardRadius,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: SwitchListTile(
              key: const Key('settings_pin_switch'),
              secondary: Icon(
                settings.isPinEnabled
                    ? Icons.lock_outline_rounded
                    : Icons.lock_open_rounded,
                color: settings.isPinEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: const Text('قفل التطبيق برمز PIN'),
              subtitle: Text(
                settings.isPinEnabled
                    ? 'الحماية مفعلة برمز مكون من 4 أرقام'
                    : 'حماية بياناتك وسجلاتك المالية محلياً',
              ),
              value: settings.isPinEnabled,
              onChanged: (enable) async {
                AppHaptics.selectionClick();
                if (enable) {
                  // Navigate to PIN creation
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => PinLockScreen(
                        mode: PinScreenMode.create,
                        setPinUseCase: widget.controller.setPinUseCase,
                        onSuccess: () {
                          widget.controller.loadPinStatus();
                          Navigator.of(ctx).pop();
                        },
                        onCancel: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  );
                } else {
                  // Navigate to PIN disable verification
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => PinLockScreen(
                        mode: PinScreenMode.disable,
                        verifyPinUseCase: widget.controller.verifyPinUseCase,
                        disablePinUseCase: widget.controller.disablePinUseCase,
                        onSuccess: () {
                          widget.controller.loadPinStatus();
                          Navigator.of(ctx).pop();
                        },
                        onCancel: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 4. Data Management Section
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
                  subtitle: const Text(
                    'حفظ ملف النسخة الاحتياطية في مجلد التطبيق',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: settings.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: settings.isBusy
                      ? null
                      : () => _handleExportBackup(context),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
          IconButton(
            key: const Key('settings_banner_dismiss_button'),
            icon: Icon(Icons.close, color: textColor, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'إغلاق',
            onPressed: () => widget.controller.clearNotificationAndError(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportBackup(BuildContext context) async {
    final jsonContent = await widget.controller.exportBackup();
    if (jsonContent != null && context.mounted) {
      File? savedFile;
      try {
        savedFile = await BackupFileManager.saveBackupFile(jsonContent);
      } catch (_) {
        // Handled gracefully in test / restricted environments
      }
      if (context.mounted && savedFile != null) {
        _showExportSuccessDialog(context, savedFile, jsonContent);
      }
    }
  }

  Future<void> _showExportSuccessDialog(
    BuildContext context,
    File file,
    String jsonContent,
  ) async {
    final fileName = p.basename(file.path);
    final filePath = file.path;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.emerald500),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('تم حفظ النسخة بنجاح')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم إنشاء ملف النسخة الاحتياطية وحفظه في مسار الجهاز:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    filePath,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text(
                      'نسخ المسار',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: filePath));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ مسار الملف إلى الحافظة'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.data_object, size: 16),
                    label: const Text(
                      'نسخ JSON',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: jsonContent));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ محتوى النسخة إلى الحافظة'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تم'),
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
    List<BackupFileInfo> backupFiles = [];
    bool fetched = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          if (!fetched) {
            fetched = true;
            BackupFileManager.listBackupFiles()
                .then((files) {
                  if (ctx.mounted) {
                    setState(() => backupFiles = files);
                  }
                })
                .catchError((_) {});
          }

          return AlertDialog(
            title: Text(l10n?.importBackup ?? 'استيراد نسخة احتياطية'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Strategy selector
                    const Text(
                      'استراتيجية الاستيراد:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    RadioGroup<ImportStrategy>(
                      groupValue: selectedStrategy,
                      onChanged: (val) {
                        if (val != null) setState(() => selectedStrategy = val);
                      },
                      child: Column(
                        children: const [
                          RadioListTile<ImportStrategy>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('دمج البيانات (Merge)'),
                            value: ImportStrategy.merge,
                          ),
                          RadioListTile<ImportStrategy>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('استبدال شامل (Replace)'),
                            value: ImportStrategy.replace,
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Discovered Files list
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ملفات النسخ على الجهاز:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: 'تحديث القائمة',
                          onPressed: () async {
                            final files =
                                await BackupFileManager.listBackupFiles();
                            if (ctx.mounted) {
                              setState(() => backupFiles = files);
                            }
                          },
                        ),
                      ],
                    ),
                    if (backupFiles.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            ctx,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: const Text(
                          'لم يتم العثور على ملفات احتياطية في مجلد SubTracker_Backups بعد.',
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(ctx).dividerColor),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: backupFiles.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (ctx, index) {
                            final fileInfo = backupFiles[index];
                            final dateStr =
                                '${fileInfo.modifiedAt.year}-${fileInfo.modifiedAt.month.toString().padLeft(2, '0')}-${fileInfo.modifiedAt.day.toString().padLeft(2, '0')} ${fileInfo.modifiedAt.hour.toString().padLeft(2, '0')}:${fileInfo.modifiedAt.minute.toString().padLeft(2, '0')}';
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.insert_drive_file,
                                size: 20,
                              ),
                              title: Text(
                                fileInfo.fileName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '$dateStr • ${fileInfo.formattedSize}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  try {
                                    final content =
                                        await BackupFileManager.readBackupFile(
                                          fileInfo.file,
                                        );
                                    await widget.controller.importBackup(
                                      content,
                                      strategy: selectedStrategy,
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('فشل قراءة الملف: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  'استيراد',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),

                    // Manual Paste Option
                    const Text(
                      'أو إدخال كود النسخة (JSON) يدوياً:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      key: const Key('settings_import_json_field'),
                      controller: textController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'الصق محتوى النسخة الاحتياطية هنا...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
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
                child: Text(l10n?.confirm ?? 'تأكيد الاستيراد اليدوي'),
              ),
            ],
          );
        },
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
