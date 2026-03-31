# Baseline EXPLAIN QUERY PLAN Results

All queries run before adding any indexes.
`.timer on` enabled to capture execution time.

---

## Q1 — All murders in SQL City
```sql
SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City' AND type = 'murder'
ORDER BY date DESC;
```

**Execution Plan:**
```
|--SCAN crime_scene_report
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE (full scan) ⚠️
- **Issue:** No index on `city` or `type` — reads all 1,228 rows
- **Time:** 0.003946s

---

## Q2 — People with driver's license details
```sql
SELECT p.name, ... FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;
```

**Execution Plan:**
```
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE on `person` ⚠️ — 10,011 rows scanned
- **Join:** `drivers_license` uses PK index ✅
- **Issue:** No index on `person.license_id`
- **Time:** 0.003902s

---

## Q3 — Gym members who checked in on January 9, 2018
```sql
SELECT m.name, ... FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;
```

**Execution Plan:**
```
|--SCAN ci
|--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE on `get_fit_now_check_in` ⚠️ — 2,703 rows
- **Join:** `get_fit_now_member` uses auto index ✅
- **Issue:** No index on `check_in_date`
- **Time:** 0.005057s

---

## Q4 — Gold gym members and their income
```sql
SELECT m.name, m.membership_status, i.annual_income
FROM get_fit_now_member m
JOIN person p ON m.person_id = p.id
JOIN income i ON p.ssn = i.ssn
WHERE m.membership_status = 'gold'
ORDER BY i.annual_income DESC;
```

**Execution Plan:**
```
|--SCAN m
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE on `get_fit_now_member` ⚠️ — 184 rows (small, acceptable)
- **Joins:** Both `person` and `income` use PK ✅
- **Issue:** No index on `membership_status`
- **Time:** 0.005618s

---

## Q5 — People who attended Facebook events in 2018
```sql
SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;
```

**Execution Plan:**
```
|--SCAN fe
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE on `facebook_event_checkin` ⚠️ — 20,011 rows (largest table!)
- **Join:** `person` uses PK ✅
- **Issue:** No index on `date`
- **Time:** 0.004406s

---

## Q6 — Red-haired Tesla drivers
```sql
SELECT p.name, dl.hair_color, dl.car_make, ...
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.hair_color = 'red' AND dl.car_make = 'Tesla'
ORDER BY p.name;
```

**Execution Plan:**
```
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE on `person` ⚠️ — 10,011 rows
- **Issue:** Filter is on `drivers_license` columns but scan starts from `person`
- **Time:** 0.004157s

---

## Q7 — Interview transcripts mentioning gym or murder
```sql
SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript LIKE '%gym%' OR i.transcript LIKE '%murder%';
```

**Execution Plan:**
```
|--SCAN i
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
```
- **Scan type:** SCAN TABLE on `interview` ⚠️ — 4,991 rows
- **Note:** LIKE '%...%' wildcard cannot use B-tree index — full scan unavoidable
- **Time:** 0.003045s

---

## Q8 — Average income by car make
```sql
SELECT dl.car_make, COUNT(*), AVG(i.annual_income), ...
FROM drivers_license dl
JOIN person p ON dl.id = p.license_id
JOIN income i ON p.ssn = i.ssn
GROUP BY dl.car_make
ORDER BY avg_income DESC;
```

**Execution Plan:**
```
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY
```
- **Scan type:** SCAN TABLE on `person` ⚠️ — 10,011 rows
- **Joins:** Both use PK ✅
- **Issue:** No index on `person.license_id`, temp B-TREE for GROUP BY and ORDER BY
- **Time:** 0.007634s (slowest query)

---

## Summary of Targets

| Query | Table Scanned | Rows | Fix |
|---|---|---|---|
| Q1 | crime_scene_report | 1,228 | Index on (city, type) |
| Q2 | person | 10,011 | Index on license_id |
| Q3 | get_fit_now_check_in | 2,703 | Index on check_in_date |
| Q5 | facebook_event_checkin | 20,011 | Index on date, person_id |
| Q6 | person | 10,011 | Index on license_id |
| Q7 | interview | 4,991 | Cannot fix (LIKE wildcard) |
| Q8 | person | 10,011 | Index on license_id |
