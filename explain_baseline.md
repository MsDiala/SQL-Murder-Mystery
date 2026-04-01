# Baseline EXPLAIN ANALYZE Results — PostgreSQL

All queries run before adding any indexes.

---

## Q1 — All murders in SQL City

Execution Plan:
  Sort (cost=34.43..34.44) (actual time=0.279..0.280 rows=3)
    -> Seq Scan on crime_scene_report (actual time=0.024..0.192 rows=3)
         Filter: (city = SQL City AND type = murder)
         Rows Removed by Filter: 1225

- Scan type: Seq Scan on crime_scene_report (1,228 rows)
- Join method: None
- Execution time: 0.324 ms
- Target: Full scan on filter columns -- index candidate

---

## Q2 — People with driver license details

Execution Plan:
  Sort (cost=1215.46..1240.48) (actual time=50.475..52.048 rows=10006)
    -> Hash Join (actual time=6.709..14.592 rows=10006)
         -> Seq Scan on person p (actual time=0.010..1.317 rows=10011)
         -> Seq Scan on drivers_license dl (actual time=6.395..6.398 rows=10007)

- Scan type: Seq Scan on both person and drivers_license
- Join method: Hash Join
- Execution time: 53.399 ms (slowest baseline query)
- Target: No filter -- full scan unavoidable

---

## Q3 — Gym members who checked in on January 9, 2018

Execution Plan:
  Sort (cost=58.12..58.14) (actual time=0.399..0.402 rows=10)
    -> Hash Join (actual time=0.123..0.389 rows=10)
         -> Seq Scan on get_fit_now_check_in ci
              Filter: (check_in_date = 20180109)
              Rows Removed by Filter: 2693
         -> Seq Scan on get_fit_now_member m (184 rows)

- Scan type: Seq Scan on get_fit_now_check_in (2,703 rows)
- Join method: Hash Join
- Execution time: 0.507 ms
- Target: Filter on check_in_date -- index candidate

---

## Q4 — Gold gym members and their income

Execution Plan:
  Sort (actual time=2.748..2.754 rows=49)
    -> Nested Loop (actual time=0.173..2.723 rows=49)
         -> Hash Join (actual time=0.161..2.383 rows=68)
              -> Seq Scan on person p (rows=10011)
              -> Seq Scan on get_fit_now_member m
                   Filter: membership_status = gold
                   Rows Removed by Filter: 116
         -> Index Scan on income using income_pkey

- Scan type: Seq Scan on person (10,011 rows) and get_fit_now_member (184 rows)
- Join method: Hash Join + Nested Loop
- Execution time: 2.784 ms
- Target: membership_status filter -- index candidate

---

## Q5 — People who attended Facebook events in 2018

Execution Plan:
  Sort (actual time=11.523..12.311 rows=5025)
    -> Hash Join (actual time=3.761..9.056 rows=5025)
         -> Seq Scan on facebook_event_checkin fe
              Filter: date BETWEEN 20180101 AND 20181231
              Rows Removed by Filter: 14986
         -> Seq Scan on person p (10011 rows)

- Scan type: Seq Scan on facebook_event_checkin (20,011 rows) and person (10,011 rows)
- Join method: Hash Join
- Execution time: 13.222 ms
- Target: Largest table -- date range filter is a strong index candidate

---

## Q6 — Red-haired Tesla drivers

Execution Plan:
  Sort (actual time=5.126..5.137 rows=4)
    -> Hash Join (actual time=3.626..5.072 rows=4)
         -> Seq Scan on person p (10,011 rows)
         -> Seq Scan on drivers_license dl
              Filter: hair_color = red AND car_make = Tesla
              Rows Removed by Filter: 10003

- Scan type: Seq Scan on person (10,011 rows) and drivers_license (10,007 rows)
- Join method: Hash Join
- Execution time: 5.183 ms
- Target: Composite filter on drivers_license -- strong index candidate

---

## Q7 — Interview transcripts mentioning gym or murder

Execution Plan:
  Nested Loop (actual time=1.174..15.601 rows=4)
    -> Seq Scan on interview i
         Filter: transcript ILIKE '%gym%' OR transcript ILIKE '%murder%'
         Rows Removed by Filter: 4987
    -> Index Scan on person using person_pkey

- Scan type: Seq Scan on interview (4,991 rows)
- Join method: Nested Loop
- Execution time: 15.635 ms
- Note: ILIKE with leading wildcard cannot use B-tree index -- full scan unavoidable

---

## Q8 — Average income by car make

Execution Plan:
  Sort (actual time=22.552..22.562 rows=64)
    -> HashAggregate (actual time=22.414..22.485 rows=64)
         -> Hash Join on person.license_id = drivers_license.id
              -> Hash Join on person.ssn = income.ssn
                   -> Seq Scan on person p (10,011 rows)
                   -> Seq Scan on income i (7,514 rows)
              -> Seq Scan on drivers_license dl (10,007 rows)

- Scan type: Seq Scan on person, income, and drivers_license
- Join method: Hash Join x2 + HashAggregate
- Execution time: 22.635 ms
- Target: person.license_id is the main join column -- index candidate

---

## Summary of Targets

| Query | Table Scanned            | Rows   | Time (ms) | Fix                            |
|-------|--------------------------|--------|-----------|--------------------------------|
| Q1    | crime_scene_report       | 1,228  | 0.324     | Index on (city, type)          |
| Q2    | person + drivers_license | 10,011 | 53.399    | No filter -- unavoidable       |
| Q3    | get_fit_now_check_in     | 2,703  | 0.507     | Index on check_in_date         |
| Q4    | person                   | 10,011 | 2.784     | Index on membership_status     |
| Q5    | facebook_event_checkin   | 20,011 | 13.222    | Index on date, person_id       |
| Q6    | person + drivers_license | 10,011 | 5.183     | Index on (hair_color, car_make)|
| Q7    | interview                | 4,991  | 15.635    | Cannot fix (ILIKE wildcard)    |
| Q8    | person + all tables      | 10,011 | 22.635    | Index on person.license_id     |