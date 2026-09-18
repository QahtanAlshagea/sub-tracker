# دليل تشغيل وتوجيه الفريق التنفيذي (Sub Tracker)
### كيف يعمل كل عضو في الفريق مع Antigravity و Git و Trello خطوة بخطوة

> **موجّه إلى:** قحطان الشاجع (قائد الفريق)، أواب النزيلي، مشعل حاجب، محمد العيدروس، محمد العواضي  
> **الأدوات المعتمدة:** Google Antigravity IDE (Gemini Coding Agent)، Git، GitHub، Trello

---

## 1. التوزيع الهندسي للمسؤوليات والطبقات

| العضو | المسار الهندسي في المشروع | البطاقات المسندة في Trello | حساب GitHub |
|---|---|---|---|
| **قحطان الشاجع** | المعمارية، الحوكمة، ملفات الوكيل، التوثيق، والمراجعة | `C-01` إلى `C-06` | `@QahtanAlshagea` |
| **محمد العيدروس** | طبقة الدومين، الكيانات، العقود، وحالات الاستخدام (`domain/`) | `C-07` إلى `C-10` | `@Eng-Mohammed-Al-aidrous` |
| **أواب النزيلي** | طبقة الواجهات ونظام التصميم وتجربة المستخدم (`presentation/`) | `C-15` إلى `C-17` | `@AWNO-1` |
| **محمد العواضي** | طبقة التخزين المحلي، قاعدة البيانات Drift والبيانات (`data/`) | `C-11` إلى `C-14` | `@dragongold2022-design` |
| **مشعل حاجب** | منظومة الاختبارات الشاملة ومصفوفة حالات الحافة (`test/`) | `C-18` | `@mshalhajep` |

---

## 2. خطوات إعداد بيئة العمل لكل عضو (تُنفَّذ مرة واحدة)

1. **تثبيت المتطلبات:**
   - التأكد من تثبيت Flutter SDK (الإصدار المستقر Stable) و Git على الجهاز.
   - تشغيل `flutter doctor` للتأكد من جاهزية بيئة Android.
2. **استنساخ المستودع (Clone):**
   يفتح العضو الطرفية (Terminal) في مجلد مشاريعه ويكتب:
   ```bash
   git clone https://github.com/QahtanAlshagea/sub-tracker.git
   cd sub-tracker
   ```
3. **فتح المشروع داخل Google Antigravity IDE:**
   - يفتح برنامج **Google Antigravity IDE**.
   - يختار **File** ← **Open Folder** ويحدد مجلد `sub-tracker`.
4. **التحقق من جاهزية المشروع:**
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```
   يجب أن يظهر `No issues found!` و `All tests passed!`.

---

## 3. الدورة اليومية لكل عضو لتنفيذ أي مهمة (خطوة بخطوة)

### الخطوة 1: اختيار المهمة من Trello
1. يفتح العضو لوحة Trello، وينتقل لبطاقته التالية في عمود **`Backlog`** أو **`Ready for Dev`**.
2. يسحب البطاقة إلى عمود **`In Progress`**.
3. يقرأ معايير القبول والاعتماديات الخاصة بالبطاقة.

### الخطوة 2: إنشاء فرع عمل جديد (Branch)
في طرفية Antigravity IDE، يتأكد العضو أنه على أحدث نسخة من `develop`:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/card-XX-short-name
```
*(مثال: `git checkout -b feature/c-07-domain-entities`)*.

### الخطوة 3: توجيه وكيل Antigravity (Gemini Coding Agent)
يفتح العضو نافذة الدردشة مع الوكيل في Antigravity ويكتب برومبت موجه بدقة بالصيغة التالية:

> **صيغة البرومبت المقترحة للعضو:**  
> «أنا العضو [فلان]، أعمل الآن على بطاقة **[C-XX]** بعنوان **[اسم البطاقة]**.  
> راجع أولاً: `GEMINI.md` و `.agents/rules/codeguaid.md` و `.agents/rules/skills-routing.md` ووثيقة المتطلبات `docs/SRS.md` لمتطلب `FR-XX` وقصة المستخدم `US-XX`.  
> طبّق مهارات: [المهارات المناسبة، مثل clean-architecture و dart-add-unit-test].  
> اعرض عليّ أولاً خطة العمل وعقد الاختبار (Test Contract) لحالات الحافة قبل كتابة أي شيفرة تنفيذية، والتزم بنقاء طبقة الدومين / حدود الطبقات.»

### الخطوة 4: حلقة التنفيذ الإلزامية للوكيل (المراقبة والمراجعة)
يتحقق العضو من أن الوكيل البرمجي ينفذ الخطوات التالية:
1. **الربط (Ground):** يعلن عن رقم المتطلب وقصة المستخدم وحالات الحافة `EC-XX`.
2. **عقد الاختبار (Test Contract):** يكتب أسماء حالات الاختبار أولاً تحت مجلد `test/`.
3. **التنفيذ (Implement):** يكتب الشيفرة في الملفات المخصصة ضمن مسار العضو حصراً.
4. **الفحص (Verify):** يشغّل أوامر الفحص ويتأكد من خلوها من الأخطاء:
   ```bash
   dart format --set-exit-if-changed .
   flutter analyze --fatal-infos
   flutter test
   ```
5. **التدقيق الذاتي (Self-Audit):** يجيب بـ YES على الأسئلة السبعة الإلزامية.

### الخطوة 5: حفظ التغييرات والرفع (Commit & Push)
بعد اكتمال المهمة ونجاح الاختبارات، يلتزم العضو بالتعديلات ويرفعها:
```bash
git add .
git commit -m "feat(domain): implement subscription entities and value objects

- Add SubscriptionEntity and Money value object
- Cover EC-01, EC-02 edge cases with unit tests

Refs #C-07"

git push -u origin feature/card-XX-short-name
```

### الخطوة 6: فتح طلب الدمج (Pull Request) وتحديث Trello
1. يذهب العضو إلى صفحة المستودع على GitHub:  
   `https://github.com/QahtanAlshagea/sub-tracker`
2. سيظهر زر أخضر **Compare & pull request**، يضغط عليه:
   - يتأكد أن الفرع الهدف (Base) هو **`develop`** وليس `main`.
   - يعبئ قالب الـ PR الموحد (يذكر رقم البطاقة، ملخص التغيير، وحالات الحافة المغطاة).
   - يعيّن المراجع المخصص (وفق ما هو محدد في `CODEOWNERS`).
   - يضغط **Create pull request**.
3. ينسخ رابط الـ PR ويذهب إلى بطاقته في Trello:
   - ينقل البطاقة إلى عمود **`Code Review`**.
   - يلصق رابط الـ PR في وصف البطاقة.

### الخطوة 7: المراجعة والدمج (Done)
1. يقوم المراجع (أو قائد الفريق قحطان) بمراجعة الكود وفحص نتائج CI.
2. بعد اعتماد الـ PR، يتم دمجه بخيار **Squash and merge**.
3. تُنقل البطاقة في Trello إلى عمود **`Done`** وتُحدّد جميع معايير الاكتمال.
