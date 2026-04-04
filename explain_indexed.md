# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.348 ms ms *(baseline:  1.050 ms ms | change: 73.88)*
**Scan Type:** SEARCH
**Index Used:** YES

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(4, 0, 62, 'SEARCH crime_scene_report USING INDEX idx_crime_city_type_date (city=? AND type=?)')]
```

---

## Q2 — People with their driver's license details

**Execution Time:** 123.933 ms *(baseline: 157.979 ms | change: 21.55)*
**Scan Type:** SCAN p, SEARCH dl
**Index Used:** Yes

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(5, 0, 224, 'SCAN p USING INDEX idx_person_name'), (8, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 1.105 ms *(baseline: 1.285 ms | change: 13.97)*
**Scan Type:** SCAN ci, SEARCH m
**Index Used:** YES
```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(6, 0, 215, 'SCAN ci USING INDEX idx_checkin_membership'), (11, 0, 47, 'SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)'), (24, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.822 ms *(baseline: 1.529 ms | change: 46.24)*
**Scan Type:** SEARCH m, SEARCH i 
**Index Used:** Yes

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(6, 0, 62, 'SEARCH m USING INDEX idx_gold_member (membership_status=?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (23, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 25.573 ms *(baseline: 30.395 ms | change: 15.86)*
**Scan Type:** SEARCH fe, SEARCH p
**Index Used:** Yes

```
-- Paste EXPLAIN QUERY PLAN output here

[(5, 0, 163, 'SEARCH fe USING INDEX idx_fb_checkin_date (date>? AND date<?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.571 ms *(baseline: 5.516 ms | change: 89.64)*
**Scan Type:** SEARCH dl, SEARCH p
**Index Used:** yes

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(6, 0, 61, 'SEARCH dl USING INDEX idx_dl_hair_car (hair_color=? AND car_make=?)'), (12, 0, 61, 'SEARCH p USING INDEX idx_person_license (license_id=?)'), (26, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 3.809 ms *(baseline: 6.239 ms | change:  38.95)*
**Scan Type:** SCAN i, SEARCH p
**Index Used:** NO

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(3, 0, 216, 'SCAN i'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q8 — Average income by car make

**Execution Time:** 18.979 ms *(baseline: 22.102 ms | change: 14.13*
**Scan Type:** SCAN p, SEARCH dl, SEARCH i
**Index Used:** NO

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(9, 0, 216, 'SCAN p'), (11, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (17, 0, 0, 'USE TEMP B-TREE FOR GROUP BY'), (67, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```
