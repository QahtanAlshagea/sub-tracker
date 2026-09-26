# المعمارية النظيفة وهرم الاختبارات (Architecture & Testing Pyramid)
## مسؤول الجودة وهندسة الاختبارات: مشعل حاجب (Meshal Hajeb — @mshalhajep)

---

## 1. المعمارية المعتمدة (Clean Architecture)

يعتمد تطبيق **Sub Tracker** نموذج المعمارية النظيفة المكون من ثلاث طبقات معزولة تماماً، وتتجه فيها التبعيات إلى الداخل حصراً:

```text
┌─────────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER (العرض)                   │
│   Screens · Widgets · ViewState (Data/Loading/Empty/Error)  │
│   Controllers (MVVM) · fl_chart Visuals · Formatters        │
│   Imports: Domain Layer ONLY                                │
└──────────────────────────────┬──────────────────────────────┘
                               │ calls UseCases
┌──────────────────────────────▼──────────────────────────────┐
│           DOMAIN LAYER (النطاق — PURE DART 100%)            │
│   Entities · Value Objects (Money, Pin) · Failures          │
│   Repository Interfaces (Abstract Contracts) · UseCases     │
│   Imports: ZERO external packages (NO Flutter, NO Drift)    │
└──────────────────────────────▲──────────────────────────────┘
                               │ implements interfaces
┌──────────────────────────────┴──────────────────────────────┐
│                  DATA LAYER (البيانات والتخزين)              │
│   Drift Tables · DAOs · LocalDataSources · SQLite Engine    │
│   Models · Repository Implementations · Atomic Transactions │
│   Imports: Domain + Drift/SQLite                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. هرم الاختبارات المعتمد (Testing Pyramid)

تم تصميم منظومة الاختبارات وفق هرم الاختبارات القياسي في هندسة البرمجيات، لضمان السرعة والدقة والموثوقية العالية:

```text
                  ▲
                 / \
                /   \     Widget & Screen Tests (95 Tests)
               / UI  \    - فحص الحالات الأربع لكل شاشة (Data, Loading, Empty, Error)
              /-------\   - فحص التفاعل، التغذية اللمسية، وشريط التراجع
             /         \
            / Data/DAOs \ Data Layer Tests (88 Tests)
           /  (Drift)    \ - المعاملات الذرية All-or-Nothing والتراجع التلقائي
          /---------------\ - ترقية المخطط V1 إلى V2 وعزل أخطاء التخزين
         /                 \
        /    Pure Unit      \ Domain & Logic Tests (342 Tests)
       /    Tests (Dart)     \ - حسابات التقويم O(1)، تثبيت يوم التقويم
      /───────────────────────\ - منع تقريب الفاصلة العائمة (Minor Units)
```

---

## 3. تطبيق مبادئ SOLID من منظور ضمان الجودة والاختبارات

| المبدأ | التطبيق العملي في منظومة الاختبارات | آلية التحقق من الجودة |
|---|---|---|
| **S — Single Responsibility** | كل ملف اختبار يفحص صنفاً واحداً أو حالة حافة محددة بدقة. | عزل ملفات الاختبار تحت `test/unit/` و `test/widget/` لتعكس هيكل `lib/`. |
| **O — Open/Closed** | واجهات المستودعات مفتوحة للاستبدال ببدائل وهمية (Fakes/Mocks) ومغلقة عن التعديل. | بناء مستودعات الفحص التماثلية (`FakeSubscriptionRepository`, `FakeCategoryRepository`) لاختبارات الدومين السريعة دون اتصال بقاعدة بيانات. |
| **L — Liskov Substitution** | بدائل الفحص تحل تماماً وبدون أي أخطاء محل المستودعات الحقيقية. | اختبار حالات النجاح والفشل للـ UseCases عبر نفس العقد المجرد. |
| **I — Interface Segregation** | تقسيم الواجهات إلى عقود صغيرة ومستقلة (`SubscriptionRepository`, `PaymentRepository`, `SecurityRepository`). | منع كسر الاختبارات السابقة عند إضافة سجلات الدفعات أو قفل الأمان. |
| **D — Dependency Inversion** | حالات الاستخدام لا ترتبط بقاعدة البيانات؛ تعتمد على الواجهات المجردة. | اختبار كامل منطق الأعمال بدون تشغيل محرك SQLite أو الحاجة لبيئة نظام تشغيل. |

---

## 4. القواعد الحاكمة لجودة الكود وضمان استقراره

1. **نقاء طبقة الدومين (Domain Purity):**
   - حظر استيراد `package:flutter/*`, `package:drift/*`, `dart:io`, `dart:ui`.
   - يتم التحقق من ذلك آلياً في خط بناء CI لمنع أي تسريب تقني للطبقة الحيوية.
2. **الحالات الأربع الإلزامية لشاشات العرض (Four ViewStates):**
   - كل شاشة واجهة لابد وأن تمتلك تغطية اختبارية صريحة للحالات الأربع:
     1. `DataState`: عرض البيانات بشكل متناسق.
     2. `LoadingState`: مؤشر التحميل غير الحاجب للتفاعل.
     3. `EmptyState`: شاشة الفراغ الدلالية مع زر الإجراء.
     4. `ErrorState`: رسالة الخطأ العربية الواضحة مع زر إعادة المحاولة.
3. **سلامة الحسابات المالية (The Strict Money Rule):**
   - استخدام الوحدات الصغرى (`int`) بدقة 100%، وحظر `double` تماماً في الحسابات المالية لتجنب أخطاء التقريب العشري.
