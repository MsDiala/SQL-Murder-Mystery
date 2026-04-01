# explain_indexed.md — After Indexing

> Re-run the same 8 queries after applying your indexes from `indexes.sql`.
> Compare with `explain_baseline.md` — look for Seq Scan → Index Scan improvements.

---

## Q1 — All murders in SQL City

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=8.31..8.31 rows=1 width=53) (actual time=0.451..0.453 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Index Scan using idx_crime_city_type on crime_scene_report  (cost=0.28..8.30 rows=1 width=53) (actual time=0.383..0.400 rows=3 loops=1)
         Index Cond: ((city = 'SQL City'::text) AND (type = 'murder'::text))
 Planning Time: 2.299 ms
 Execution Time: 0.535 ms
(7 rows)

```

---

## Q2 — People with their driver's license details

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=37.584..38.214 rows=7511 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 997kB
   ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=13.756..19.858 rows=7511 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.014..1.109 rows=7511 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=13.416..13.419 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.020..6.064 rows=10007 loops=1)
 Planning Time: 4.199 ms
 Execution Time: 38.651 ms
(11 rows)

```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.019..0.020 rows=0 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.010..0.011 rows=0 loops=1)
         Join Filter: (m.id = ci.membership_id)
         ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.009..0.010 rows=0 loops=1)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
               Filter: (check_in_date = 20180109)
 Planning Time: 1.214 ms
 Execution Time: 0.064 ms
(10 rows)

```

---

## Q4 — Gold gym members and their income

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.024..0.026 rows=0 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.007..0.008 rows=0 loops=1)
         ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.006..0.007 rows=0 loops=1)
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.006..0.006 rows=0 loops=1)
                     Filter: (membership_status = 'gold'::text)
               ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                     Index Cond: (id = m.person_id)
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.904 ms
 Execution Time: 0.068 ms
(13 rows)

```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.050..0.053 rows=0 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.015..0.017 rows=0 loops=1)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.014..0.014 rows=0 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
               Index Cond: (id = fe.person_id)
 Planning Time: 1.750 ms
 Execution Time: 0.117 ms
(10 rows)


```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=269.73..269.74 rows=2 width=40) (actual time=5.980..5.983 rows=3 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..269.72 rows=2 width=40) (actual time=0.904..5.947 rows=3 loops=1)
         ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.492..4.692 rows=4 loops=1)
               Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
               Rows Removed by Filter: 10003
         ->  Index Scan using idx_person_license on person p  (cost=0.28..8.30 rows=1 width=18) (actual time=0.303..0.305 rows=1 loops=4)
               Index Cond: (license_id = dl.id)
 Planning Time: 0.888 ms
 Execution Time: 6.059 ms
(11 rows)

```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.009..0.011 rows=0 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.008..0.009 rows=0 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
   ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
         Index Cond: (id = i.person_id)
 Planning Time: 0.460 ms
 Execution Time: 0.040 ms
(7 rows)

```

---

## Q8 — Average income by car make

**Execution Time:** ___ ms *(baseline: ___ ms | change: ___)*
**Scan Type:** ___
**Index Used:** ___

```
 Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=17.247..17.256 rows=62 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=17.105..17.145 rows=62 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=9.773..15.326 rows=5647 loops=1)
               Hash Cond: (p.ssn = i.ssn)
               ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=5.420..8.885 rows=7511 loops=1)
                     Hash Cond: (p.license_id = dl.id)
                     ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.009..0.717 rows=7511 loops=1)
                     ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=5.356..5.357 rows=10007 loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 567kB
                           ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.008..2.572 rows=10007 loops=1)
               ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=4.333..4.334 rows=7514 loops=1)
                     Buckets: 8192  Batches: 1  Memory Usage: 358kB
                     ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.015..2.010 rows=7514 loops=1)
 Planning Time: 1.488 ms
 Execution Time: 17.409 ms
(19 rows)

```
