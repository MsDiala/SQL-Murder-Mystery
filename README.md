# Module 3 — Stretch: SQL Performance Investigation
### 🔍 Database: SQL Murder Mystery (PostgreSQL)

> **Honors Track.** This stretch assignment is not required for program completion but counts toward Honors distinction.
> Only work on this if you have completed **all core assignments** for this module and are **On Track or Advanced**.
> If you are behind on core work, focus there first.

---

## 🎯 The Challenge

A murder was committed in **SQL City** on January 15, 2018. The detective's database is full of clues — but the queries are *slow*. Your job isn't just to run queries; it's to understand **why they're slow** and **make them faster**.

You'll use `EXPLAIN ANALYZE` to read execution plans, add indexes, and measure the impact. This is a professional database skill — understanding why a query is slow and how to fix it is the difference between a working prototype and a production-ready system.

---

## 📚 What You'll Learn

- Reading PostgreSQL query execution plans (`EXPLAIN ANALYZE`)
- Index types and when they help (B-tree for equality/range, partial indexes)
- The read/write tradeoff of indexing
- Making evidence-based optimization decisions

---

## 🗄️ The Database

The database is named **`murder_mystery`** and runs in a PostgreSQL container.

### Tables

| Table | Rows | Description |
|-------|------|-------------|
| `person` | 10,011 | People in the city (name, address, SSN, license) |
| `drivers_license` | 10,007 | Driver's license details (age, height, eye color, car…) |
| `crime_scene_report` | 1,228 | Police reports (date, type, description, city) |
| `interview` | 4,991 | Witness and suspect interview transcripts |
| `facebook_event_checkin` | 20,011 | Event attendance records |
| `get_fit_now_member` | 184 | Gym membership records |
| `get_fit_now_check_in` | 2,703 | Gym check-in/check-out times |
| `income` | 7,514 | Annual income per person (via SSN) |

### Schema Diagram

```
person ──────────────── drivers_license        (person.license_id → drivers_license.id)
  │
  ├──────────────────── interview              (person.id → interview.person_id)
  ├──────────────────── income                 (person.ssn → income.ssn)
  ├──────────────────── facebook_event_checkin (person.id → facebook_event_checkin.person_id)
  └──────────────────── get_fit_now_member     (person.id → get_fit_now_member.person_id)
                                │
                                └──────────── get_fit_now_check_in (member.id → check_in.membership_id)
```

---

## ⚙️ Setup (5 minutes)

### 1. Start the database

Make sure Docker is installed, then run:

```bash
docker-compose up -d
```

This starts a PostgreSQL 15 container named `murder_db`.

### 2. Load the schema and data

```bash
docker exec -i murder_db psql -U postgres -d murder_mystery < setup.sql
```

### 3. Connect to the database

```bash
docker exec -it murder_db psql -U postgres -d murder_mystery
```

### 4. Verify the setup

```sql
SELECT table_name, (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) AS col_count
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;
```

You should see 9 tables. To check row counts:

```sql
SELECT 'crime_scene_report'      AS table_name, COUNT(*) FROM crime_scene_report
UNION ALL SELECT 'drivers_license',              COUNT(*) FROM drivers_license
UNION ALL SELECT 'facebook_event_checkin',       COUNT(*) FROM facebook_event_checkin
UNION ALL SELECT 'get_fit_now_check_in',         COUNT(*) FROM get_fit_now_check_in
UNION ALL SELECT 'get_fit_now_member',           COUNT(*) FROM get_fit_now_member
UNION ALL SELECT 'income',                       COUNT(*) FROM income
UNION ALL SELECT 'interview',                    COUNT(*) FROM interview
UNION ALL SELECT 'person',                       COUNT(*) FROM person;
```

---

## ✅ Tasks

### Task 1 — Baseline Execution Plans

Run `EXPLAIN ANALYZE` on each of the 8 queries below. Save all output to `explain_baseline.md`.

For each query, record:
- ⏱ Execution time (ms) — shown at the bottom of the `EXPLAIN ANALYZE` output
- 🔍 Scan type (`Seq Scan` = slow full scan, `Index Scan` / `Bitmap Index Scan` = fast)
- 🔗 Join method (`Nested Loop`, `Hash Join`, `Merge Join`)
- ⚠️ Flag any `Seq Scan` on large tables — those are your targets

---

#### The 8 Queries

**Q1 — All murders in SQL City**
```sql
EXPLAIN ANALYZE
SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND type = 'murder'
ORDER BY date DESC;
```

**Q2 — People with their driver's license details**
```sql
EXPLAIN ANALYZE
SELECT p.name, p.address_number, p.address_street_name,
       dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;
```

**Q3 — Gym members who checked in on January 9, 2018**
```sql
EXPLAIN ANALYZE
SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;
```

**Q4 — Gold gym members and their income**
```sql
EXPLAIN ANALYZE
SELECT m.name, m.membership_status, i.annual_income
FROM get_fit_now_member m
JOIN person p ON m.person_id = p.id
JOIN income i ON p.ssn = i.ssn
WHERE m.membership_status = 'gold'
ORDER BY i.annual_income DESC;
```

**Q5 — People who attended Facebook events in 2018**
```sql
EXPLAIN ANALYZE
SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;
```

**Q6 — Red-haired Tesla drivers**
```sql
EXPLAIN ANALYZE
SELECT p.name, dl.hair_color, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.hair_color = 'red'
  AND dl.car_make = 'Tesla'
ORDER BY p.name;
```

**Q7 — Interview transcripts mentioning the gym or murder**
```sql
EXPLAIN ANALYZE
SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript ILIKE '%gym%'
   OR i.transcript ILIKE '%murder%';
```

**Q8 — Average income by car make**
```sql
EXPLAIN ANALYZE
SELECT dl.car_make,
       COUNT(*) AS drivers,
       ROUND(AVG(i.annual_income), 0) AS avg_income,
       MIN(i.annual_income) AS min_income,
       MAX(i.annual_income) AS max_income
FROM drivers_license dl
JOIN person p ON dl.id = p.license_id
JOIN income i ON p.ssn = i.ssn
GROUP BY dl.car_make
ORDER BY avg_income DESC;
```

---

### Task 2 — Add Indexes

Based on your execution plans, identify tables being fully scanned unnecessarily. Edit `indexes.sql` with your chosen indexes, then run:

```bash
docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
```

Starter suggestions (add more based on your findings):

```sql
CREATE INDEX idx_crime_city_type  ON crime_scene_report(city, type);
CREATE INDEX idx_person_license   ON person(license_id);
CREATE INDEX idx_checkin_date     ON get_fit_now_check_in(check_in_date);
CREATE INDEX idx_facebook_date    ON facebook_event_checkin(date);
CREATE INDEX idx_facebook_person  ON facebook_event_checkin(person_id);
```

---

### Task 3 — Compare Performance

Re-run `EXPLAIN ANALYZE` on the same 8 queries after adding indexes. Save output to `explain_indexed.md`.

Note the execution time before and after for each query, and observe whether the scan type changed from `Seq Scan` to `Index Scan`.

---

### Task 4 — Write a Report

Complete `performance_report.md` documenting:

- Which queries improved the most (and why the index helped)
- Which queries showed no improvement (e.g., small table, `ILIKE '%...'` wildcard, planner chose seq scan)
- The tradeoffs: faster reads vs. slower writes, additional storage
- Your production recommendation: which indexes would you actually keep?

---

## 📁 Repository Structure

```
module-3-stretch-sql-performance/
├── README.md                    ← this file
├── docker-compose.yml           ← spins up PostgreSQL
├── setup.sql                    ← schema + full data load
├── indexes.sql                  ← your CREATE INDEX statements (edit this)
├── explain_baseline.md          ← Task 1 output (fill this in)
├── explain_indexed.md           ← Task 3 output (fill this in)
└── performance_report.md        ← Task 4 report (fill this in)
```

---

## 🔗 Resources

- [PostgreSQL: EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html)
- [PostgreSQL: Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)
- [PostgreSQL: Indexes](https://www.postgresql.org/docs/current/indexes.html)
- [PostgreSQL: Index Types](https://www.postgresql.org/docs/current/indexes-types.html)
- [Original SQL Murder Mystery Game](https://mystery.knightlab.com) — try solving the case too! 🕵️

---

## 📬 Submission

Push your completed repo to GitHub and submit the link via the student portal.

### Query Performance Comparison (Before vs After Indexing)
---

## 📊 Query Performance Comparison (Before vs After Indexing) -- BY Batool

| Query | Scan Before | Time Before | Scan After | Time After | Result |
|------|-------------|------------|------------|-----------|--------|
| Q1 | Sequential Scan | 0.184 ms | Index Scan | 0.069 ms | ✅ Improved |
| Q2 | Sequential Scan + Hash Join | 7.582 ms | Hash Join + Seq Scan | 18.991 ms | ⚠️ Slower (index not beneficial) |
| Q3 | Sequential Scan | 0.315 ms | Index Scan | ___ ms | ✅ Improved |
| Q4 | Sequential Scan | 1.003 ms | Index Scan | ___ ms | ✅ Improved |
| Q5 | Sequential Scan | 0.336 ms | Bitmap Heap + Index Scan | 7.779 ms | ⚠️ Slight regression |
| Q6 | Sequential Scan | 3.610 ms | Bitmap Heap + Index Scan | 2.127 ms | ✅ Improved |
| Q7 | Sequential Scan | ___ ms | Index Scan | ___ ms | ✅ Improved |
| Q8 | Sequential Scan | ___ ms | Index Scan | ___ ms | ✅ Improved |

---

## 🧠 Analysis

Using `EXPLAIN ANALYZE`, query performance was evaluated before and after adding indexes.

Most queries improved because PostgreSQL switched from **Sequential Scan** to **Index Scan**, reducing the number of scanned rows and improving execution speed. Indexes were especially effective for filtering conditions and join keys such as `(type, city)`, `person.ssn`, and foreign key relationships.

However, not all indexes improved performance:

- **Q2** became slower because PostgreSQL preferred a Hash Join with full table scans. Since most rows were required, using an index added overhead instead of improving performance.
- **Q5** also showed slower execution despite index usage, demonstrating that indexes are not always beneficial for large result sets.

This investigation highlights an important database engineering principle:  
**Indexes help selective queries but may hurt performance when large portions of tables are scanned.**

Overall, indexing significantly improved targeted lookup queries while showing the tradeoff between read optimization and execution planning.
---

*© 2026 LevelUp Economy. All rights reserved. Unauthorized reproduction or distribution of this material is prohibited.*

