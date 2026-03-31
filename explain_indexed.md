# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.243 ms *(baseline:  0.423 ms | change:  44.06 )*
**Scan Type:** SEARCH 
**Index Used:** yes

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(4, 0, 62, 'SEARCH crime_scene_report USING INDEX idx_crime_city_type_date (city=? AND type=?)')]
```
---

## Q2 — People with their driver's license details

**Execution Time:** 23.944  ms *(baseline: 37.437 ms | change:  42.38)*
**Scan Type:** SCAN P ,SEARCH dl
**Index Used:** yes

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(5, 0, 224, 'SCAN p USING INDEX idx_person_name'), (8, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)')]
```
---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:**  0.524 ms *(baseline:  0.524 ms | change: -51.14)*
**Scan Type:**  SCAN ci ,SEARCH m
**Index Used:** yes

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(6, 0, 215, 'SCAN ci USING INDEX idx_checkin_membership'), (11, 0, 47, 'SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)'), (24, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')] 
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.363 ms *(baseline: 0.630 ms | change:-5.64)*
**Scan Type:** SEARCH m , SEARCH i
**Index Used:** Yes

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(6, 0, 62, 'SEARCH m USING INDEX idx_gold_member (membership_status=?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (23, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 12.660 ms *(baseline: 11.644 ms | change: 5.98)*
**Scan Type:** SEARCH fe ,SEARCH P
**Index Used:** yes

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(5, 0, 163, 'SEARCH fe USING INDEX idx_fb_checkin_date (date>? AND date<?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.260 ms *(baseline: 1.647 ms | change:81.3 )*
**Scan Type:** SEARCH dl , SEARCH P
**Index Used:** Yes

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(6, 0, 61, 'SEARCH dl USING INDEX idx_dl_hair_car (hair_color=? AND car_make=?)'), (12, 0, 61, 'SEARCH p USING INDEX idx_person_license (license_id=?)'), (26, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 1.364 ms *(baseline: 3.704  ms | change: -2.58)*
**Scan Type:** SCAN i , SEARCH P
**Index Used:** NO

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(3, 0, 216, 'SCAN i'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')] 
```

---

## Q8 — Average income by car make

**Execution Time:**9.071  ms *(baseline:10.940 ms | change:  24.24 )*
**Scan Type:** SCAN P ,SEARCH dl , SEARCH i
**Index Used:** NO

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(9, 0, 216, 'SCAN p'), (11, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (17, 0, 0, 'USE TEMP B-TREE FOR GROUP BY'), (67, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```
