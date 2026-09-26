# هيكل المجلدات وتوزيع المسؤوليات (Project Structure)
## المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. الشجرة المعمارية للمشروع

```text
sub-tracker/
├── .agents/                               # موجهات وقواعد الوكيل الذكي والمهارات المثبتة
│   ├── mcp_config.json
│   ├── rules/                             # القواعد الإلزامية (codeguaid.md, skills-routing.md)
│   └── skills/                            # مهارات المعمارية والتطوير
│
├── .github/                               # تكوينات وأتمتة GitHub
│   ├── CODEOWNERS                         # مصفوفة ملاك الشيفرة وتوزيع المسؤوليات
│   ├── ISSUE_TEMPLATE/                    # قوالب المهام
│   ├── pull_request_template.md           # قالب طلبات الدمج (PR)
│   └── workflows/                         # سير العمل المؤتمت (ci.yml)
│
├── docs/                                  # المرجع الهندسي والوثائق الشاملة
│   ├── ARCHITECTURE.md                    # وثيقة المعمارية ونموذج البيانات والمخطط
│   ├── KANBAN_AND_GIT_WORKFLOW.md         # لوحة كانبان والبطاقات (C-01 إلى C-18)
│   ├── RISK_REGISTER.md                   # سجل المخاطر والاحتياطات الدفاعية
│   ├── SRS.md                             # مواصفات المتطلبات (FR-01..20, NFR-01..08)
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
│   │   └── utils/                         # الأدوات والمساعدات العامة (result.dart, app_haptics.dart)
│   │
│   └── features/                          # الميزات المقسمة وفق Clean Architecture
│       └── subscriptions/                 # ميزة إدارة الاشتراكات والفواتير
│           ├── domain/                    # طبقة الدومين (شيفرة Dart نقية 100%) - مسؤولية العيدروس
│           │   ├── entities/              # الكيانات (Subscription, Category, PriceHistoryEntry, etc.)
│           │   ├── failures/              # إخفاقات الدومين المحددة (subscription_failures.dart)
│           │   ├── repositories/          # واجهات المستودعات المجردة (Contracts)
│           │   ├── usecases/              # حالات الاستخدام المنسقة للعمليات (16 UseCase + 5 Analytics)
│           │   ├── validators/            # محركات التحقق والحساب (SubscriptionValidator, RecurrenceCalculator, etc.)
│           │   └── value_objects/         # كائنات القيمة غير القابلة للتغيير (Money, DueDate, BillingCycle, etc.)
│           │
│           ├── data/                      # طبقة البيانات والتخزين المحلي
│           │   ├── daos/                  # كائنات الوصول للبيانات (CategoryDao, SubscriptionDao, etc.)
│           │   ├── datasources/           # مصادر البيانات المحلية (Local Data Sources)
│           │   ├── models/                # نماذج التحويل ومطابقة الجداول (DTOs / Models)
│           │   ├── repositories/          # التنفيذ الفعلي لواجهات الدومين (Repository Implementations)
│           │   └── tables/                # تعريفات جداول Drift المستقلة
│           │
│           └── presentation/              # طبقة العرض والواجهات
│               ├── formatters/            # منسقات العملات والتواريخ
│               ├── screens/               # الشاشات الرئيسية بحالاتها الأربع
│               ├── state/                 # حائزي الحالة (Controllers)
│               └── widgets/               # المكونات والعناصر البصرية القابلة لإعادة الاستخدام
│
├── test/                                  # منظومة الاختبارات المؤتمتة (مطابقة لـ lib/ مساراً بمسار)
│   ├── unit/                              # اختبارات الوحدة (نواة، بيانات، دومين)
│   ├── widget/                            # اختبارات الواجهة والمكونات والحالات الأربع
│   └── integration/                       # اختبارات التكامل والمسارات الشاملة
│
└── mohammed aidrous/                      # مساحة التوثيق الخاصة بالمهندس محمد العيدروس
    ├── 00_project-understanding/          # فهم المشروع والمواصفات المعمارية
    ├── tasks/                             # التوثيق المرحلي للمهام (task-001 إلى task-004)
    └── README.md                          # فهرس التوثيق ودليل الملفات
```
