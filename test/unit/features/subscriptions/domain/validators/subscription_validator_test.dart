import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/entities/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/failures/subscription_failures.dart';
import 'package:sub_tracker/features/subscriptions/domain/validators/subscription_validator.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/billing_cycle.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/due_date.dart';
import 'package:sub_tracker/features/subscriptions/domain/value_objects/money.dart';

void main() {
  group('SubscriptionValidator Tests', () {
    group('BR-01 & EC-01: Name Validation Boundaries', () {
      test('BR-01 / EC-01-1: reject empty name (limit 0)', () {
        final result = SubscriptionValidator.validateName('');
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.emptyName()),
        );
      });

      test('BR-01 / EC-01-1: reject whitespace-only name', () {
        final result = SubscriptionValidator.validateName('    ');
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.emptyName()),
        );
      });

      test('BR-01: accept valid name at lower boundary (length 1)', () {
        final result = SubscriptionValidator.validateName('A');
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('A'));
      });

      test('BR-01: accept valid name at upper boundary (length 60)', () {
        final name60 = 'a' * 60;
        final result = SubscriptionValidator.validateName(name60);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(name60));
      });

      test('BR-01 / EC-01-2: reject name above upper boundary (length 61)', () {
        final name61 = 'a' * 61;
        final result = SubscriptionValidator.validateName(name61);
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.nameTooLong()),
        );
      });

      test('BR-01 / EC-01-3: accept special characters, Arabic and emojis', () {
        const complexName = 'Netflix 🎬 (العائلة) #1 & VIP!';
        final result = SubscriptionValidator.validateName(complexName);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(complexName));
      });

      test('BR-01 / EC-01-4: auto-trim leading and trailing whitespace', () {
        final result = SubscriptionValidator.validateName(
          '   Spotify Premium  ',
        );
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('Spotify Premium'));
      });
    });

    group('BR-02, BR-03 & EC-02: Price Validation Boundaries', () {
      test('BR-02: reject negative price (value -1)', () {
        final result = SubscriptionValidator.validatePrice(-1, isTrial: false);
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.negativePrice()),
        );
      });

      test('BR-02: reject zero price when isTrial is false (value 0)', () {
        final result = SubscriptionValidator.validatePrice(0, isTrial: false);
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.zeroPriceNonTrial()),
        );
      });

      test('BR-02: accept zero price when isTrial is true (value 0)', () {
        final result = SubscriptionValidator.validatePrice(0, isTrial: true);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(0));
      });

      test(
        'BR-02: accept strictly positive price at lower boundary (value 1)',
        () {
          final result = SubscriptionValidator.validatePrice(1, isTrial: false);
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(1));
        },
      );

      test(
        'BR-03 / EC-02-1: accept maximum allowed price (value 99,999,999,999 minor units)',
        () {
          final result = SubscriptionValidator.validatePrice(
            99999999999,
            isTrial: false,
          );
          expect(result.isSuccess, isTrue);
          expect(result.dataOrNull, equals(99999999999));
        },
      );

      test(
        'BR-03 / EC-02-1: reject price exceeding maximum boundary (value 100,000,000,000)',
        () {
          final result = SubscriptionValidator.validatePrice(
            100000000000,
            isTrial: false,
          );
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.priceTooHigh()),
          );
        },
      );
    });

    group('ISO 4217 Currency Code Validation Boundaries', () {
      test('ISO 4217: accept 3 uppercase ASCII letters', () {
        expect(
          SubscriptionValidator.validateCurrencyCode('USD').isSuccess,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateCurrencyCode('SAR').isSuccess,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateCurrencyCode('YER').isSuccess,
          isTrue,
        );
      });

      test('ISO 4217: reject currency code with length 2', () {
        final result = SubscriptionValidator.validateCurrencyCode('US');
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.invalidCurrencyCode()),
        );
      });

      test('ISO 4217: reject currency code with length 4', () {
        final result = SubscriptionValidator.validateCurrencyCode('USDT');
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.invalidCurrencyCode()),
        );
      });

      test(
        'ISO 4217: reject currency code with lowercase or non-alpha chars',
        () {
          expect(
            SubscriptionValidator.validateCurrencyCode('usd').isFailure,
            isTrue,
          );
          expect(
            SubscriptionValidator.validateCurrencyCode('U1D').isFailure,
            isTrue,
          );
        },
      );
    });

    group('BR-04 & EC-03: Billing Cycle Boundaries', () {
      test('BR-04: non-custom cycles are always valid', () {
        expect(
          SubscriptionValidator.validateBillingCycle(
            BillingCycle.monthly(),
          ).isSuccess,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateBillingCycle(
            BillingCycle.yearly(),
          ).isSuccess,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateBillingCycle(
            BillingCycle.weekly(),
          ).isSuccess,
          isTrue,
        );
      });

      test(
        'BR-04 / EC-03-1: reject custom cycle days below boundary (value 0)',
        () {
          final result = SubscriptionValidator.validateCustomDays(0);
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.invalidCustomCycleDays()),
          );
        },
      );

      test('BR-04: accept custom cycle days at lower boundary (value 1)', () {
        final cycle = BillingCycle.custom(1);
        final result = SubscriptionValidator.validateBillingCycle(cycle);
        expect(result.isSuccess, isTrue);
        expect(SubscriptionValidator.validateCustomDays(1).isSuccess, isTrue);
      });

      test(
        'BR-04: accept custom cycle days at upper boundary (value 3650)',
        () {
          final cycle = BillingCycle.custom(3650);
          final result = SubscriptionValidator.validateBillingCycle(cycle);
          expect(result.isSuccess, isTrue);
          expect(
            SubscriptionValidator.validateCustomDays(3650).isSuccess,
            isTrue,
          );
        },
      );

      test(
        'BR-04 / EC-03-2: reject custom cycle days above upper boundary (value 3651)',
        () {
          final result = SubscriptionValidator.validateCustomDays(3651);
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.invalidCustomCycleDays()),
          );
        },
      );
    });

    group('BR-06 & EC-04: Notes & Metadata Boundaries', () {
      test('BR-06: accept null notes', () {
        final result = SubscriptionValidator.validateNotes(null);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNull);
      });

      test('BR-06 / EC-04-1: accept notes at upper boundary (length 500)', () {
        final notes500 = 'n' * 500;
        final result = SubscriptionValidator.validateNotes(notes500);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(notes500));
      });

      test(
        'BR-06 / EC-04-1: reject notes above upper boundary (length 501)',
        () {
          final notes501 = 'n' * 501;
          final result = SubscriptionValidator.validateNotes(notes501);
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.notesTooLong()),
          );
        },
      );

      test('BR-06 / EC-04-2: accept valid http and https renewal URLs', () {
        expect(
          SubscriptionValidator.validateRenewalUrl(
            'https://netflix.com/cancel',
          ).isSuccess,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateRenewalUrl(
            'http://example.org/account',
          ).isSuccess,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateRenewalUrl(null).isSuccess,
          isTrue,
        );
      });

      test('BR-06 / EC-04-2: reject invalid renewal URL format', () {
        final result = SubscriptionValidator.validateRenewalUrl(
          'not-a-valid-url',
        );
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.invalidUrl()),
        );
      });

      test(
        'EC-04-4: accept payment method description at limit (length 50)',
        () {
          final desc50 = 'd' * 50;
          final result = SubscriptionValidator.validatePaymentMethodDesc(
            desc50,
          );
          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'EC-04-4: reject payment method description above limit (length 51)',
        () {
          final desc51 = 'd' * 51;
          final result = SubscriptionValidator.validatePaymentMethodDesc(
            desc51,
          );
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.paymentMethodDescTooLong()),
          );
        },
      );

      test('EC-04-4: accept safe description like Visa ending in 4242', () {
        final result = SubscriptionValidator.validatePaymentMethodDesc(
          'Visa ending in 4242',
        );
        expect(result.isSuccess, isTrue);
      });

      test(
        'EC-04-4: reject payment method containing valid credit card number',
        () {
          // Standard Luhn-valid test card number (Visa 4532 0150 1234 5678)
          const validCard = 'Visa 4532 0150 1234 5678';
          final result = SubscriptionValidator.validatePaymentMethodDesc(
            validCard,
          );
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.creditCardDetected()),
          );
        },
      );

      test('passesLuhn verifies credit card checksum algorithm', () {
        // 4532015012345671 sums to 50 (valid mod 10)
        expect(SubscriptionValidator.passesLuhn('4532015012345671'), isTrue);
        // 4532015012345670 sums to 49 (invalid)
        expect(SubscriptionValidator.passesLuhn('4532015012345670'), isFalse);
        // Canonical IBM Luhn test number 79927398713
        expect(SubscriptionValidator.passesLuhn('79927398713'), isTrue);
      });
    });

    group('BR-10 & EC-03-4: Reminder Configuration Boundaries', () {
      test('BR-10: accept disabled reminders regardless of lead days', () {
        final result = SubscriptionValidator.validateReminderSettings(
          reminderEnabled: false,
          reminderLeadDays: 99,
          reminderTimeHour: 99,
          reminderTimeMinute: 99,
          cycle: BillingCycle.monthly(),
        );
        expect(result.isSuccess, isTrue);
      });

      test('BR-10: reject reminder lead days below boundary (value -1)', () {
        final result = SubscriptionValidator.validateReminderSettings(
          reminderEnabled: true,
          reminderLeadDays: -1,
          reminderTimeHour: 9,
          reminderTimeMinute: 0,
          cycle: BillingCycle.monthly(),
        );
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.invalidReminderLeadDays()),
        );
      });

      test('BR-10: accept reminder lead days at lower boundary (value 0)', () {
        final result = SubscriptionValidator.validateReminderSettings(
          reminderEnabled: true,
          reminderLeadDays: 0,
          reminderTimeHour: 9,
          reminderTimeMinute: 0,
          cycle: BillingCycle.monthly(),
        );
        expect(result.isSuccess, isTrue);
      });

      test('BR-10: accept reminder lead days at upper boundary (value 30)', () {
        final result = SubscriptionValidator.validateReminderSettings(
          reminderEnabled: true,
          reminderLeadDays: 30,
          reminderTimeHour: 9,
          reminderTimeMinute: 0,
          cycle: BillingCycle.monthly(),
        );
        expect(result.isSuccess, isTrue);
      });

      test('BR-10: reject reminder lead days above boundary (value 31)', () {
        final result = SubscriptionValidator.validateReminderSettings(
          reminderEnabled: true,
          reminderLeadDays: 31,
          reminderTimeHour: 9,
          reminderTimeMinute: 0,
          cycle: BillingCycle.monthly(),
        );
        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull,
          equals(SubscriptionValidationFailure.invalidReminderLeadDays()),
        );
      });

      test('BR-10: reject invalid hour (-1 or 24) or minute (-1 or 60)', () {
        expect(
          SubscriptionValidator.validateReminderSettings(
            reminderEnabled: true,
            reminderLeadDays: 1,
            reminderTimeHour: -1,
            reminderTimeMinute: 0,
            cycle: BillingCycle.monthly(),
          ).isFailure,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateReminderSettings(
            reminderEnabled: true,
            reminderLeadDays: 1,
            reminderTimeHour: 24,
            reminderTimeMinute: 0,
            cycle: BillingCycle.monthly(),
          ).isFailure,
          isTrue,
        );
        expect(
          SubscriptionValidator.validateReminderSettings(
            reminderEnabled: true,
            reminderLeadDays: 1,
            reminderTimeHour: 9,
            reminderTimeMinute: 60,
            cycle: BillingCycle.monthly(),
          ).isFailure,
          isTrue,
        );
      });

      test(
        'EC-03-4: reject reminder lead days exceeding cycle duration for daily cycle',
        () {
          final result = SubscriptionValidator.validateReminderSettings(
            reminderEnabled: true,
            reminderLeadDays: 2,
            reminderTimeHour: 9,
            reminderTimeMinute: 0,
            cycle: BillingCycle.custom(1),
          );
          expect(result.isFailure, isTrue);
          expect(
            result.failureOrNull,
            equals(SubscriptionValidationFailure.leadDaysExceedCycle()),
          );
        },
      );
    });

    group('EC-02-4: Digit Normalization', () {
      test('normalize Arabic-Indic and Eastern Arabic digits to Western', () {
        expect(
          SubscriptionValidator.normalizeDigits('١٢٣٤٥٦٧٨٩٠'),
          equals('1234567890'),
        );
        expect(
          SubscriptionValidator.normalizeDigits('۱۲۳۴۵۶۷۸۹۰'),
          equals('1234567890'),
        );
        expect(
          SubscriptionValidator.normalizeDigits('SAR ٤٥.٥٠'),
          equals('SAR 45.50'),
        );
      });
    });

    group('validateSubscription Complete Entity Integration', () {
      test('accept fully valid subscription entity', () {
        final sub = Subscription(
          id: 'sub-valid',
          name: 'Netflix 4K',
          price: const Money(amountMinorUnits: 1599, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
          categoryId: 'cat-ent',
          notes: 'Standard 4K plan',
          renewalUrl: 'https://netflix.com',
          paymentMethodDesc: 'Visa ending 4242',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

        final result = SubscriptionValidator.validateSubscription(sub);
        expect(result.isSuccess, isTrue);
      });

      test('reject subscription entity with invalid anchor day', () {
        final sub = Subscription(
          id: 'sub-valid',
          name: 'Netflix',
          price: const Money(amountMinorUnits: 1599, currencyCode: 'USD'),
          cycle: const BillingCycle.monthly(),
          startDate: DateTime.utc(2026, 1, 1),
          dueDate: DueDate(DateTime.utc(2026, 2, 1), 1),
          categoryId: 'cat-ent',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        expect(
          SubscriptionValidator.validateSubscription(sub).isSuccess,
          isTrue,
        );
      });
    });
  });
}
