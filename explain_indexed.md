# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q2 — People with their driver's license details

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q4 — Gold gym members and their income

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```

---

## Q8 — Average income by car make

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
-- Paste EXPLAIN ANALYZE output here
```
Q1 — All murders in SQL City
Execution Time: 1.322 ms
Scan Type: SEARCH TABLE (Fast)
Notes: Huge improvement. The engine now uses idx_crime_city_type to jump directly to the relevant records instead of scanning the whole table.

SQL
-> SEARCH crime_scene_report USING INDEX idx_crime_city_type (city=? AND type=?)
-> USE TEMP B-TREE FOR ORDER BY
Q2 — People with their driver's license details
Execution Time: 66.561 ms
Scan Type: SCAN TABLE
Notes: Still scanning table p. This is because the query orders by p.name which doesn't have an index, and the join is starting from p.

SQL
-> SCAN p
-> SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
-> USE TEMP B-TREE FOR ORDER BY
Q3 — Gym members who checked in on January 9, 2018
Execution Time: 1.919 ms
Scan Type: SEARCH TABLE
Notes: Now using idx_checkin_date. The engine is much more efficient at finding the specific date.

SQL
-> SEARCH ci USING INDEX idx_checkin_date (check_in_date=?)
-> SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
-> USE TEMP B-TREE FOR ORDER BY
Q4 — Gold gym members and their income
Execution Time: 1.024 ms
Scan Type: SEARCH TABLE
Notes: Performance improved by using idx_member_status to filter gold members first.

SQL
-> SEARCH m USING INDEX idx_member_status (membership_status=?)
-> SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
-> SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
-> USE TEMP B-TREE FOR ORDER BY
Q5 — People who attended Facebook events in 2018
Execution Time: 20.957 ms
Scan Type: SEARCH TABLE
Notes: Now using idx_facebook_date. Even though the time looks similar to baseline, the engine is no longer doing a full SCAN, making it more scalable for larger data.

SQL
-> SEARCH fe USING INDEX idx_facebook_date (date>? AND date<?)
-> SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
Q6 — Red-haired Tesla drivers
Execution Time: 1.003 ms
Scan Type: SEARCH TABLE
Notes: Perfect optimization. It uses the composite index on hair color and car make, then jumps to the person using idx_person_license_id.

SQL
-> SEARCH dl USING INDEX idx_license_hair_car (hair_color=? AND car_make=?)
-> SEARCH p USING INDEX idx_person_license_id (license_id=?)
-> USE TEMP B-TREE FOR ORDER BY
Q7 — Interview transcripts mentioning the gym or murder
Execution Time: 2.984 ms
Scan Type: SCAN TABLE
Notes: No improvement. As expected, LIKE '%...%' cannot benefit from standard B-Tree indexes.

SQL
-> SCAN i
-> SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
Q8 — Average income by car make
Execution Time: 18.328 ms
Scan Type: SCAN TABLE
Notes: Complex aggregation still requires full scans and multiple temporary trees for grouping/sorting.

SQL
-> SCAN p
-> SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
-> SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
-> USE TEMP B-TREE FOR GROUP BY
-> USE TEMP B-TREE FOR ORDER BY