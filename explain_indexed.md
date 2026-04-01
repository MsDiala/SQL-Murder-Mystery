# explain_indexed.md — After Indexing (PostgreSQL)

> Re-ran the same queries after applying indexes from `indexes.sql`.
> This version uses PostgreSQL `EXPLAIN ANALYZE`, so scan improvements appear as `Seq Scan` → `Index Scan` / `Bitmap Index Scan`.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.170 ms *(baseline: 0.138 ms | change: +0.032 ms)*
**Scan Type:** Index Scan
**Index Used:** `idx_crime_city_type`

```text
Sort
 -> Index Scan using idx_crime_city_type on crime_scene_report
```

---

## Q2 — People with their driver's license details

**Execution Time:** 26.052 ms *(baseline: 21.441 ms | change: +4.611 ms)*
**Scan Type:** Seq Scan (`person`, `drivers_license`)
**Join Type:** Hash Join
**Index Used:** None used by planner

```text
Sort
 -> Hash Join
    -> Seq Scan on person
    -> Seq Scan on drivers_license
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.147 ms *(baseline: 1.098 ms | change: -0.951 ms)*
**Scan Type:** Bitmap Heap Scan + Bitmap Index Scan
**Join Type:** Hash Join
**Index Used:** `idx_checkin_date`

```text
Sort
 -> Hash Join
    -> Bitmap Heap Scan on get_fit_now_check_in
       -> Bitmap Index Scan on idx_checkin_date
    -> Seq Scan on get_fit_now_member
```

---

## Q4 — Gold gym members and their income

**Execution Time:** Not re-run after `idx_member_status`
**Scan Type:** Not re-run after index creation
**Index Used:** `idx_member_status` was created, but no post-index execution plan was captured

```text
Post-index EXPLAIN ANALYZE not captured.
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 5.711 ms *(baseline: 6.159 ms | change: -0.448 ms)*
**Scan Type:** Bitmap Heap Scan + Bitmap Index Scan (`facebook_event_checkin`)
**Join Type:** Hash Join
**Index Used:** `idx_facebook_date`

```text
Sort
 -> Hash Join
    -> Bitmap Heap Scan on facebook_event_checkin
       -> Bitmap Index Scan on idx_facebook_date
    -> Seq Scan on person
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.078 ms *(baseline: 0.939 ms | change: -0.861 ms)*
**Scan Type:** Bitmap Heap Scan (`drivers_license`) + Index Scan (`person`)
**Join Type:** Nested Loop
**Index Used:** `idx_dl_hair_car`, `idx_person_license`

```text
Sort
 -> Nested Loop
    -> Bitmap Heap Scan on drivers_license
       -> Bitmap Index Scan on idx_dl_hair_car
    -> Index Scan using idx_person_license on person
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 7.063 ms *(baseline: 7.063 ms | change: 0.000 ms)*
**Scan Type:** Seq Scan (`interview`)
**Join Type:** Nested Loop
**Index Used:** None

```text
Nested Loop
 -> Seq Scan on interview
 -> Index Scan using person_pkey on person
```

---

## Q8 — Average income by car make

**Execution Time:** Not re-run after `idx_person_ssn` and `idx_income_ssn`
**Scan Type:** Not re-run after index creation
**Index Used:** `idx_person_ssn`, `idx_income_ssn` were created, but no post-index execution plan was captured

```text
Post-index EXPLAIN ANALYZE not captured.
```
