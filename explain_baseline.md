# explain_baseline.md - Before Indexing

> Run each query with `EXPLAIN QUERY PLAN` and paste the output below.
> Also run `.timer on` before each query to capture execution time.
>
> **Connect:** `sqlite3 sql-murder-mystery.db`
> Then type: `.timer on`

---

## Q1 - All murders in SQL City

**Execution Time:** 0.09 ms
**Scan Type:** `SCAN TABLE crime_scene_report` (full scan)
**Notes:** No index on `(city, type)`, so SQLite scans `crime_scene_report`, then sorts by `date` using a temp B-tree.

```
QUERY PLAN
|--SCAN crime_scene_report
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q2 - People with their driver's license details

**Execution Time:** 0.10 ms
**Scan Type:** `SCAN TABLE person` (`p`)
**Notes:** Joins `drivers_license` by its primary key, but `ORDER BY p.name` requires sorting (temp B-tree) because `person.name` isn't indexed.

```
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q3 - Gym members who checked in on January 9, 2018

**Execution Time:** 0.11 ms
**Scan Type:** `SCAN TABLE get_fit_now_check_in` (`ci`)
**Notes:** Filter on `ci.check_in_date` can't use an index, so it scans `get_fit_now_check_in`; join to member uses the existing autoindex on `get_fit_now_member.id`; `ORDER BY ci.check_in_time` needs a temp sort.

```
QUERY PLAN
|--SCAN ci
|--SEARCH m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q4 - Gold gym members and their income

**Execution Time:** 0.10 ms
**Scan Type:** `SCAN TABLE get_fit_now_member` (`m`) *(small table)*
**Notes:** No index on `m.membership_status`, so it scans `get_fit_now_member` (184 rows). Join lookups for `person` and `income` use primary-key indexes; `ORDER BY i.annual_income DESC` requires sorting.

```
QUERY PLAN
|--SCAN m
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q5 - People who attended Facebook events in 2018

**Execution Time:** 0.11 ms
**Scan Type:** `SCAN TABLE facebook_event_checkin` (`fe`) *(large table)*
**Notes:** Date-range filter on `fe.date` can't use an index, so it scans all event rows, then sorts by `fe.date` using a temp B-tree.

```
QUERY PLAN
|--SCAN fe
|--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q6 - Red-haired Tesla drivers

**Execution Time:** 0.10 ms
**Scan Type:** `SCAN TABLE person` (`p`)
**Notes:** Because there's no index on `drivers_license(hair_color, car_make)`, the `WHERE` clause can't be applied via index search; planner scans `person` and joins `drivers_license` by PK, then sorts for `ORDER BY p.name`.

```
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
`--USE TEMP B-TREE FOR ORDER BY
```

---

## Q7 - Interview transcripts mentioning the gym or murder

**Execution Time:** 0.10 ms
**Scan Type:** `SCAN TABLE interview` (`i`)
**Notes:** Leading-wildcard `LIKE '%gym%'` / `LIKE '%murder%'` prevents normal B-tree index usage, so it scans `interview`. Join to `person` uses primary key.

```
QUERY PLAN
|--SCAN i
`--SEARCH p USING INTEGER PRIMARY KEY (rowid=?)
```

---

## Q8 - Average income by car make

**Execution Time:** 0.11 ms
**Scan Type:** `SCAN TABLE person` (`p`)
**Notes:** Joins use primary-key lookups, but there's no index to avoid scanning `person`. Both `GROUP BY` and `ORDER BY` require temp B-trees.

```
QUERY PLAN
|--SCAN p
|--SEARCH dl USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH i USING INTEGER PRIMARY KEY (rowid=?)
|--USE TEMP B-TREE FOR GROUP BY
`--USE TEMP B-TREE FOR ORDER BY
```
