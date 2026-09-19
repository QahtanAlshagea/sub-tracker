# توثيق مهام Awab Alnozili — Sub Tracker

مرحباً بك في مساحة التوثيق الخاصة بالمهندس **أواب النزيلي (Awab Alnozili)** في مشروع **Sub Tracker**.

هذا المجلد مخصص لحفظ كافة مراحل التوثيق الهندسي، والخطط، والتحليلات، وتقارير الاختبار، والتغييرات المتعلقة بالمهام المكلف بها أواب في المشروع.

---

## هيكل المجلد

```text
awab alnozili/
│
├── 00_project-understanding/          # توثيق الفهم الشامل للمشروع (المرحلة 0)
│   ├── project-overview.md            # نظرة عامة على النظام والمشكلة والمستخدمين
│   ├── architecture.md                # المعمارية المعتمدة وتدفق البيانات وقواعد SOLID
│   ├── technology-stack.md            # التقنيات والمكتبات المستخدمة فعلياً
│   ├── project-structure.md           # هيكل المجلدات والملفات ودور كل منها
│   ├── database-overview.md           # نموذج البيانات ومخطط SQLite/Drift والقواعد المالية
│   └── important-notes.md             # الملاحظات الحرجة والديون التقنية والحدود الصارمة
│
├── tasks/                             # مجلد المهام التنفيذية المستقلة
│   ├── task-001/                      # مثال لهيكل كل مهمة قادمة
│   │   ├── 01-task-request.md
│   │   ├── 02-analysis.md
│   │   ├── 03-plan.md
│   │   ├── 04-before-state.md
│   │   ├── 05-implementation.md
│   │   ├── 06-after-state.md
│   │   ├── 07-testing.md
│   │   ├── 08-changes-summary.md
│   │   └── 09-issues-and-notes.md
│   └── ...
│
└── README.md                          # دليل المجلد (هذا الملف)
```

---

## مبادئ العمل المعتمدة

1. **دورة العمل الإلزامية:**
   $$\text{READ} \rightarrow \text{UNDERSTAND} \rightarrow \text{ANALYZE} \rightarrow \text{DOCUMENT BEFORE} \rightarrow \text{PLAN} \rightarrow \text{IMPLEMENT} \rightarrow \text{TEST} \rightarrow \text{REVIEW} \rightarrow \text{DOCUMENT AFTER} \rightarrow \text{FINAL REPORT}$$
2. **عزل المهام:** كل مهمة مستقلة تماماً في توثيقها واختباراتها دون خلط.
3. **أقل تغيير ممكن (Minimal Changes):** الحفاظ على استقرار المشروع المشترك ومنع الآثار الجانبية.
4. **نقاء طبقة الدومين (Domain Purity):** صفر تبعيات خارجية في `domain/`.
5. **التحقق الصارم:** لا يُعتبر أي عمل منجزاً إلا بعد اجتياز الفحوصات الآلية والاختبارات بنجاح 100%.
