# Indexed EXPLAIN QUERY PLAN Results

All queries run after adding indexes from indexes.sql.
Timer enabled to capture execution time.

---

## Q1 — All murders in SQL City

**Execution Plan:**
```
|--SEARCH crime_scene_report USING INDEX idx_crime_city_type (city=? AND type=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- Scan type: SEARCH USING INDEX (improved)
- Before: SCAN TABLE — full scan of 1,228 rows
- After: Index lookup — only matching rows read
- Time: 0.006106s

---

## Q2 — People with driver's license details

**Execution Plan:**
```
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- Scan type: Still SCAN TABLE on person — no improvement
- Before: SCAN p — 10,011 rows
- After: SCAN p — 10,011 rows (unchanged)
- Time: 0.004164s
- Note: No filter on person — full scan is unavoidable for this query

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Plan:**
```
|--SEARCH ci USING INDEX idx_checkin_date (check_in_date=?)
|--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- Scan type: SEARCH USING INDEX (improved)
- Before: SCAN ci — 2,703 rows
- After: Index lookup on check_in_date — only matching rows read
- Time: 0.006376s

---

## Q4 — Gold gym members and their income

**Execution Plan:**
```
|--SEARCH m USING INDEX idx_member_status (membership_status=?)
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- Scan type: SEARCH USING INDEX (improved)
- Before: SCAN m — 184 rows
- After: Index lookup on membership_status
- Time: 0.008435s
- Note: Table was small so practical improvement is marginal

---

## Q5 — People who attended Facebook events in 2018

**Execution Plan:**
```
|--SEARCH fe USING INDEX idx_facebook_date (date>? AND date<?)
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
```
- Scan type: SEARCH USING INDEX (best improvement)
- Before: SCAN fe — 20,011 rows, with temp B-TREE for ORDER BY
- After: Index range scan + ORDER BY eliminated
- Time: 0.005017s
- Note: Largest table in database — biggest practical gain

---

## Q6 — Red-haired Tesla drivers

**Execution Plan:**
```
|--SEARCH dl USING INDEX idx_license_hair_car (hair_color=? AND car_make=?)
|--SEARCH p USING INDEX idx_person_license (license_id=?)
`--USE TEMP B-TREE FOR ORDER BY
```
- Scan type: Both tables now use indexes (improved)
- Before: SCAN p — 10,011 rows
- After: Starts from filtered drivers_license rows, then looks up person by license_id
- Time: 0.007531s

---

## Q7 — Interview transcripts mentioning gym or murder

**Execution Plan:**
```
|--SCAN i
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
```
- Scan type: Still SCAN TABLE on interview — no improvement
- Before: SCAN i — 4,991 rows
- After: SCAN i — 4,991 rows (unchanged)
- Time: 0.003040s
- Note: LIKE '%gym%' wildcard at start prevents B-tree index use — full scan unavoidable

---

## Q8 — Average income by car make

**Execution Plan:**
```
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY
```
- Scan type: Still SCAN TABLE on person — no improvement
- Before: SCAN p — 10,011 rows
- After: SCAN p — 10,011 rows (unchanged)
- Time: 0.007940s
- Note: Aggregation over all rows requires full scan regardless of indexes

---

## Summary: Before vs After

| Query | Before              | After                          | Improved |
|-------|---------------------|--------------------------------|----------|
| Q1    | SCAN 1,228 rows     | SEARCH idx_crime_city_type     | Yes      |
| Q2    | SCAN 10,011 rows    | SCAN 10,011 rows               | No       |
| Q3    | SCAN 2,703 rows     | SEARCH idx_checkin_date        | Yes      |
| Q4    | SCAN 184 rows       | SEARCH idx_member_status       | Yes      |
| Q5    | SCAN 20,011 rows    | SEARCH idx_facebook_date       | Yes      |
| Q6    | SCAN 10,011 rows    | SEARCH idx_license_hair_car    | Yes      |
| Q7    | SCAN 4,991 rows     | SCAN 4,991 rows                | No       |
| Q8    | SCAN 10,011 rows    | SCAN 10,011 rows               | No       |
