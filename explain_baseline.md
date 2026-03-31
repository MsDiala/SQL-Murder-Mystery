# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 — All murders in SQL City

**Execution Time:** ___ ms  
**Scan Type:** SCAN crime_scene_report  
**Notes:** Full table scan on crime_scene_report. Also uses a TEMP B-TREE for ORDER BY, indicating no index for sorting.

---
QUERY PLAN
SCAN crime_scene_report
USE TEMP B-TREE FOR ORDER BY
---
---

## Q2 — People with their driver's license details

**Execution Time:** ___ ms  
**Scan Type:** SCAN person + SEARCH drivers_license USING INTEGER PRIMARY KEY  
**Notes:** person table is fully scanned. drivers_license is accessed efficiently using primary key. ORDER BY requires TEMP B-TREE (no index on name).

---
QUERY PLAN
SCAN p
SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ___ ms  
**Scan Type:** SCAN get_fit_now_check_in + SEARCH get_fit_now_member USING INDEX  
**Notes:** Full scan on get_fit_now_check_in (likely large table). Efficient lookup on get_fit_now_member using primary key index. ORDER BY requires TEMP B-TREE (no index on check_in_time).

---
QUERY PLAN
SCAN ci
SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q4 — Gold gym members and their income

## Q4 — Gold gym members and their income

**Execution Time:** ___ ms  
**Scan Type:** SCAN get_fit_now_member + SEARCH person + SEARCH income  
**Notes:** Full scan on get_fit_now_member. Joins to person and income use primary key lookups (efficient). ORDER BY requires TEMP B-TREE (no index on annual_income).

---
QUERY PLAN
SCAN m
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ___ ms  
**Scan Type:** SCAN facebook_event_checkin + SEARCH person USING INTEGER PRIMARY KEY  
**Notes:** Full scan on facebook_event_checkin (large table). Join to person is efficient via primary key. ORDER BY requires TEMP B-TREE (no index on date).

---
QUERY PLAN
SCAN fe
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ___ ms  
**Scan Type:** SCAN person + SEARCH drivers_license USING INTEGER PRIMARY KEY  
**Notes:** Full scan on person table. drivers_license is accessed efficiently via primary key. Filtering is applied after join (no index on hair_color or car_make). ORDER BY requires TEMP B-TREE.

---
QUERY PLAN
SCAN p
SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ___ ms  
**Scan Type:** SCAN interview + SEARCH person USING INTEGER PRIMARY KEY  
**Notes:** Full scan on interview. The `LIKE '%gym%'` and `LIKE '%murder%'` patterns start with a wildcard, so a normal index would not help much. Join to person is efficient via primary key.

---
QUERY PLAN
SCAN i
SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
---

## Q8 — Average income by car make

**Execution Time:** ___ ms  
**Scan Type:** SCAN person + SEARCH drivers_license USING INTEGER PRIMARY KEY + SEARCH income USING INTEGER PRIMARY KEY  
**Notes:** Full scan on person. Joins to drivers_license and income use primary key lookups. Query also uses TEMP B-TREE for both GROUP BY and ORDER BY, which adds sorting/aggregation overhead.

---
QUERY PLAN
SCAN p
SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR GROUP BY
USE TEMP B-TREE FOR ORDER BY
---