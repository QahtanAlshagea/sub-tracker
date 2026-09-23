# نموذج قاعدة البيانات والتخزين المحلي (Database Overview)
## المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. مخطط الجداول والعلاقات في SQLite/Drift

```text
┌─────────────────────────────────┐
│           categories            │
├─────────────────────────────────┤
│ PK  id : TEXT                   │◀──────────────┐
│     name : TEXT [UNIQUE]        │               │
│     color_value : INTEGER       │               │
│     icon_code : TEXT?           │               │ 1:N (ON DELETE RESTRICT)
│     is_system : INTEGER         │               │
│     created_at : INTEGER        │               │
└─────────────────────────────────┘               │
                                                  │
┌─────────────────────────────────┐               │
│          subscriptions          │               │
├─────────────────────────────────┤               │
│ PK  id : TEXT                   │               │
│     name : TEXT                 │               │
│     price_minor_units : INTEGER │               │
│     currency_code : TEXT        │               │
│     cycle_type : TEXT           │               │
│     custom_cycle_days : INT?    │               │
│     start_date : INTEGER        │               │
│     next_due_date : INTEGER     │               │
│     original_anchor_day : INT   │               │
│ FK  category_id : TEXT          │───────────────┘
│     status : TEXT               │
│     is_trial : INTEGER          │
│     notes : TEXT?               │
│     renewal_url : TEXT?         │
│     payment_method_desc : TEXT? │
│     reminder_enabled : INTEGER  │
│     reminder_lead_days : INT    │
│     reminder_time_hour : INT    │
│     reminder_time_minute : INT  │
│     created_at : INTEGER        │
│     updated_at : INTEGER        │
│     deleted_at : INTEGER?       │
│     archived_at : INTEGER?      │
└────────────────┬────────────────┘
                 │
                 │ 1:N (ON DELETE CASCADE)
                 ▼
┌─────────────────────────────────┐
│          price_history          │
├─────────────────────────────────┤
│ PK  id : TEXT                   │
│ FK  subscription_id : TEXT      │
│     old_price_minor_units : INT │
│     new_price_minor_units : INT │
│     currency_code : TEXT        │
│     changed_at : INTEGER        │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│            settings             │ (Singleton Table)
├─────────────────────────────────┤
│ PK  id : TEXT ('app_settings')  │
│     theme_mode : TEXT           │
│     default_currency : TEXT     │
│     default_reminder_days : INT │
│     default_reminder_hour : INT │
│     default_reminder_minute: INT│
│     default_sort_order : TEXT   │
│     last_backup_at : INTEGER?   │
│     schema_version : INTEGER    │
│     updated_at : INTEGER        │
└─────────────────────────────────┘
```

---

## 2. انعكاس نموذج البيانات على كائنات الدومين
كجزء من مساهمة طبقة الدومين، قمنا بتعريف الكيانات وكائنات القيمة المستقلة التي ترتبط بهذا النموذج عبر نماذج تحويل البيانات ثنائية الاتجاه (Bidirectional Models في طبقة البيانات):
- **`Money`:** يرتبط بحقلي `price_minor_units` و `currency_code`.
- **`BillingCycle`:** يرتبط بحقلي `cycle_type` و `custom_cycle_days`.
- **`DueDate`:** يرتبط بحقلي `next_due_date` و `original_anchor_day`.
- **`Subscription`:** الكيان المجمع الذي يحتوي على كافة بيانات الاشتراك دون معرفة تفاصيل SQLite.
- **`Category`:** كيان الفئة المستقل.
- **`PriceHistoryEntry`:** سجل التغيرات في السعر.
