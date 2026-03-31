# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.423  ms
**Scan Type:** SEARCH
**Notes:**
Highly efficient. The engine uses a Composite Index (idx_crime_city_type_date) to filter both city and type simultaneously, avoiding a full table scan.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(4, 0, 62, 'SEARCH crime_scene_report USING INDEX idx_crime_city_type_date (city=? AND type=?)')]
```

---

## Q2 — People with their driver's license details

**Execution Time:** 37.437 ms
**Scan Type:** SCAN P ,SEARCH dl
**Notes:** Efficiently uses idx_gold_member to filter status. It then leverages Integer Primary Keys for rapid lookups in the person and income tables, though it still requires a temporary B-Tree for sorting.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(5, 0, 224, 'SCAN p USING INDEX idx_person_name'), (8, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.529 ms
**Scan Type:** SCAN ci ,SEARCH m
**Notes:** Uses an index to scan check-ins, but requires a Temporary B-Tree to handle the ORDER BY clause. This indicates the existing index does not cover the requested sort order.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(6, 0, 215, 'SCAN ci USING INDEX idx_checkin_membership'), (11, 0, 47, 'SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)'), (24, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]   
```

---

## Q4 — Gold gym members and their income

**Execution Time:**  0.630 ms
**Scan Type:** SEARCH m , SEARCH i
**Notes:**Efficiently uses idx_gold_member to filter status. It then leverages Integer Primary Keys for rapid lookups in the person and income tables, though it still requires a temporary B-Tree for sorting.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(6, 0, 62, 'SEARCH m USING INDEX idx_gold_member (membership_status=?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (23, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 11.644 ms
**Scan Type:** SEARCH fe ,SEARCH P
**Notes:**Utilizes a Range Scan on idx_fb_checkin_date to find dates between the two boundaries. This is much faster than a full scan, though 7ms suggests a significant number of events in 2018.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(5, 0, 163, 'SEARCH fe USING INDEX idx_fb_checkin_date (date>? AND date<?)'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')]
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:**  1.647 ms
**Scan Type:** SEARCH dl , SEARCH P
**Notes:** Very efficient Multi-column Index usage. By filtering hair_color and car_make within the index itself, the engine only fetches the specific rows needed from the person table.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(6, 0, 61, 'SEARCH dl USING INDEX idx_dl_hair_car (hair_color=? AND car_make=?)'), (12, 0, 61, 'SEARCH p USING INDEX idx_person_license (license_id=?)'), (26, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:**3.704 ms
**Scan Type:** SCAN i , SEARCH P
**Notes:** Inefficient Full Table Scan (SCAN i). Because the query likely uses LIKE '%...%', the engine cannot use a standard index and must read every single interview transcript line-by-line.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(3, 0, 216, 'SCAN i'), (11, 0, 45, 'SEARCH p USING INTEGER PRIMARY KEY (rowid=?)')] 
```

---

## Q8 — Average income by car make

**Execution Time:** 10.940 ms
**Scan Type:** SCAN P ,SEARCH dl , SEARCH i
**Notes:** Resource-intensive. It performs a Full Scan of the person table and uses two separate Temporary B-Trees to handle the GROUP BY and ORDER BY operations, explaining the higher execution time.

```
-- Paste EXPLAIN QUERY PLAN output here
Query Plan: [(9, 0, 216, 'SCAN p'), (11, 0, 45, 'SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)'), (14, 0, 45, 'SEARCH i USING INTEGER PRIMARY KEY (rowid=?)'), (17, 0, 0, 'USE TEMP B-TREE FOR GROUP BY'), (67, 0, 0, 'USE TEMP B-TREE FOR ORDER BY')]

```
