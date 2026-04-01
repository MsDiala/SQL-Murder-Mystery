# explain_indexed.md - After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` - look for SCAN -> SEARCH improvements.

---

## Q1 - All murders in SQL City
**Execution Time:** 0.10 ms *(baseline: 0.09 ms | change: +0.01 ms)*
**Scan Type:** `SEARCH crime_scene_report` (no full scan)
**Index Used:** `idx_crime_city_type_date`

```
QUERY PLAN
`--SEARCH crime_scene_report USING INDEX idx_crime_city_type_date (city=? AND type=?)
```

---

## Q2 - People with their driver's license details
**Execution Time:** 0.11 ms *(baseline: 0.10 ms | change: +0.01 ms)*
**Scan Type:** `SCAN person USING INDEX idx_person_name` (ORDER BY satisfied)
**Index Used:** `idx_person_name` (join to `drivers_license` uses its primary key)

```
QUERY PLAN
|--SCAN p USING INDEX idx_person_name
`--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
```

---

## Q3 - Gym members who checked in on January 9, 2018
**Execution Time:** 0.11 ms *(baseline: 0.11 ms | change: +0.00 ms)*
**Scan Type:** `SEARCH get_fit_now_check_in` (indexed filter)
**Index Used:** `idx_checkin_date_time`

```
QUERY PLAN
|--SEARCH ci USING INDEX idx_checkin_date_time (check_in_date=?)
`--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
```

---

## Q4 - Gold gym members and their income
**Execution Time:** 0.12 ms *(baseline: 0.10 ms | change: +0.02 ms)*
**Scan Type:** `SEARCH get_fit_now_member` using `membership_status` index (still sorts for ORDER BY)
**Index Used:** `idx_member_status_person_id`

```
QUERY PLAN
|--SEARCH m USING INDEX idx_member_status_person_id (membership_status=?)
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q5 - People who attended Facebook events in 2018
**Execution Time:** 0.11 ms *(baseline: 0.11 ms | change: +0.00 ms)*
**Scan Type:** `SEARCH facebook_event_checkin` (date range indexed)
**Index Used:** `idx_facebook_date_person_id`

```
QUERY PLAN
|--SEARCH fe USING INDEX idx_facebook_date_person_id (date>? AND date<?)
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
```

---

## Q6 - Red-haired Tesla drivers
**Execution Time:** 0.15 ms *(baseline: 0.10 ms | change: +0.05 ms)*
**Scan Type:** `SEARCH drivers_license` using composite index (join still needs sort for ORDER BY)
**Index Used:** `idx_license_hair_color_car_make`, `idx_person_license_id`

```
QUERY PLAN
|--SEARCH dl USING INDEX idx_license_hair_color_car_make (hair_color=? AND car_make=?)
|--SEARCH p USING INDEX idx_person_license_id (license_id=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q7 - Interview transcripts mentioning the gym or murder
**Execution Time:** 0.11 ms *(baseline: 0.10 ms | change: +0.01 ms)*
**Scan Type:** `SCAN interview` (LIKE with leading wildcard)
**Index Used:** none (LIKE '%...%' prevents index usage)

```
QUERY PLAN
|--SCAN i
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
```

---

## Q8 - Average income by car make
**Execution Time:** 0.13 ms *(baseline: 0.11 ms | change: +0.02 ms)*
**Scan Type:** still `SCAN person` (no improved join order)
**Index Used:** none of the custom indexes shown in the plan

```
QUERY PLAN
|--SCAN p
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY
```
