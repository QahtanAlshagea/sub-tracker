import 'package:flutter/material.dart';
import 'core/database/app_database.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/subscriptions/data/datasources/backup_local_data_source.dart';
import 'features/subscriptions/data/datasources/category_local_data_source.dart';
import 'features/subscriptions/data/datasources/subscription_local_data_source.dart';
import 'features/subscriptions/data/repositories/backup_repository_impl.dart';
import 'features/subscriptions/data/repositories/category_repository_impl.dart';
import 'features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/export_backup_usecase.dart';
import 'features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'features/subscriptions/domain/usecases/get_category_distribution_usecase.dart';
import 'features/subscriptions/domain/usecases/get_highest_cost_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/get_monthly_summary_usecase.dart';
import 'features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'features/subscriptions/domain/usecases/get_upcoming_projections_usecase.dart';
import 'features/subscriptions/domain/usecases/import_backup_usecase.dart';
import 'features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'features/subscriptions/presentation/screens/add_edit_screen.dart';
import 'features/subscriptions/presentation/screens/home_screen.dart';
import 'features/subscriptions/presentation/screens/settings_screen.dart';
import 'features/subscriptions/presentation/screens/summary_screen.dart';
import 'features/subscriptions/presentation/state/add_edit_subscription_controller.dart';
import 'features/subscriptions/presentation/state/settings_controller.dart';
import 'features/subscriptions/presentation/state/subscriptions_list_controller.dart';
import 'features/subscriptions/presentation/state/summary_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Local Persistence Layer
  final database = AppDatabase();
  final subLocalDataSource = SubscriptionLocalDataSourceImpl(
    database.subscriptionDao,
  );
  final catLocalDataSource = CategoryLocalDataSourceImpl(database.categoryDao);
  final backupLocalDataSource = BackupLocalDataSourceImpl(database);

  final subRepository = SubscriptionRepositoryImpl(subLocalDataSource);
  final catRepository = CategoryRepositoryImpl(catLocalDataSource);
  final backupRepository = BackupRepositoryImpl(backupLocalDataSource);

  // 2. Domain Layer UseCases
  final getSubscriptionsUseCase = GetSubscriptionsUseCase(subRepository);
  final renewSubscriptionUseCase = RenewSubscriptionUseCase(subRepository);
  final getCategoriesUseCase = GetCategoriesUseCase(catRepository);
  final createSubscriptionUseCase = CreateSubscriptionUseCase(subRepository);
  final updateSubscriptionUseCase = UpdateSubscriptionUseCase(subRepository);
  final getSubscriptionByIdUseCase = GetSubscriptionByIdUseCase(subRepository);

  final getMonthlySummaryUseCase = GetMonthlySummaryUseCase(subRepository);
  final getUpcomingProjectionsUseCase = GetUpcomingProjectionsUseCase(
    subRepository,
  );
  final getCategoryDistributionUseCase = GetCategoryDistributionUseCase(
    subscriptionRepository: subRepository,
    categoryRepository: catRepository,
  );
  final getHighestCostSubscriptionUseCase = GetHighestCostSubscriptionUseCase(
    subRepository,
  );

  final exportBackupUseCase = ExportBackupUseCase(backupRepository);
  final importBackupUseCase = ImportBackupUseCase(backupRepository);

  // 3. Presentation MVVM Controllers
  final subscriptionsListController = SubscriptionsListController(
    getSubscriptionsUseCase: getSubscriptionsUseCase,
    renewSubscriptionUseCase: renewSubscriptionUseCase,
    getCategoriesUseCase: getCategoriesUseCase,
  );

  final summaryController = SummaryController(
    getMonthlySummaryUseCase: getMonthlySummaryUseCase,
    getUpcomingProjectionsUseCase: getUpcomingProjectionsUseCase,
    getCategoryDistributionUseCase: getCategoryDistributionUseCase,
    getHighestCostSubscriptionUseCase: getHighestCostSubscriptionUseCase,
  );

  final settingsController = SettingsController(
    exportBackupUseCase: exportBackupUseCase,
    importBackupUseCase: importBackupUseCase,
    backupRepository: backupRepository,
  );

  runApp(
    SubTrackerApp(
      subscriptionsListController: subscriptionsListController,
      summaryController: summaryController,
      settingsController: settingsController,
      createSubscriptionUseCase: createSubscriptionUseCase,
      updateSubscriptionUseCase: updateSubscriptionUseCase,
      getSubscriptionByIdUseCase: getSubscriptionByIdUseCase,
      getCategoriesUseCase: getCategoriesUseCase,
    ),
  );
}

class SubTrackerApp extends StatefulWidget {
  final SubscriptionsListController subscriptionsListController;
  final SummaryController summaryController;
  final SettingsController settingsController;
  final CreateSubscriptionUseCase createSubscriptionUseCase;
  final UpdateSubscriptionUseCase updateSubscriptionUseCase;
  final GetSubscriptionByIdUseCase getSubscriptionByIdUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  const SubTrackerApp({
    super.key,
    required this.subscriptionsListController,
    required this.summaryController,
    required this.settingsController,
    required this.createSubscriptionUseCase,
    required this.updateSubscriptionUseCase,
    required this.getSubscriptionByIdUseCase,
    required this.getCategoriesUseCase,
  });

  @override
  State<SubTrackerApp> createState() => _SubTrackerAppState();
}

class _SubTrackerAppState extends State<SubTrackerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _navigateToAddEdit(
    BuildContext context, {
    String? subscriptionId,
  }) async {
    final addEditController = AddEditSubscriptionController(
      createSubscriptionUseCase: widget.createSubscriptionUseCase,
      updateSubscriptionUseCase: widget.updateSubscriptionUseCase,
      getSubscriptionByIdUseCase: widget.getSubscriptionByIdUseCase,
      getCategoriesUseCase: widget.getCategoriesUseCase,
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddEditSubscriptionScreen(
          controller: addEditController,
          subscriptionId: subscriptionId,
        ),
      ),
    );

    if (result == true) {
      widget.subscriptionsListController.loadSubscriptions();
      widget.summaryController.loadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sub Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: Builder(
        builder: (ctx) => HomeScreen(
          controller: widget.subscriptionsListController,
          summaryTab: SummaryScreen(
            controller: widget.summaryController,
            onAddSubscription: () => _navigateToAddEdit(ctx),
          ),
          settingsTab: SettingsScreen(
            controller: widget.settingsController,
            onThemeModeChanged: _onThemeModeChanged,
          ),
          onAddSubscription: () => _navigateToAddEdit(ctx),
          onSubscriptionTap: (sub) =>
              _navigateToAddEdit(ctx, subscriptionId: sub.id),
        ),
      ),
    );
  }
}
