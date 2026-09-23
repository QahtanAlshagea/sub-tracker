import 'package:flutter/material.dart';
import 'core/database/app_database.dart' hide Subscription;
import 'core/localization/app_localizations.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/usecase/usecase.dart';
import 'features/subscriptions/data/datasources/backup_local_data_source.dart';
import 'features/subscriptions/data/datasources/category_local_data_source.dart';
import 'features/subscriptions/data/datasources/payment_local_data_source.dart';
import 'features/subscriptions/data/datasources/security_local_data_source.dart';
import 'features/subscriptions/data/datasources/subscription_local_data_source.dart';
import 'features/subscriptions/data/repositories/backup_repository_impl.dart';
import 'features/subscriptions/data/repositories/category_repository_impl.dart';
import 'features/subscriptions/data/repositories/payment_repository_impl.dart';
import 'features/subscriptions/data/repositories/security_repository_impl.dart';
import 'features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'features/subscriptions/domain/entities/subscription.dart';
import 'features/subscriptions/domain/usecases/create_category_usecase.dart';
import 'features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/disable_pin_usecase.dart';
import 'features/subscriptions/domain/usecases/export_backup_usecase.dart';
import 'features/subscriptions/domain/usecases/get_categories_usecase.dart';
import 'features/subscriptions/domain/usecases/get_category_distribution_usecase.dart';
import 'features/subscriptions/domain/usecases/get_highest_cost_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/get_monthly_summary_usecase.dart';
import 'features/subscriptions/domain/usecases/get_payment_history_usecase.dart';
import 'features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import 'features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import 'features/subscriptions/domain/usecases/get_upcoming_projections_usecase.dart';
import 'features/subscriptions/domain/usecases/import_backup_usecase.dart';
import 'features/subscriptions/domain/usecases/is_pin_enabled_usecase.dart';
import 'features/subscriptions/domain/usecases/move_subscription_to_trash_usecase.dart';
import 'features/subscriptions/domain/usecases/record_payment_usecase.dart';
import 'features/subscriptions/domain/usecases/renew_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/restore_subscription_from_trash_usecase.dart';
import 'features/subscriptions/domain/usecases/set_pin_usecase.dart';
import 'features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import 'features/subscriptions/domain/usecases/verify_pin_usecase.dart';
import 'features/subscriptions/presentation/screens/add_edit_screen.dart';
import 'features/subscriptions/presentation/screens/details_screen.dart';
import 'features/subscriptions/presentation/screens/home_screen.dart';
import 'features/subscriptions/presentation/screens/pin_lock_screen.dart';
import 'features/subscriptions/presentation/screens/settings_screen.dart';
import 'features/subscriptions/presentation/screens/summary_screen.dart';
import 'features/subscriptions/presentation/state/add_edit_subscription_controller.dart';
import 'features/subscriptions/presentation/state/settings_controller.dart';
import 'features/subscriptions/presentation/state/subscriptions_list_controller.dart';
import 'features/subscriptions/presentation/state/summary_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Local Persistence Layer
  final database = AppDatabase();
  await database.ensureDefaultCategories();

  final subLocalDataSource = SubscriptionLocalDataSourceImpl(
    database.subscriptionDao,
  );
  final catLocalDataSource = CategoryLocalDataSourceImpl(database.categoryDao);
  final backupLocalDataSource = BackupLocalDataSourceImpl(database);
  final paymentLocalDataSource = PaymentLocalDataSourceImpl(database);

  final subRepository = SubscriptionRepositoryImpl(subLocalDataSource);
  final catRepository = CategoryRepositoryImpl(catLocalDataSource);
  final backupRepository = BackupRepositoryImpl(backupLocalDataSource);
  final paymentRepository = PaymentRepositoryImpl(paymentLocalDataSource);

  final securityLocalDataSource = SecurityLocalDataSourceImpl(
    database.settingsDao,
  );
  final securityRepository = SecurityRepositoryImpl(securityLocalDataSource);

  // 2. Domain Layer UseCases
  final getSubscriptionsUseCase = GetSubscriptionsUseCase(subRepository);
  final renewSubscriptionUseCase = RenewSubscriptionUseCase(subRepository);
  final moveSubscriptionToTrashUseCase = MoveSubscriptionToTrashUseCase(
    subRepository,
  );
  final restoreSubscriptionFromTrashUseCase =
      RestoreSubscriptionFromTrashUseCase(subRepository);
  final getCategoriesUseCase = GetCategoriesUseCase(catRepository);
  final createCategoryUseCase = CreateCategoryUseCase(catRepository);
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

  final getPaymentHistoryUseCase = GetPaymentHistoryUseCase(paymentRepository);
  final recordPaymentUseCase = RecordPaymentUseCase(paymentRepository);

  final exportBackupUseCase = ExportBackupUseCase(backupRepository);
  final importBackupUseCase = ImportBackupUseCase(backupRepository);

  final isPinEnabledUseCase = IsPinEnabledUseCase(securityRepository);
  final verifyPinUseCase = VerifyPinUseCase(securityRepository);
  final setPinUseCase = SetPinUseCase(securityRepository);
  final disablePinUseCase = DisablePinUseCase(securityRepository);

  final pinStatusRes = await isPinEnabledUseCase(const NoParams());
  final initialPinLocked = pinStatusRes.dataOrNull ?? false;

  // 3. Local Device Notification Service
  final notificationService = NotificationServiceImpl();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // 4. Presentation MVVM Controllers
  final subscriptionsListController = SubscriptionsListController(
    getSubscriptionsUseCase: getSubscriptionsUseCase,
    renewSubscriptionUseCase: renewSubscriptionUseCase,
    getCategoriesUseCase: getCategoriesUseCase,
    moveSubscriptionToTrashUseCase: moveSubscriptionToTrashUseCase,
    restoreSubscriptionFromTrashUseCase: restoreSubscriptionFromTrashUseCase,
    paymentRepository: paymentRepository,
    recordPaymentUseCase: recordPaymentUseCase,
    notificationService: notificationService,
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
    isPinEnabledUseCase: isPinEnabledUseCase,
    setPinUseCase: setPinUseCase,
    disablePinUseCase: disablePinUseCase,
    verifyPinUseCase: verifyPinUseCase,
    autoDismissDuration: const Duration(seconds: 4),
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
      createCategoryUseCase: createCategoryUseCase,
      getPaymentHistoryUseCase: getPaymentHistoryUseCase,
      verifyPinUseCase: verifyPinUseCase,
      notificationService: notificationService,
      isInitialPinLocked: initialPinLocked,
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
  final CreateCategoryUseCase createCategoryUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;
  final VerifyPinUseCase verifyPinUseCase;
  final NotificationService? notificationService;
  final bool isInitialPinLocked;

  const SubTrackerApp({
    super.key,
    required this.subscriptionsListController,
    required this.summaryController,
    required this.settingsController,
    required this.createSubscriptionUseCase,
    required this.updateSubscriptionUseCase,
    required this.getSubscriptionByIdUseCase,
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.getPaymentHistoryUseCase,
    required this.verifyPinUseCase,
    this.notificationService,
    this.isInitialPinLocked = false,
  });

  @override
  State<SubTrackerApp> createState() => _SubTrackerAppState();
}

class _SubTrackerAppState extends State<SubTrackerApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.isInitialPinLocked;
  }

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
      createCategoryUseCase: widget.createCategoryUseCase,
      notificationService: widget.notificationService,
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

  void _navigateToDetails(BuildContext context, Subscription sub) async {
    final category =
        widget.subscriptionsListController.categoriesById[sub.categoryId];

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => SubscriptionDetailsScreen(
          subscription: sub,
          category: category,
          getPaymentHistoryUseCase: widget.getPaymentHistoryUseCase,
          onMarkPaid: () async {
            await widget.subscriptionsListController.markAsPaid(sub.id);
            widget.summaryController.loadSummary();
          },
          onEdit: () {
            Navigator.pop(ctx);
            _navigateToAddEdit(context, subscriptionId: sub.id);
          },
          onDelete: () async {
            Navigator.pop(ctx);
            await widget.subscriptionsListController.deleteSubscription(sub.id);
            widget.summaryController.loadSummary();
          },
        ),
      ),
    );

    // Refresh lists upon return
    widget.subscriptionsListController.loadSubscriptions();
    widget.summaryController.loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متتبع الدفعات الدورية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar'),
      home: _isLocked
          ? PinLockScreen(
              mode: PinScreenMode.unlock,
              verifyPinUseCase: widget.verifyPinUseCase,
              onSuccess: () {
                setState(() {
                  _isLocked = false;
                });
              },
            )
          : Builder(
              builder: (ctx) => HomeScreen(
                controller: widget.subscriptionsListController,
                summaryTab: SummaryScreen(
                  controller: widget.summaryController,
                  onAddSubscription: () => _navigateToAddEdit(ctx),
                  showAppBar: false,
                ),
                settingsTab: SettingsScreen(
                  controller: widget.settingsController,
                  onThemeModeChanged: _onThemeModeChanged,
                  showAppBar: false,
                ),
                onAddSubscription: () => _navigateToAddEdit(ctx),
                onSubscriptionTap: (sub) => _navigateToDetails(ctx, sub),
              ),
            ),
    );
  }
}
