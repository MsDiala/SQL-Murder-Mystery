# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=1.138..1.141 rows=3 loops=1)
   Sort Key: date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.099..0.784 rows=3 loops=1)
         Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
         Rows Removed by Filter: 1225
 Planning Time: 2.633 ms
 Execution Time: 1.927 ms
(8 rows)

```

---

## Q2 — People with their driver's license details

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Sort  (cost=1002.51..1021.29 rows=7511 width=60) (actual time=26.864..27.416 rows=7511 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 997kB
   ->  Hash Join  (cost=328.16..519.00 rows=7511 width=60) (actual time=10.466..14.419 rows=7511 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=36) (actual time=0.012..0.775 rows=7511 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=7.592..7.595 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.012..3.549 rows=10007 loops=1)
 Planning Time: 6.249 ms
 Execution Time: 28.063 ms
(11 rows)

```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Sort  (cost=0.02..0.03 rows=1 width=72) (actual time=0.085..0.087 rows=0 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.00..0.01 rows=1 width=72) (actual time=0.020..0.022 rows=0 loops=1)
         Join Filter: (m.id = ci.membership_id)
         ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=96) (actual time=0.019..0.019 rows=0 loops=1)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..0.00 rows=1 width=40) (never executed)
               Filter: (check_in_date = 20180109)
 Planning Time: 1.309 ms
 Execution Time: 0.475 ms
(10 rows)

```

---

## Q4 — Gold gym members and their income

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Sort  (cost=8.64..8.65 rows=1 width=68) (actual time=0.009..0.010 rows=0 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.56..8.63 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
         ->  Nested Loop  (cost=0.28..8.30 rows=1 width=68) (actual time=0.004..0.005 rows=0 loops=1)
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..0.00 rows=1 width=68) (actual time=0.004..0.004 rows=0 loops=1)
                     Filter: (membership_status = 'gold'::text)
               ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=8) (never executed)
                     Index Cond: (id = m.person_id)
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.33 rows=1 width=8) (never executed)
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.629 ms
 Execution Time: 0.041 ms
(13 rows)

```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
--------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=8.31..8.32 rows=1 width=50) (actual time=0.011..0.012 rows=0 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=0.28..8.30 rows=1 width=50) (actual time=0.005..0.006 rows=0 loops=1)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..0.00 rows=1 width=40) (actual time=0.005..0.005 rows=0 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
         ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
               Index Cond: (id = fe.person_id)
 Planning Time: 0.196 ms
 Execution Time: 0.034 ms
(10 rows)

```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Sort  (cost=443.98..443.98 rows=2 width=40) (actual time=9.148..9.156 rows=3 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..443.97 rows=2 width=40) (actual time=6.561..9.118 rows=3 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=18) (actual time=0.015..1.709 rows=7511 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=4.681..4.683 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.422..4.661 rows=4 loops=1)
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 0.523 ms
 Execution Time: 9.221 ms
(13 rows)

```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Nested Loop  (cost=0.28..8.30 rows=1 width=46) (actual time=0.022..0.024 rows=0 loops=1)
   ->  Seq Scan on interview i  (cost=0.00..0.00 rows=1 width=36) (actual time=0.020..0.021 rows=0 loops=1)
         Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text))
   ->  Index Scan using person_pkey on person p  (cost=0.28..8.30 rows=1 width=18) (never executed)
         Index Cond: (id = i.person_id)
 Planning Time: 1.503 ms
 Execution Time: 0.094 ms
(7 rows)

```

---

## Q8 — Average income by car make

**Execution Time:** ___ ms
**Scan Type:** ___
**Join Method:** ___

```
 Sort  (cost=838.61..838.77 rows=65 width=55) (actual time=15.179..15.187 rows=62 loops=1)
   Sort Key: (round(avg(i.annual_income), 0)) DESC
   Sort Method: quicksort  Memory: 29kB
   ->  HashAggregate  (cost=835.68..836.65 rows=65 width=55) (actual time=14.794..14.830 rows=62 loops=1)
         Group Key: dl.car_make
         Batches: 1  Memory Usage: 32kB
         ->  Hash Join  (cost=531.22..741.79 rows=7511 width=11) (actual time=7.924..12.853 rows=5647 loops=1)
               Hash Cond: (p.ssn = i.ssn)
               ->  Hash Join  (cost=328.16..519.00 rows=7511 width=11) (actual time=4.468..7.639 rows=7511 loops=1)
                     Hash Cond: (p.license_id = dl.id)
                     ->  Seq Scan on person p  (cost=0.00..171.11 rows=7511 width=8) (actual time=0.007..0.616 rows=7511 loops=1)
                     ->  Hash  (cost=203.07..203.07 rows=10007 width=11) (actual time=4.351..4.352 rows=10007 loops=1)
                           Buckets: 16384  Batches: 1  Memory Usage: 567kB
                           ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=11) (actual time=0.006..2.008 rows=10007 loops=1)
               ->  Hash  (cost=109.14..109.14 rows=7514 width=8) (actual time=3.403..3.403 rows=7514 loops=1)
                     Buckets: 8192  Batches: 1  Memory Usage: 358kB
                     ->  Seq Scan on income i  (cost=0.00..109.14 rows=7514 width=8) (actual time=0.058..1.600 rows=7514 loops=1)
 Planning Time: 2.863 ms
 Execution Time: 15.837 ms
(19 rows)

```
