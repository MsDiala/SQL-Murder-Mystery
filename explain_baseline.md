# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.001997 s  
**Scan Type:** Full Table Scan (SCAN crime_scene_report)  
**Notes:** Full scan on crime_scene_report and temporary B-tree used for ORDER BY. No index on filtering columns.

```sql
QUERY PLAN
|--SCAN crime_scene_report
`--USE TEMP B-TREE FOR ORDER BY


## Q2 — People with their driver's license details

**Execution Time:** 0.000165 s  
**Scan Type:**  
- SCAN on person (p)  
- SEARCH on drivers_license using PRIMARY KEY  
**Notes:**  
- SQLite performed a full table scan on `person`.  
- The join with `drivers_license` is efficient because it uses the primary key (`rowid`).  
- A temporary B-tree is used for sorting due to `ORDER BY p.name`.  
- This query could benefit from an index on `person(license_id)` and possibly `person(name)` to optimize sorting.

```sql
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.000726 s  
**Scan Type:**  
- SCAN on `get_fit_now_check_in` (ci)  
- SEARCH on `get_fit_now_member` using existing index on `id`  
**Notes:**  
- SQLite performed a full table scan on `get_fit_now_check_in` to filter `check_in_date = 20180109`.  
- The join to `get_fit_now_member` is efficient because it uses the existing index on `id`.  
- A temporary B-tree is used for sorting because of `ORDER BY ci.check_in_time`.  
- This query could benefit from an index on `get_fit_now_check_in(check_in_date)` and possibly a composite index including `check_in_time`.

```sql
QUERY PLAN
|--SCAN ci
|--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q4 — Gold gym members and their income

**Execution Time:** 0.000933 s  
**Scan Type:**  
- SCAN on `get_fit_now_member` (m)  
- SEARCH on `person` using PRIMARY KEY  
- SEARCH on `income` using PRIMARY KEY  
**Notes:**  
- SQLite performed a full table scan on `get_fit_now_member` to filter `membership_status = 'gold'`.  
- The joins to `person` and `income` are efficient because they use primary key lookups.  
- A temporary B-tree is used for sorting due to `ORDER BY i.annual_income DESC`.  
- This query could benefit from an index on `get_fit_now_member(membership_status)` and possibly on `income(annual_income)` for sorting support.

```sql
QUERY PLAN
|--SCAN m
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.029443 s  
**Scan Type:**  
- SCAN on `facebook_event_checkin` (fe)  
- SEARCH on `person` using PRIMARY KEY  
**Notes:**  
- SQLite performed a full table scan on `facebook_event_checkin` to apply the date range filter.  
- The join to `person` is efficient because it uses the primary key.  
- A temporary B-tree is used for sorting due to `ORDER BY fe.date DESC`.  
- This query could benefit from an index on `facebook_event_checkin(date)` and possibly `facebook_event_checkin(person_id)`.

```sql
QUERY PLAN
|--SCAN fe
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.007282 s  
**Scan Type:**  
- SCAN on `person` (p)  
- SEARCH on `drivers_license` using PRIMARY KEY  
**Notes:**  
- SQLite performed a full table scan on `person`, then used primary key lookups on `drivers_license`.  
- Although the filtering conditions are on `drivers_license.hair_color` and `drivers_license.car_make`, the planner still starts by scanning `person`.  
- A temporary B-tree is used for sorting due to `ORDER BY p.name`.  
- This query could benefit from a composite index on `drivers_license(hair_color, car_make)` and an index on `person(license_id)`.

```sql
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.003169 s  
**Scan Type:** Likely full table scan on `interview`  
**Notes:**  
- This query searches inside text using `LIKE '%gym%'` and `LIKE '%murder%'`.  
- Wildcards at the beginning of the pattern usually prevent efficient index usage, so SQLite typically performs a full scan of the `interview` table.  
- The join to `person` is expected to use the primary key.  
- This query may show little or no improvement from standard indexing because substring text search is not index-friendly.

```sql
-- EXPLAIN QUERY PLAN failed due to a parse/paste issue in the SQLite shell.
-- Based on the query structure, SQLite will likely scan `interview`
-- and use a primary key lookup on `person`.

## Q8 — Average income by car make

**Execution Time:** 0.010259 s  
**Scan Type:**  
- SCAN on `person` (p)  
- SEARCH on `drivers_license` using PRIMARY KEY  
- SEARCH on `income` using PRIMARY KEY  
**Notes:**  
- SQLite performed a full table scan on `person`.  
- The joins to `drivers_license` and `income` are efficient because they use primary key lookups.  
- A temporary B-tree is used for `GROUP BY dl.car_make`.  
- Another temporary B-tree is used for `ORDER BY avg_income DESC`.  
- This query could benefit from an index on `person(license_id)` and `person(ssn)`, though aggregation and sorting will still require extra work.

```sql
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY