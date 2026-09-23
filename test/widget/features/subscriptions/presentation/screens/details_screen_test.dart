import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/localization/app_localizations.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/utils/result.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/category.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/payment_record.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/payment_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_payment_history_usecase.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/details_screen.dart';

class FakePaymentRepository implements PaymentRepository {
  List<PaymentRecord> recordsToReturn = [];

  @override
  Future<Result<List<PaymentRecord>>> getPaymentHistory(
    String subscriptionId,
  ) async {
    return Success(recordsToReturn);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SubscriptionDetailsScreen Widget Tests', () {
    late FakePaymentRepository fakePaymentRepo;
    late GetPaymentHistoryUseCase getPaymentHistoryUseCase;

    setUp(() {
      fakePaymentRepo = FakePaymentRepository();
      getPaymentHistoryUseCase = GetPaymentHistoryUseCase(fakePaymentRepo);
    });

    Widget createWidget({
      required Subscription subscription,
      Category? category,
      VoidCallback? onMarkPaid,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: SubscriptionDetailsScreen(
          subscription: subscription,
          category: category,
          getPaymentHistoryUseCase: getPaymentHistoryUseCase,
          onMarkPaid: onMarkPaid,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      );
    }

    testWidgets(
      'renders subscription details and empty payment notice when zero payments exist',
      (tester) async {
        final now = DateTime.now();
        final sub = Subscription.create(
          id: 'sub-new',
          name: 'Figma Pro',
          price: Money.create(amountMinorUnits: 1200, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: now.subtract(const Duration(days: 5)),
          dueDate: DueDate(now.add(const Duration(days: 25)), now.day),
          categoryId: 'cat-design',
        );

        final category = Category.create(
          id: 'cat-design',
          name: 'تصميم',
          colorValue: 0xFF6366F1,
          iconCode: 'design_services',
        );

        fakePaymentRepo.recordsToReturn = [];

        await tester.pumpWidget(
          createWidget(subscription: sub, category: category),
        );
        await tester.pumpAndSettle();

        expect(find.text('Figma Pro'), findsWidgets);
        expect(find.text('تصميم'), findsOneWidget);
        expect(find.text('لا توجد دفعات مسجلة بعد'), findsOneWidget);
        expect(find.text('لا توجد دفعات'), findsOneWidget);
      },
    );

    testWidgets('renders payment timeline history and total paid correctly', (
      tester,
    ) async {
      final now = DateTime.now();
      final sub = Subscription.create(
        id: 'sub-paid',
        name: 'GitHub Copilot',
        price: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: now.subtract(const Duration(days: 60)),
        dueDate: DueDate(now.add(const Duration(days: 25)), now.day),
        categoryId: 'cat-dev',
      );

      fakePaymentRepo.recordsToReturn = [
        PaymentRecord(
          id: 'pay-1',
          subscriptionId: 'sub-paid',
          amount: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          paidAt: now.subtract(const Duration(days: 30)),
          cycleType: 'monthly',
        ),
        PaymentRecord(
          id: 'pay-2',
          subscriptionId: 'sub-paid',
          amount: Money.create(amountMinorUnits: 1000, currencyCode: 'USD'),
          paidAt: now.subtract(const Duration(days: 1)),
          cycleType: 'monthly',
        ),
      ];

      await tester.pumpWidget(createWidget(subscription: sub));
      await tester.pumpAndSettle();

      expect(find.text('GitHub Copilot'), findsWidgets);
      expect(find.text('دفعتان'), findsOneWidget);
      expect(find.textContaining('الإجمالي:'), findsOneWidget);
      expect(find.textContaining('مسدد ✓'), findsNWidgets(2));
    });

    testWidgets('action buttons trigger corresponding callbacks', (
      tester,
    ) async {
      final now = DateTime.now();
      final sub = Subscription.create(
        id: 'sub-action',
        name: 'Netflix',
        price: Money.create(amountMinorUnits: 1500, currencyCode: 'USD'),
        cycle: const BillingCycle.monthly(),
        startDate: now.subtract(const Duration(days: 10)),
        dueDate: DueDate(now.add(const Duration(days: 20)), now.day),
        categoryId: 'cat-ent',
      );

      bool editTriggered = false;
      bool deleteTriggered = false;

      await tester.pumpWidget(
        createWidget(
          subscription: sub,
          onEdit: () => editTriggered = true,
          onDelete: () => deleteTriggered = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(editTriggered, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(deleteTriggered, isTrue);
    });
  });
}
