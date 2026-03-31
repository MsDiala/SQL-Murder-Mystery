# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 0.009934 ms  
**Scan Type:** SEARCH crime_scene_report USING INDEX  
**Notes:** Improved from baseline. The query now uses an index on (city, type) instead of performing a full table scan. However, it still uses a TEMP B-TREE for ORDER BY, indicating sorting is not fully optimized.

---
QUERY PLAN
SEARCH crime_scene_report USING INDEX idx_crime_city_type (city=? AND type=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q2 — People with their driver's license details

**Execution Time:** 0.004321 ms  
**Scan Type:** SCAN person + SEARCH drivers_license USING INTEGER PRIMARY KEY  
**Notes:** No significant improvement from baseline. The person table is still fully scanned. Although an index exists on person(license_id), SQLite continues to scan person first. ORDER BY still requires a TEMP B-TREE, indicating no index on name.

---
QUERY PLAN
SCAN p
SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.006107 ms  
**Scan Type:** SEARCH get_fit_now_check_in USING INDEX + SEARCH get_fit_now_member USING INDEX  
**Notes:** Improved from baseline. The query now uses an index on `get_fit_now_check_in(check_in_date)` to filter check-ins by date, avoiding a full table scan. The join to `get_fit_now_member` continues to use its existing index. ORDER BY still requires a TEMP B-TREE, so sorting is not fully optimized.

---
QUERY PLAN
SEARCH ci USING INDEX idx_checkin_date (check_in_date=?)
SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q4 — Gold gym members and their income

**Execution Time:** 0.003759 ms  
**Scan Type:** SEARCH get_fit_now_member USING INDEX + SEARCH person USING INTEGER PRIMARY KEY + SEARCH income USING INTEGER PRIMARY KEY  
**Notes:** Improved from baseline. The query now uses an index on `get_fit_now_member(membership_status)` to filter gold members instead of scanning the entire member table. Joins to `person` and `income` remain efficient via primary key lookups. ORDER BY still requires a TEMP B-TREE.

---
QUERY PLAN
SEARCH m USING INDEX idx_member_status (membership_status=?)
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 0.020710 ms  
**Scan Type:** SEARCH facebook_event_checkin USING INDEX + SEARCH person USING INTEGER PRIMARY KEY  
**Notes:** Improved from baseline. The query now uses an index on `facebook_event_checkin(date)` to filter the date range instead of scanning the full table. The join to `person` remains efficient via primary key. No TEMP B-TREE appears in the plan, so sorting is handled more efficiently here.

---
QUERY PLAN
SEARCH fe USING INDEX idx_facebook_date (date>? AND date<?)
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 0.042438 ms  
**Scan Type:** SEARCH drivers_license USING INDEX + SEARCH person USING INDEX  
**Notes:** Significant improvement from baseline. The query now uses a composite index on `drivers_license(hair_color, car_make)` to filter efficiently instead of scanning. It also uses an index on `person(license_id)` for the join. ORDER BY still requires a TEMP B-TREE.

---
QUERY PLAN
SEARCH dl USING INDEX idx_license_hair_car (hair_color=? AND car_make=?)
SEARCH p USING INDEX idx_person_license_id (license_id=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 0.015140 ms  
**Scan Type:** SCAN interview + SEARCH person USING INTEGER PRIMARY KEY  
**Notes:** No meaningful improvement from baseline. The interview table is still fully scanned because the predicates use `LIKE '%gym%'` and `LIKE '%murder%'`, which begin with wildcards and cannot effectively use a normal B-tree index. The join to person remains efficient via primary key.

---
QUERY PLAN
SCAN i
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
---

## Q8 — Average income by car make

**Execution Time:** 0.035670 ms  
**Scan Type:** SCAN person + SEARCH drivers_license USING INTEGER PRIMARY KEY + SEARCH income USING INTEGER PRIMARY KEY  
**Notes:** No significant improvement from baseline. SQLite still chooses to scan the person table first, then joins to drivers_license and income using primary key lookups. The query also still requires TEMP B-TREE structures for both GROUP BY and ORDER BY, so aggregation and sorting remain expensive.

---
QUERY PLAN
SCAN p
SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR GROUP BY
USE TEMP B-TREE FOR ORDER BY
---
