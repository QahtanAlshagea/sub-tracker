import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/accessibility/accessibility_widgets.dart';
import 'package:sub_tracker/core/theme/app_theme.dart';
import 'package:sub_tracker/core/theme/tokens/app_spacing.dart';

void main() {
  group('Accessibility & Text Scaling 200% Tests (NFR-04, NFR-08, US-40)', () {
    testWidgets(
      '[EC-40-1] & [EC-38-3] Layout scales to 200% text scale without overflow or clipping',
      (WidgetTester tester) async {
        // Set standard mobile screen dimensions
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Build widget tree with 200% text scale factor (TextScaler.linear(2.0))
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0), // 200% scale
              ),
              child: Scaffold(
                appBar: AppBar(title: const Text('اشتراكاتي')),
                body: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'خدمة البث السحابي الممتازة للاشتراك الشهري',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const AccessibleStatusBadge(
                                  type: StatusBadgeType.dueSoon,
                                ),
                              ],
                            ),
                            AppSpacing.gapVerticalMd,
                            const Text(
                              '45.00 ر.س / شهرياً',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpacing.gapVerticalSm,
                            const Text(
                              'تاريخ الاستحقاق: 25 سبتمبر 2026',
                              style: TextStyle(fontSize: 12.0),
                            ),
                            AppSpacing.gapVerticalMd,
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('تسديد الآن'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify no RenderFlex errors were thrown and elements are rendered properly
        expect(tester.takeException(), isNull);
        expect(find.text('اشتراكاتي'), findsOneWidget);
        expect(find.text('تسديد الآن'), findsOneWidget);
        expect(find.text('مستحق قريباً'), findsOneWidget);
      },
    );

    testWidgets(
      '[EC-40-3] Color Blindness: Status badges ALWAYS pair color with text and icon',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: Column(
                children: [
                  AccessibleStatusBadge(type: StatusBadgeType.active),
                  AccessibleStatusBadge(type: StatusBadgeType.paid),
                  AccessibleStatusBadge(type: StatusBadgeType.dueSoon),
                  AccessibleStatusBadge(type: StatusBadgeType.overdue),
                  AccessibleStatusBadge(type: StatusBadgeType.trial),
                  AccessibleStatusBadge(type: StatusBadgeType.cancelled),
                  AccessibleStatusBadge(type: StatusBadgeType.archived),
                ],
              ),
            ),
          ),
        );

        // Verify each badge has its explicit semantic text
        expect(find.text('نشط'), findsOneWidget);
        expect(find.text('مسدّد'), findsOneWidget);
        expect(find.text('مستحق قريباً'), findsOneWidget);
        expect(find.text('متأخر'), findsOneWidget);
        expect(find.text('تجربة مجانية'), findsOneWidget);
        expect(find.text('ملغى'), findsOneWidget);
        expect(find.text('مؤرشف'), findsOneWidget);

        // Verify each badge has an associated semantic Icon
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.done_all), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.byIcon(Icons.stars_outlined), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
        expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'NFR-04 MinTouchTarget ensures interactive area is at least 48x48 dp',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: MinTouchTarget(
                  onTap: () {},
                  child: const Icon(Icons.close, size: 16.0),
                ),
              ),
            ),
          ),
        );

        final targetFinder = find.byType(MinTouchTarget);
        final targetSize = tester.getSize(targetFinder);

        expect(
          targetSize.width,
          greaterThanOrEqualTo(AppSpacing.touchTargetMin),
        );
        expect(
          targetSize.height,
          greaterThanOrEqualTo(AppSpacing.touchTargetMin),
        );
      },
    );

    testWidgets(
      'NFR-08 RTL Support: Directionality propagates from right to left properly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: Row(children: [Text('الأول'), Spacer(), Text('الأخير')]),
              ),
            ),
          ),
        );

        final firstRect = tester.getRect(find.text('الأول'));
        final lastRect = tester.getRect(find.text('الأخير'));

        // In RTL, "الأول" must be on the right side of "الأخير"
        expect(firstRect.left, greaterThan(lastRect.left));
      },
    );
  });
}
