# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q2 — People with their driver's license details

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q4 — Gold gym members and their income

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```

---

## Q8 — Average income by car make

**Execution Time:** ___ ms
**Scan Type:** ___
**Notes:** ___

```
-- Paste EXPLAIN QUERY PLAN output here
```
Q1 — All murders in SQL City
Execution Time: 7.501 ms
Scan Type: SCAN TABLE
Notes: The engine performs a full scan of the crime_scene_report table and uses a temporary B-Tree to sort the results by date.

Q2 — People with their driver's license details
Execution Time: 59.571 ms
Scan Type: SCAN TABLE + SEARCH TABLE
Notes: This is the slowest query. It scans the person table fully before joining with drivers_license, and uses another temporary B-Tree for sorting.

Q3 — Gym members who checked in on January 9, 2018
Execution Time: 1.972 ms
Scan Type: SCAN TABLE + SEARCH TABLE
Notes: Scans the check-in table (ci) and searches the member table (m) using an automatic index. Sorting adds overhead.

Q4 — Gold gym members and their income
Execution Time: 1.803 ms
Scan Type: SCAN TABLE + SEARCH TABLE
Notes: Joins three tables. It scans the membership table first, then uses primary keys to find matching person and income records.

Q5 — People who attended Facebook events in 2018
Execution Time: 19.991 ms
Scan Type: SCAN TABLE
Notes: Performs a full scan of the facebook_event_checkin table to filter by date, which is inefficient without an index.

Q6 — Red-haired Tesla drivers
Execution Time: 7.828 ms
Scan Type: SCAN TABLE + SEARCH TABLE
Notes: Scans the entire person table and joins with drivers_license. A temporary B-Tree is used for the name sorting.

Q7 — Interview transcripts mentioning the gym or murder
Execution Time: 2.724 ms
Scan Type: SCAN TABLE
Notes: Uses a full scan of the interview table. This is typical for queries using LIKE with wildcards.

Q8 — Average income by car make
Execution Time: 16.980 ms
Scan Type: SCAN TABLE + TEMP B-TREE
Notes: A complex query involving multiple joins and two temporary B-Trees for grouping and ordering the final results.