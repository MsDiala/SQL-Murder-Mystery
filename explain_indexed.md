# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.000232 s  
**Scan Type:** Index Search (`SEARCH crime_scene_report USING INDEX idx_crime_city_type`)  
**Notes:**  
- SQLite used the new index `idx_crime_city_type` on `(city, type)`.  
- This replaced the baseline full table scan and made filtering more efficient.  
- SQLite still uses a temporary B-tree for `ORDER BY date DESC`.  
- Execution time improved significantly compared to the baseline.

```sql
QUERY PLAN
|--SEARCH crime_scene_report USING INDEX idx_crime_city_type (city=? AND type=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q2 — People with their driver's license details

**Execution Time:** 0.000364 s  
**Scan Type:**  
- SCAN on `person` using index `idx_person_name`  
- SEARCH on `drivers_license` using PRIMARY KEY  
**Notes:**  
- SQLite now scans `person` using the new `idx_person_name` index.  
- This avoids the temporary B-tree that appeared in the baseline for `ORDER BY p.name`.  
- The join to `drivers_license` remains efficient through primary key lookups.  
- The indexed plan is more efficient for sorting and overall query execution.

```sql
QUERY PLAN
|--SCAN p USING INDEX idx_person_name
`--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.000116 s  
**Scan Type:**  
- SEARCH on `get_fit_now_check_in` using index `idx_checkin_date`  
- SEARCH on `get_fit_now_member` using existing index on `id`  
**Notes:**  
- SQLite now uses the new `idx_checkin_date` index to filter rows by `check_in_date`.  
- This replaces the baseline full table scan on `get_fit_now_check_in`.  
- The join to `get_fit_now_member` remains efficient through the existing index on `id`.  
- A temporary B-tree is still used for `ORDER BY ci.check_in_time`.

```sql
QUERY PLAN
|--SEARCH ci USING INDEX idx_checkin_date (check_in_date=?)
|--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q4 — Gold gym members and their income

**Execution Time:** 0.000157 s  
**Scan Type:**  
- SEARCH on `get_fit_now_member` using index `idx_member_status`  
- SEARCH on `person` using PRIMARY KEY  
- SEARCH on `income` using PRIMARY KEY  
**Notes:**  
- SQLite now uses the new `idx_member_status` index to filter `membership_status = 'gold'`.  
- This replaces the baseline full table scan on `get_fit_now_member`.  
- The joins to `person` and `income` remain efficient through primary key lookups.  
- A temporary B-tree is still used for `ORDER BY i.annual_income DESC`.

```sql
QUERY PLAN
|--SEARCH m USING INDEX idx_member_status (membership_status=?)
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.000159 s  
**Scan Type:**  
- SEARCH on `facebook_event_checkin` using index `idx_facebook_date`  
- SEARCH on `person` using PRIMARY KEY  
**Notes:**  
- SQLite now uses the new `idx_facebook_date` index to filter the 2018 date range.  
- This replaces the baseline full table scan on `facebook_event_checkin`.  
- The join to `person` remains efficient through primary key lookups.  
- The indexed plan avoids the baseline temporary B-tree for sorting and is much more efficient.

```sql
QUERY PLAN
|--SEARCH fe USING INDEX idx_facebook_date (date>? AND date<?)
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.00018 s  
**Scan Type:**  
- SEARCH on `drivers_license` using index `idx_drivers_hair_make`  
- SEARCH on `person` using index `idx_person_license`  
**Notes:**  
- SQLite now uses the composite index `idx_drivers_hair_make` to filter `hair_color = 'red'` and `car_make = 'Tesla'`.  
- It also uses `idx_person_license` to join back to `person`.  
- This replaces the baseline plan that scanned `person` first.  
- A temporary B-tree is still used for `ORDER BY p.name`, but the filtering and join steps are now much more efficient.

```sql
QUERY PLAN
|--SEARCH dl USING INDEX idx_drivers_hair_make (hair_color=? AND car_make=?)
|--SEARCH p USING INDEX idx_person_license (license_id=?)
`--USE TEMP B-TREE FOR ORDER BY

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.000191 s  
**Scan Type:**  
- SCAN on `interview` (i)  
- SEARCH on `person` using PRIMARY KEY  
**Notes:**  
- SQLite still performs a full table scan on `interview`.  
- This is expected because `LIKE '%gym%'` and `LIKE '%murder%'` use leading wildcards, which prevent efficient use of normal B-tree indexes.  
- The join to `person` remains efficient through primary key lookups.  
- This query showed little structural improvement after indexing, which is consistent with substring text search behavior.

```sql
QUERY PLAN
|--SCAN i
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)

## Q8 — Average income by car make

**Execution Time:** 0.001118 s  
**Scan Type:**  
- SCAN on `income` (i)  
- SEARCH on `person` using index `idx_person_ssn`  
- SEARCH on `drivers_license` using PRIMARY KEY  
**Notes:**  
- SQLite now uses `idx_person_ssn` to join from `income` to `person`.  
- The join to `drivers_license` remains efficient through primary key lookups.  
- SQLite still scans `income` and still uses temporary B-trees for both `GROUP BY` and `ORDER BY`.  
- Even with those remaining steps, execution improved significantly compared to the baseline.

```sql
QUERY PLAN
|--SCAN i
|--SEARCH p USING INDEX idx_person_ssn (ssn=?)
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY