# الدليل التوجيهي لقائد الفريق — قحطان الشاجع
## تأسيس المستودع وحوكمة الفرع الرئيسي ولوحة المشروع

> هذا الدليل خاص بقائد الفريق. ينفَّذ **مرة واحدة** في بداية المشروع، وخطواته مرتبة ولا يجوز القفز فوق أي منها.

---

## المرحلة 1 — إنشاء المستودع على GitHub

1. من الصفحة الرئيسية لـ GitHub اضغط **+** ← **New repository**.
2. **Repository name:** `sub-tracker`
3. **Description:** `Offline-first Flutter subscription & recurring bill manager — Software Engineering Lab 1`
4. **Visibility:** Private (أو Public حسب تعليمات المقرر).
5. **لا تفعّل** خيار «Add a README» إن كان لديك مشروع محلي جاهز، تفادياً لتعارض التاريخ.
6. اضغط **Create repository** واحتفظ برابط المستودع.

## المرحلة 2 — ربط المشروع المحلي ورفعه

```bash
cd "Sub Tracker"

# تأكد أن ملف .gitignore الخاص بـ Flutter موجود قبل أول التزام
git init
git add .
git commit -m "chore: initialize Sub Tracker repository with docs and agent rules"
git branch -M main
git remote add origin https://github.com/<اسم-المستخدم>/sub-tracker.git
git push -u origin main

# إنشاء فرع التطوير المشترك
git checkout -b develop
git push -u origin develop
```

## المرحلة 3 — إضافة أعضاء الفريق

1. **Settings** ← **Collaborators and teams** ← **Add people**.
2. أضف: أواب النزيلي، مشعل حاجب، محمد العيدروس، محمد العواضي.
3. **الصلاحية:** `Write` للجميع — **لا تمنح أحداً `Admin`**، فذلك يسمح بتجاوز الحماية.
4. عيّن **محمد العواضي** كمراجع افتراضي عبر ملف `CODEOWNERS` (المرحلة 6).

## المرحلة 4 — ضبط الفرع الافتراضي

1. **Settings** ← **General** ← **Default branch**.
2. اجعل الفرع الافتراضي `develop` حتى تُفتح طلبات الدمج تلقائياً عليه لا على `main`.

## المرحلة 5 — قواعد حماية الفرع الرئيسي (أهم خطوة)

**Settings** ← **Branches** ← **Add branch protection rule** (أو **Rulesets** في الواجهة الحديثة).

### القاعدة الأولى: حماية `main`

| الخيار | الضبط المطلوب | السبب |
|---|---|---|
| Branch name pattern | `main` | تحديد الفرع المحمي |
| Require a pull request before merging | ✅ مفعّل | منع الدفع المباشر نهائياً |
| Require approvals | ✅ العدد: **1** على الأقل (2 للمهام المعمارية) | ضمان المراجعة |
| Dismiss stale pull request approvals when new commits are pushed | ✅ مفعّل | لا تُعتمد موافقة على كود تغيّر بعدها |
| Require review from Code Owners | ✅ مفعّل | إلزام مراجعة المسؤول عن الملف |
| Require status checks to pass before merging | ✅ مفعّل + اختر `analyze` و`test` | منع دمج كود راسب |
| Require branches to be up to date before merging | ✅ مفعّل | منع التعارضات الصامتة |
| Require conversation resolution before merging | ✅ مفعّل | لا تُترك ملاحظة مراجعة معلّقة |
| Require linear history | ✅ مفعّل | تاريخ نظيف عبر Squash merge |
| Do not allow bypassing the above settings | ✅ مفعّل | القاعدة تسري على القائد نفسه أيضاً |
| Allow force pushes | ❌ معطّل | منع إعادة كتابة التاريخ |
| Allow deletions | ❌ معطّل | منع حذف الفرع الرئيسي |

### القاعدة الثانية: حماية `develop`

كرّر الخطوات نفسها بنمط `develop`، مع الإبقاء على: طلب دمج إلزامي، موافقة واحدة، ونجاح الفحوص. يمكن تخفيف «linear history» هنا فقط.

### التحقق من نجاح الضبط

```bash
git checkout main
echo "test" >> README.md
git commit -am "test: should be rejected"
git push origin main
# النتيجة المتوقعة: remote: error: GH006: Protected branch update failed
```
ظهور رسالة الرفض يعني أن الحماية تعمل. ثم تراجع:
```bash
git reset --hard origin/main
```

## المرحلة 6 — ملف CODEOWNERS

أنشئ الملف `.github/CODEOWNERS` بالمحتوى التالي (مع استبدال المعرّفات بمعرّفات GitHub الحقيقية):

```
# المراجعة الافتراضية لكل شيء
*                                   @qahtan @awab-qa

# الدومين والعقود
/lib/features/*/domain/             @awab

# التخزين المحلي
/lib/features/*/data/               @mishal

# الواجهات وتجربة المستخدم
/lib/features/*/presentation/       @mohammed-aidroos

# الاختبارات
/test/                              @mohammed-alawadhi

# الحوكمة والمعمارية وملفات الوكيل
/docs/                              @qahtan
/.agents/                           @qahtan
/GEMINI.md                          @qahtan
```

## المرحلة 7 — إنشاء لوحة المشروع وربط المهام

1. **Projects** ← **New project** ← قالب **Board** باسم `Sub Tracker – Lab 1 Board`.
2. أنشئ الأعمدة: `Backlog`، `Ready for Dev`، `In Progress`، `Code Review (PR)`، `Testing/QA`، `Done`.
3. أضف الحقول المخصصة: `Priority`، `Story Points`، `Type`.
4. أنشئ الـ Issues الثمانية عشر من `docs/KANBAN_AND_GIT_WORKFLOW.md` (C-01 إلى C-18) بعناوينها ووصفها ومسؤوليها ولصائقها.
5. من **Workflows** فعّل: `Item added to project → Backlog`، `Pull request opened → Code Review`، `Issue closed → Done`.

## المرحلة 8 — اللصائق (Labels) الموحّدة

**Issues** ← **Labels** ← أنشئ: `architecture`، `domain`، `data`، `ui`، `qa`، `docs`، `setup`، `governance`، `ci`، `blocked`، `critical`، `good-first-task`.

## المرحلة 9 — قوالب الـ Issue و الـ Pull Request

أنشئ `.github/pull_request_template.md` بالمحتوى الوارد في `docs/KANBAN_AND_GIT_WORKFLOW.md` §3.6، و`.github/ISSUE_TEMPLATE/task.md` بالحقول: العنوان، المتطلب المرتبط (FR/US)، الوصف، الاعتماديات، معايير القبول، تعريف الإنجاز.

## المرحلة 10 — التكامل المستمر

أنشئ `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  pull_request:
    branches: [ main, develop ]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - name: analyze
        run: flutter analyze --fatal-infos
      - name: test
        run: flutter test --coverage
```

ثم عد إلى **Branches** وأضف `verify` ضمن **Required status checks**.

---

## قائمة تحقق القائد قبل انطلاق التنفيذ

- [ ] المستودع منشور وجميع الأعضاء مضافون بصلاحية `Write` فقط.
- [ ] الفرعان `main` و`develop` موجودان ومحميّان.
- [ ] محاولة الدفع المباشر على `main` تُرفض فعلياً (تم اختبارها).
- [ ] ملف `CODEOWNERS` فعّال ويظهر المراجع تلقائياً في أي PR.
- [ ] لوحة المشروع منشأة بالأعمدة الستة والـ 18 بطاقة.
- [ ] اللصائق والقوالب جاهزة.
- [ ] التكامل المستمر يعمل وإلزامي قبل الدمج.
- [ ] الوثائق (`SRS`, `USER_STORIES`, `KANBAN_AND_GIT_WORKFLOW`) مدموجة في `main`.
- [ ] ملفات الوكيل (`GEMINI.md`, `codeguaid.md`, `skills-routing.md`, `mcp_config.json`) مدموجة ومفعّلة.
- [ ] `AI_Log.md` منشأ وبدأ الفريق بتعبئته.
- [ ] شرحتَ لكل عضو دورته اليومية في Git وتأكدت من تنفيذه لها مرة واحدة تجريبياً.
