# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for SCAN → SEARCH improvements.

---

## Q1 — All murders in SQL City

**Scan Type:** SEARCH TABLE
**Index Used:** idx_crime_city_type

```sql
SEARCH TABLE crime_scene_report USING INDEX idx_crime_city_type (city=? AND type=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q2 — People with their driver's license details

SEARCH TABLE person AS p USING INDEX idx_person_license_id (license_id=?)
SEARCH TABLE drivers_license AS dl USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q3 — Gym members who checked in on January 9, 2018

SEARCH TABLE get_fit_now_check_in AS ci USING INDEX idx_checkin_date (check_in_date=?)
SEARCH TABLE get_fit_now_member AS m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
USE TEMP B-TREE FOR ORDER BY

## Q4 — Gold gym members and their income

SEARCH TABLE get_fit_now_member AS m USING INDEX idx_member_status (membership_status=?)
SEARCH TABLE person AS p USING INTEGER PRIMARY KEY (rowid=?)
SEARCH TABLE income AS i USING INDEX sqlite_autoindex_income_1 (ssn=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q5 — People who attended Facebook events in 2018

SEARCH TABLE facebook_event_checkin AS fe USING INDEX idx_facebook_date (date>? AND date<?)
SEARCH TABLE person AS p USING INTEGER PRIMARY KEY (rowid=?)
USE TEMP B-TREE FOR ORDER BY
---

## Q6 — Red-haired Tesla drivers

SEARCH TABLE drivers_license AS dl USING INDEX idx_license_hair_car (hair_color=? AND car_make=?)
SEARCH TABLE person AS p USING INDEX sqlite_autoindex_person_1 (license_id=?)
---

## Q7 — Interview transcripts mentioning the gym or murder

SCAN TABLE interview AS i
SEARCH TABLE person AS p USING INTEGER PRIMARY KEY (rowid=?)

---

## Q8 — Average income by car make

SCAN TABLE drivers_license AS dl
SEARCH TABLE person AS p USING INDEX idx_person_license_id (license_id=?)
SEARCH TABLE income AS i USING INDEX sqlite_autoindex_income_1 (ssn=?)
USE TEMP B-TREE FOR GROUP BY
