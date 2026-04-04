# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

Q1 — After Index

- Scan Type: Index Scan (using idx_crime_city_type)
- Execution Time: 0.112 ms
- Improvement: Query performance improved significantly after adding the index.
- Reason: The index allows PostgreSQL to directly locate rows matching city and type instead of scanning the entire table.
```

---

## Q2 — People with their driver's license details

Q2 — After Index

- Scan Type: Index Scan (on both person and drivers_license)
- Execution Time: ~20 ms
- Improvement: The query now uses indexes instead of sequential scans, improving join efficiency.
- Reason: Indexes on join keys (person.license_id and drivers_license.id) allow faster matching between tables.
- Note: Execution time did not improve significantly due to sorting (ORDER BY p.name).


## Q3 — Gym members who checked in on January 9, 2018

 After Index

- Scan Type: Bitmap Index Scan + Index Scan
- Execution Time: 0.097 ms (baseline: ~111 ms | change: significantly faster)
- Improvement: Massive performance improvement after adding index on check_in_date.
- Reason: The index allows PostgreSQL to quickly filter rows by date instead of scanning the entire table.
---

## Q4 — Gold gym members and their income

After Index

- Scan Type: Bitmap Index Scan + Index Scan
- Execution Time: 0.580 ms (baseline: ~62 ms | change: significantly faster)
- Improvement: Major performance improvement after adding index on membership_status.
- Reason: The index allows efficient filtering of gold members before performing joins.
---

## Q5 — People who attended Facebook events in 2018

— After Index

- Scan Type: Bitmap Index Scan (GIN) + Index Scan
- Execution Time: 0.035 ms
- Improvement: Query performance improved significantly after using full-text search instead of LIKE.
- Reason: The GIN index allows PostgreSQL to search for keywords inside text efficiently, while LIKE '%...%' requires scanning all rows.

---

## Q6 — Red-haired Tesla drivers

 — After Index

- Scan Type: Bitmap Index Scan
- Execution Time: 0.212 ms
- Improvement: Query performance improved after adding a composite index.
- Reason: The index on (hair_color, car_make) allows PostgreSQL to efficiently filter matching rows instead of scanning the entire table.

---

## Q7 — Interview transcripts mentioning the gym or murder

— After Index

- Scan Type: Bitmap Index Scan (GIN)
- Execution Time: 0.268 ms
- Improvement: Query performance improved significantly using full-text search.
- Reason: GIN index allows efficient searching of keywords instead of scanning all rows with LIKE.

---

## Q8 — Average income by car make

 — After Index

- Scan Type: Index Scan + Merge Join + Hash Join
- Execution Time: 10.529 ms
- Improvement: Query performance improved after indexing join columns.
- Reason: Indexes on join keys (license_id and ssn) allow faster joins between tables, reducing the need for full scans.
```
