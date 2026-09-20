import 'package:flutter/material.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SubTrackerApp());
}

class SubTrackerApp extends StatelessWidget {
  const SubTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sub Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: const Scaffold(body: Center(child: Text('متتبع الاشتراكات'))),
    );
  }
}
