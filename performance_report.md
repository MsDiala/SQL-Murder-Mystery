# Performance Report — SQL Murder Mystery Index Investigation

**Student Name:** Hashem Al-Qurashi
**Date:** March 31, 2026
**Database:** `sql-murder-mystery.db` (SQLite)

---

## Summary Table

| Query | Baseline (ms) | Indexed (ms) | Improvement | Index Used? |
|-------|--------------|-------------|-------------|-------------|
| Q1 — Murders in SQL City | High | Low | Excellent | Yes (idx_crime_city_type) |
| Q2 — People + license details | High | Low | Good | Yes (idx_person_license_id) |
| Q3 — Gym check-ins Jan 9 | High | Low | Excellent | Yes (idx_checkin_date) |
| Q4 — Gold members + income | High | Low | Good | Yes (idx_member_status) |
| Q5 — Facebook events 2018 | High | Low | Good | Yes (idx_facebook_date) |
| Q6 — Red-haired Tesla drivers | High | Low | Excellent | Yes (idx_license_hair_car) |
| Q7 — Interview keyword search | High | High | None | No (LIKE wildcard) |
| Q8 — Income by car make | High | Medium | Fair | Partial (idx_person_license_id) |

---

## 1. Queries That Improved the Most

الاستعلامات Q1، Q3، و Q6 شهدت أكبر تحسن. السبب هو تحول نوع البحث من **SCAN TABLE** (القراءة الكاملة للجدول) إلى **SEARCH TABLE** باستخدام الفهارس. الفهرس سمح للقاعدة بالوصول المباشر للبيانات المطلوبة بناءً على المدينة أو التاريخ أو مواصفات السيارة بدلاً من فحص كل سجل يدويّاً.

---

## 2. Queries That Did NOT Improve

الاستعلام Q7 لم يتحسن إطلاقاً. السبب هو استخدام معامل `LIKE '%...%'`. في SQL، عندما يبدأ البحث بـ `%` (wildcard)، لا تستطيع قاعدة البيانات استخدام الفهرس العادي وتضطر لعمل **Full Scan** للبحث عن النص داخل كل السجلات.

---

## 3. Tradeoffs of Indexing

- **السرعة:** الفهارس تسرّع عمليات `SELECT` و `JOIN` بشكل هائل لأنها تعمل كخريطة طريق.
- **البطء:** الفهارس تبطئ عمليات `INSERT` و `UPDATE` لأن القاعدة تضطر لتحديث الفهرس مع كل تغيير في البيانات.
- **المساحة:** كل فهرس ننشئه يستهلك مساحة إضافية على القرص الصلب.
- **لماذا لا نفهرس كل شيء؟** لأن كثرة الفهارس تستهلك موارد النظام وتجعل عمليات إدخال البيانات بطيئة جداً وتأخذ مساحة تخزينية بلا فائدة حقيقية.

---

## 4. Production Recommendation

في قاعدة بيانات حقيقية، أوصي بالإبقاء على `idx_crime_city_type` و `idx_person_license_id` لأنها أعمدة يتم البحث فيها باستمرار. أما بالنسبة لـ Q7، فقد أقترح استخدام نظام "Full Text Search" (FTS) بدلاً من الفهارس العادية لتحسين البحث النصي.

---

*© 2026 LevelUp Economy. All rights reserved.*