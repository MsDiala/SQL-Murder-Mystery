# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** 1.472 ms
**Scan Type:** SEARCH
**Notes:** Uses composite index on (city, type, date). No full table scan.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(4, 0, 62, 'SEARCH crime_scene_report USING INDEX idx_crime_city_type_date (city=? AND type=?)')]
```

---

## Q2 — People with their driver's license details

**Execution Time:** 157.979 ms
**Scan Type:** SCAN p, SEARCH dl
**Notes:** Full index scan on person table; license table searched by primary key. Person table still largely scanned.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(5, 0, 224, 'SCAN p USING INDEX idx_person_name'), (8, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 1.285 ms
**Scan Type:** SCAN ci, SEARCH m
**Notes:** Index scan on check-in table and indexed search on member table; temporary B-tree used for ORDER BY.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(6, 0, 215, 'SCAN ci USING INDEX idx_checkin_membership'), (11, 0, 47, 'SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)'), (24, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 1.529 ms
**Scan Type:** SEARCH m, SEARCH i 
**Notes:** Indexed searches on all tables; temporary B-tree created for ORDER BY sorting.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(6, 0, 62, 'SEARCH m USING INDEX idx_gold_member (membership_status=?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (23, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 30.395 ms
**Scan Type:** SEARCH fe, SEARCH p
**Notes:** Uses date index for range filtering and primary key lookup for person; no full table scan.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(5, 0, 163, 'SEARCH fe USING INDEX idx_fb_checkin_date (date>? AND date<?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 5.516 ms
**Scan Type:** SEARCH dl, SEARCH p
**Notes:** Composite index used for filtering; additional temp B-tree required for ORDER BY.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(6, 0, 61, 'SEARCH dl USING INDEX idx_dl_hair_car (hair_color=? AND car_make=?)'), (12, 0, 61, 'SEARCH p USING INDEX idx_person_license (license_id=?)'), (26, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 6.239 ms
**Scan Type:** SCAN i, SEARCH p
**Notes:** Full table scan on interview table due to text filtering (LIKE); person table searched by primary key.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(3, 0, 216, 'SCAN i'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q8 — Average income by car make

**Execution Time:** 22.102 ms
**Scan Type:** SCAN p, SEARCH dl, SEARCH i
**Notes:** Full scan on person table; grouping and ordering require temporary B-trees, increasing execution cost.

```
-- Paste EXPLAIN QUERY PLAN output here

Query Plan: [(9, 0, 216, 'SCAN p'), (11, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (17, 0, 0, 'USE TEMP B-TREE FOR GROUP BY'), (67, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```
