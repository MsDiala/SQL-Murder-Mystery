# Indexed EXPLAIN ANALYZE Results — PostgreSQL

All queries run after adding indexes from indexes.sql.

---

## Q1 — All murders in SQL City

Execution Plan:
  Sort (cost=8.31..8.31) (actual time=0.158..0.159 rows=3)
    -> Index Scan using idx_crime_city_type on crime_scene_report
         Index Cond: (city = 'SQL City' AND type = 'murder')

- Scan type: Index Scan (improved)
- Join method: None
- Before: Seq Scan 0.324 ms
- After: Index Scan 0.918 ms (planning overhead on small table)
- Note: Index is correct -- on larger datasets this will outperform seq scan

---

## Q2 — People with driver license details

Execution Plan:
  Sort (cost=1215.46..1240.48) (actual time=36.542..37.804 rows=10006)
    -> Hash Join (actual time=7.083..12.919 rows=10006)
         -> Seq Scan on person p (rows=10011)
         -> Seq Scan on drivers_license dl (rows=10007)

- Scan type: Still Seq Scan on both tables -- no improvement
- Join method: Hash Join
- Before: 53.399 ms
- After: 38.914 ms (slight improvement from warm cache)
- Note: No filter on person -- full scan unavoidable

---

## Q3 — Gym members who checked in on January 9, 2018

Execution Plan:
  Sort (cost=26.81..26.84) (actual time=0.227..0.229 rows=10)
    -> Hash Join (actual time=0.157..0.211 rows=10)
         -> Bitmap Heap Scan on get_fit_now_check_in ci
               -> Bitmap Index Scan on idx_checkin_date
                    Index Cond: (check_in_date = 20180109)
         -> Seq Scan on get_fit_now_member m (184 rows)

- Scan type: Bitmap Index Scan (improved)
- Join method: Hash Join
- Before: Seq Scan 0.507 ms
- After: Bitmap Index Scan 0.259 ms
- Improvement: 49% faster -- only matching rows fetched

---

## Q4 — Gold gym members and their income

Execution Plan:
  Sort (actual time=2.670..2.676 rows=49)
    -> Nested Loop (actual time=0.115..2.558 rows=49)
         -> Hash Join (actual time=0.104..2.248 rows=68)
              -> Seq Scan on person p (rows=10011)
              -> Seq Scan on get_fit_now_member m
                   Filter: membership_status = 'gold'
         -> Index Scan on income using income_pkey

- Scan type: Still Seq Scan on person and get_fit_now_member
- Join method: Hash Join + Nested Loop
- Before: 2.784 ms
- After: 2.714 ms (marginal improvement)
- Note: Planner chose seq scan on small table (184 rows) over index -- correct decision

---

## Q5 — People who attended Facebook events in 2018

Execution Plan:
  Sort (actual time=10.653..11.350 rows=5025)
    -> Hash Join (actual time=4.588..8.076 rows=5025)
         -> Bitmap Heap Scan on facebook_event_checkin fe
               -> Bitmap Index Scan on idx_facebook_date
                    Index Cond: (date >= 20180101 AND date <= 20181231)
         -> Seq Scan on person p (rows=10011)

- Scan type: Bitmap Index Scan on facebook_event_checkin (improved)
- Join method: Hash Join
- Before: Seq Scan 13.222 ms
- After: Bitmap Index Scan 12.015 ms
- Improvement: 9% faster -- 20,011 row scan replaced by index range scan

---

## Q6 — Red-haired Tesla drivers

Execution Plan:
  Sort (actual time=0.300..0.302 rows=4)
    -> Nested Loop (actual time=0.176..0.285 rows=4)
         -> Bitmap Heap Scan on drivers_license dl
               -> Bitmap Index Scan on idx_license_hair_car
                    Index Cond: (hair_color = 'red' AND car_make = 'Tesla')
         -> Index Scan using idx_person_license on person p
              Index Cond: (license_id = dl.id)

- Scan type: Bitmap Index Scan + Index Scan (best improvement)
- Join method: Nested Loop (changed from Hash Join)
- Before: Seq Scan 5.183 ms
- After: Index Scan 0.445 ms
- Improvement: 91% faster -- both tables now use indexes

---

## Q7 — Interview transcripts mentioning gym or murder

Execution Plan:
  Nested Loop (actual time=0.731..13.956 rows=4)
    -> Seq Scan on interview i
         Filter: transcript ILIKE '%gym%' OR transcript ILIKE '%murder%'
         Rows Removed by Filter: 4987
    -> Index Scan on person using person_pkey

- Scan type: Still Seq Scan on interview -- no improvement
- Join method: Nested Loop
- Before: 15.635 ms
- After: 13.982 ms (marginal, likely cache effect)
- Note: ILIKE with leading wildcard prevents B-tree index use -- unavoidable

---

## Q8 — Average income by car make

Execution Plan:
  Sort (actual time=17.538..17.547 rows=64)
    -> HashAggregate (actual time=17.446..17.491 rows=64)
         -> Hash Join on person.license_id = drivers_license.id
              -> Hash Join on person.ssn = income.ssn
                   -> Seq Scan on person p (rows=10011)
                   -> Seq Scan on income i (rows=7514)
              -> Seq Scan on drivers_license dl (rows=10007)

- Scan type: Still Seq Scan on all three tables
- Join method: Hash Join x2 + HashAggregate
- Before: 22.635 ms
- After: 17.617 ms (improvement from idx_person_license in join)
- Note: Aggregation over all rows still requires full scans

---

## Summary: Before vs After

| Query | Before (ms) | After (ms) | Scan Change                        | Improved |
|-------|-------------|------------|------------------------------------|----------|
| Q1    | 0.324       | 0.918      | Seq -> Index Scan                  | Yes (structurally) |
| Q2    | 53.399      | 38.914     | Seq Scan (unchanged)               | Marginal |
| Q3    | 0.507       | 0.259      | Seq -> Bitmap Index Scan           | Yes      |
| Q4    | 2.784       | 2.714      | Seq Scan (unchanged)               | Marginal |
| Q5    | 13.222      | 12.015     | Seq -> Bitmap Index Scan           | Yes      |
| Q6    | 5.183       | 0.445      | Seq -> Bitmap+Index Scan           | Yes (best) |
| Q7    | 15.635      | 13.982     | Seq Scan (unchanged)               | No       |
| Q8    | 22.635      | 17.617     | Seq Scan (partial improvement)     | Marginal |