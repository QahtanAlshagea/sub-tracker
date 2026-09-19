# هيكل المشروع ومسؤوليات المجلدات (Project Structure)

## 1. شجرة المجلدات الكلية

```text
sub-tracker/
├── .agents/                               # موجهات وقواعد الوكيل الذكي والمهارات المثبتة
│   ├── mcp_config.json
│   ├── rules/                             # القواعد الإلزامية وتوجيه المهارات (codeguaid.md, skills-routing.md)
│   └── skills/                            # مهارات المعمارية والتطوير (clean-architecture, etc.)
│
├── .github/                               # تكوينات وأتمتة GitHub
│   ├── CODEOWNERS                         # مصفوفة ملاك الشيفرة وتوزيع المسؤوليات
│   ├── ISSUE_TEMPLATE/                    # قوالب البلاغات والمهام
│   ├── pull_request_template.md           # قالب طلبات الدمج (PR)
│   └── workflows/                         # سير العمل المؤتمت (ci.yml)
│
├── docs/                                  # المرجع الهندسي والوثائق الشاملة
│   ├── ARCHITECTURE.md                    # وثيقة المعمارية ونموذج البيانات والمخطط
│   ├── KANBAN_AND_GIT_WORKFLOW.md         # لوحة كانبان والبطاقات (C-01 إلى C-18)
│   ├── RISK_REGISTER.md                   # سجل المخاطر والاحتياطات الدفاعية
│   ├── SRS.md                             # وثيقة مواصفات المتطلبات (FR-01..20, NFR-01..08)
│   ├── TEAM_LEAD_GITHUB_GUIDE.md          # دليل تأسيس المستودع وحماية الفروع
│   ├── TEST_PLAN.md                       # خطة الاختبار ومعايير التغطية
│   └── USER_STORIES.md                    # قصص المستخدم وحالات الحافة (US-01..40, EC-01..144)
│
├── lib/                                   # الشيفرة المصدرية للتطبيق (Flutter / Dart)
│   ├── main.dart                          # نقطة دخول التطبيق
│   ├── core/                              # النواة المشتركة عبر الوحدات
│   │   ├── constants/                     # الثوابت العامة
│   │   ├── database/                      # إعدادات محرك SQLite/Drift وجداول النواة
│   │   ├── di/                            # جذر التركيب وحقن التبعيات (Composition Root)
│   │   ├── error/                         # أصناف الفشل الأساسية (failures.dart)
│   │   ├── theme/                         # أنظمة الألوان والخطوط والرموز التصميمية
│   │   ├── usecase/                       # العقود العامة لحالات الاستخدام (UseCase, StreamUseCase)
│   │   └── utils/                         # الأدوات والمساعدات العامة (result.dart)
│   │
│   └── features/                          # الميزات المقسمة وفق Clean Architecture
│       └── subscriptions/                 # ميزة إدارة الاشتراكات والفواتير
│           ├── domain/                    # طبقة الدومين (شيفرة Dart نقية 100%)
│           │   ├── entities/              # الكيانات (Subscription, Category, PriceHistoryEntry)
│           │   ├── failures/              # إخفاقات الدومين المحددة (subscription_failures.dart)
│           │   ├── repositories/          # واجهات المستودعات المجردة (Contracts)
│           │   ├── usecases/              # حالات الاستخدام المنسقة للعمليات
│           │   ├── validators/            # محركات التحقق والحساب (SubscriptionValidator, RecurrenceCalculator, etc.)
│           │   └── value_objects/         # كائنات القيمة غير القابلة للتغيير (Money, DueDate, BillingCycle, etc.)
│           │
│           ├── data/                      # طبقة البيانات والتخزين المحلي
│           │   ├── daos/                  # كائنات الوصول للبيانات (Data Access Objects)
│           │   ├── datasources/           # مصادر البيانات المحلية (Local Data Sources)
│           │   ├── models/                # نماذج التحويل ومطابقة الجداول (DTOs / Models)
│           │   ├── repositories/          # التنفيذ الفعلي لواجهات الدومين (Repository Implementations)
│           │   └── tables/                # تعريفات جداول Drift المستقلة
│           │
│           └── presentation/              # طبقة العرض والواجهات
│               ├── formatters/            # منسقات العملات والتواريخ والنصوص بحسب لغة الجهاز
│               ├── screens/               # الشاشات الرئيسية بحالاتها الأربع
│               ├── state/                 # حائزي الحالة (State Notifiers / BLoCs / Controllers)
│               └── widgets/               # المكونات والعناصر البصرية القابلة لإعادة الاستخدام
│
├── test/                                  # منظومة الاختبارات المؤتمتة (مطابقة لـ lib/ مساراً بمسار)
│   ├── unit/                              # اختبارات الوحدة
│   │   ├── core/                          # اختبارات نواة النظام
│   │   ├── data/                          # اختبارات طبقة البيانات
│   │   ├── domain/                        # اختبارات الدومين العامة
│   │   └── features/                      # اختبارات ميزات النظام
│   │       └── subscriptions/domain/      # اختبارات الكيانات وكائنات القيمة والمحركات ومطابقة حالات الحافة
│   ├── widget/                            # اختبارات الواجهة والعناصر البصرية
│   └── integration/                       # اختبارات التكامل وسيناريوهات التدفق الكاملة
│
├── tool/                                  # نصوص وأدوات التطوير والصيانة
├── awab alnozili/                         # مجلد التوثيق الخاص بالمهندس أواب النزيلي
│   ├── 00_project-understanding/          # وثائق الفهم المرجعية
│   ├── tasks/                             # التوثيق والخطط والتقارير لكل مهمة على حدة
│   └── README.md                          # دليل المجلد
│
├── AI_Log.md                              # سجل شفافية استخدام أدوات الذكاء الاصطناعي
├── GEMINI.md                              # موجه السياق المعماري الجذري للأدوات الذكية
├── README.md                              # الدليل التعريفي العام بالمستودع
├── analysis_options.yaml                  # قواعد التحليل الساكن لـ Flutter
├── pubspec.yaml                           # تعريف المشروع والتبعيات الأساسية
└── pubspec.lock                           # قفل إصدارات الحزم
```

---

## 2. مصفوفة تطابق الاختبارات مع الشيفرة (Mirroring Rule)

تتبع منظومة الاختبارات قاعدة هندسية صارمة:
**كل ملف داخل `lib/` يقابله ملف اختبار بالاسم ذاته مع لاحقة `_test.dart` داخل `test/` في نفس المسار المناظر.**

أمثلة من الوضع الحالي:
- `lib/features/subscriptions/domain/entities/subscription.dart` $\rightarrow$ `test/unit/features/subscriptions/domain/entities/subscription_test.dart`
- `lib/features/subscriptions/domain/validators/subscription_validator.dart` $\rightarrow$ `test/unit/features/subscriptions/domain/validators/subscription_validator_test.dart`
- `lib/features/subscriptions/domain/value_objects/money.dart` $\rightarrow$ `test/unit/features/subscriptions/domain/value_objects/money_test.dart`
