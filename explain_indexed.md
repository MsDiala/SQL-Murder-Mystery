# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.162 ms *(baseline:0.287 ms | change:43.49)*
**Scan Type:** SEARCH
**Index Used:** yes

```
-- [(4, 0, 62, 'SEARCH crime_scene_report USING INDEX idx_crime_city_type_date (city=? AND type=?)')]
```

---

## Q2 — People with their driver's license details

**Execution Time:** 19.466 ms *(baseline: 28.779 ms | change: 19.466)*
**Scan Type:** SCAN p & SEARCH dl
**Index Used:** yes

```
--  [(5, 0, 224, 'SCAN p USING INDEX idx_person_name'), (8, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:**  0.303 ms *(baseline:0.318 ms | change: 0.303)*
**Scan Type:** SCAN ci & SEARCH m
**Index Used:** yes

```
-- [(6, 0, 215, 'SCAN ci USING INDEX idx_checkin_membership'), (11, 0, 47, 'SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)'), (24, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 0.260 ms *(baseline:0.445 ms | change:41.53)*
**Scan Type:** SEARCH M & SEARCH i
**Index Used:** YES

```
-- [(6, 0, 62, 'SEARCH m USING INDEX idx_gold_member (membership_status=?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (23, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 6.454 ms *(baseline:7.047 ms | change:8.4)*
**Scan Type:** SEARCH fe & SEARCH p
**Index Used:** YES

```
--[(5, 0, 163, 'SEARCH fe USING INDEX idx_fb_checkin_date (date>? AND date<?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.177 ms *(baseline:  1.835 ms | change: 90.34)*
**Scan Type:** SEARCH dl & SEARCH p
**Index Used:** YES

```
--  [(6, 0, 61, 'SEARCH dl USING INDEX idx_dl_hair_car (hair_color=? AND car_make=?)'), (12, 0, 61, 'SEARCH p USING INDEX idx_person_license (license_id=?)'), (26, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:**  0.177 ms *(baseline: 1.835 ms | change: -39.13)*
**Scan Type:**  SCAN i & SEARCH p
**Index Used:** NO

```
-- [(3, 0, 216, 'SCAN i'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q8 — Average income by car make

**Execution Time:** 7.869 ms *(baseline: 9.561 ms | change:17.69)*
**Scan Type:** SCAN p & SEARCH dl & SEARCH i
**Index Used:** NO

```
--  [(9, 0, 216, 'SCAN p'), (11, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (17, 0, 0, 'USE TEMP B-TREE FOR GROUP BY'), (67, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```
