```markdown
# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** 3.98 ms *(baseline: 21.22 ms | change: -17.24 ms)*
**Scan Type:** SEARCH crime_scene_report
**Index Used:** idx_crime_city_type

```text
QUERY PLAN
|--SEARCH crime_scene_report USING INDEX idx_crime_city_type (city=? AND type=?)
`--USE TEMP B-TREE FOR ORDER BY
Run Time: real 0.003981 user 0.000000 sys 0.000000
```

---

## Q2 — People with their driver's license details

**Execution Time:** 3.14 ms *(baseline: 2.96 ms | change: +0.18 ms)*
**Scan Type:** SCAN p
**Index Used:** None

```text
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
Run Time: real 0.003140 user 0.000000 sys 0.000000
```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 4.92 ms *(baseline: 3.62 ms | change: +1.30 ms)*
**Scan Type:** SEARCH ci
**Index Used:** idx_checkin_date

```text
QUERY PLAN
|--SEARCH ci USING INDEX idx_checkin_date (check_in_date=?)
|--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
`--USE TEMP B-TREE FOR ORDER BY
Run Time: real 0.004924 user 0.000000 sys 0.000000
```

---

## Q4 — Gold gym members and their income

**Execution Time:** 5.23 ms *(baseline: 3.73 ms | change: +1.50 ms)*
**Scan Type:** SEARCH m
**Index Used:** idx_member_status

```text
QUERY PLAN
|--SEARCH m USING INDEX idx_member_status (membership_status=?)
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
Run Time: real 0.005227 user 0.000000 sys 0.000000
```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 22.08 ms *(baseline: 3.18 ms | change: +18.90 ms)*
**Scan Type:** SEARCH fe
**Index Used:** idx_facebook_date

```text
QUERY PLAN
|--SEARCH fe USING INDEX idx_facebook_date (date>? AND date<?)
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
Run Time: real 0.022078 user 0.000000 sys 0.000000
```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 4.83 ms *(baseline: 2.89 ms | change: +1.94 ms)*
**Scan Type:** SEARCH dl, SEARCH p
**Index Used:** idx_license_hair_car, idx_person_license_id

```text
QUERY PLAN
|--SEARCH dl USING INDEX idx_license_hair_car (hair_color=? AND car_make=?)
|--SEARCH p USING INDEX idx_person_license_id (license_id=?)
`--USE TEMP B-TREE FOR ORDER BY
Run Time: real 0.004827 user 0.000000 sys 0.000000
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 2.25 ms *(baseline: 3.02 ms | change: -0.77 ms)*
**Scan Type:** SCAN i
**Index Used:** None

```text
QUERY PLAN
|--SCAN i
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
Run Time: real 0.002249 user 0.000000 sys 0.000000
```

---

## Q8 — Average income by car make

**Execution Time:** 4.73 ms *(baseline: 4.71 ms | change: +0.02 ms)*
**Scan Type:** SCAN p
**Index Used:** None

```text
QUERY PLAN
|--SCAN p
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY
Run Time: real 0.004725 user 0.000000 sys 0.000000
```
```