# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`

---

## Q1 — All murders in SQL City

**Execution Time:** 0.441 ms  
**Scan Type:** Seq Scan  
**Join Method:** N/A
```
Sort  (cost=34.43..34.44 rows=1 width=53) (actual time=0.398..0.399 rows=3 loops=1)
  Sort Key: date DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Seq Scan on crime_scene_report  (cost=0.00..34.42 rows=1 width=53) (actual time=0.022..0.365 rows=3 loops=1)
        Filter: ((city = 'SQL City'::text) AND (type = 'murder'::text))
        Rows Removed by Filter: 1225
Planning Time: 1.040 ms
Execution Time: 0.441 ms
```
---

## Q2 — People with their driver's license details

**Execution Time:** 19.072 ms  
**Scan Type:** Seq Scan  
**Join Method:** Hash Join

```
 Sort  (cost=1215.46..1240.48 rows=10007 width=60) (actual time=18.141..18.651 rows=10006 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 1456kB
   ->  Hash Join  (cost=328.16..550.56 rows=10007 width=60) (actual time=3.810..6.713 rows=10006 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=36) (actual time=0.005..0.534 rows=10011 loops=1)
         ->  Hash  (cost=203.07..203.07 rows=10007 width=32) (actual time=3.685..3.686 rows=10007 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 793kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..203.07 rows=10007 width=32) (actual time=0.004..1.508 rows=10007 loops=1)
 Planning Time: 1.115 ms
 Execution Time: 19.072 ms


```

---

## Q3 — Gym members who checked in on January 9, 2018

**Execution Time:** 0.495 ms  
**Scan Type:** Seq Scan  
**Join Method:** Hash Join
```
Sort  (cost=58.12..58.14 rows=10 width=28) (actual time=0.444..0.447 rows=10 loops=1)
   Sort Key: ci.check_in_time
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=6.14..57.95 rows=10 width=28) (actual time=0.156..0.403 rows=10 loops=1)
         Hash Cond: (ci.membership_id = m.id)
         ->  Seq Scan on get_fit_now_check_in ci  (cost=0.00..51.79 rows=10 width=14) (actual time=0.017..0.256 rows=10 loops=1)   
               Filter: (check_in_date = 20180109)
               Rows Removed by Filter: 2693
         ->  Hash  (cost=3.84..3.84 rows=184 width=26) (actual time=0.125..0.125 rows=184 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 19kB
               ->  Seq Scan on get_fit_now_member m  (cost=0.00..3.84 rows=184 width=26) (actual time=0.005..0.030 rows=184 loops=1)
 Planning Time: 1.318 ms
 Execution Time: 0.495 ms

```

---

## Q4 — Gold gym members and their income

**Execution Time:** 2.245 ms  
**Scan Type:** Seq Scan / Index Scan  
**Join Method:** Nested Loop
```
Sort  (cost=262.88..263.00 rows=51 width=24) (actual time=2.121..2.126 rows=49 loops=1)
   Sort Key: i.annual_income DESC
   Sort Method: quicksort  Memory: 28kB
   ->  Nested Loop  (cost=5.43..261.43 rows=51 width=24) (actual time=0.120..2.063 rows=49 loops=1)
         ->  Hash Join  (cost=5.15..239.48 rows=68 width=24) (actual time=0.106..1.743 rows=68 loops=1)
               Hash Cond: (p.id = m.person_id)
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=8) (actual time=0.006..0.658 rows=10011 loops=1)      
               ->  Hash  (cost=4.30..4.30 rows=68 width=24) (actual time=0.078..0.078 rows=68 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 12kB
                     ->  Seq Scan on get_fit_now_member m  (cost=0.00..4.30 rows=68 width=24) (actual time=0.027..0.054 rows=68 loops=1)
                           Filter: (membership_status = 'gold'::text)
                           Rows Removed by Filter: 116
         ->  Index Scan using income_pkey on income i  (cost=0.28..0.32 rows=1 width=8) (actual time=0.004..0.004 rows=1 loops=68) 
               Index Cond: (ssn = p.ssn)
 Planning Time: 0.734 ms
 Execution Time: 2.245 ms

```

---

## Q5 — People who attended Facebook events in 2018

**Execution Time:** 6.550 ms  
**Scan Type:** Seq Scan  
**Join Method:** Hash Join

```
 Sort  (cost=1159.80..1172.27 rows=4987 width=63) (actual time=6.072..6.350 rows=5025 loops=1)
   Sort Key: fe.date DESC
   Sort Method: quicksort  Memory: 723kB
   ->  Hash Join  (cost=321.25..853.50 rows=4987 width=63) (actual time=2.341..4.889 rows=5025 loops=1)
         Hash Cond: (fe.person_id = p.id)
         ->  Seq Scan on facebook_event_checkin fe  (cost=0.00..519.16 rows=4987 width=53) (actual time=0.013..1.875 rows=5025 loops=1)
               Filter: ((date >= 20180101) AND (date <= 20181231))
               Rows Removed by Filter: 14986
         ->  Hash  (cost=196.11..196.11 rows=10011 width=18) (actual time=2.248..2.248 rows=10011 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 639kB
               ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.003..0.875 rows=10011 loops=1)     
 Planning Time: 0.534 ms
 Execution Time: 6.550 ms

```

---

## Q6 — Red-haired Tesla drivers

**Execution Time:** 3.319 ms  
**Scan Type:** Seq Scan  
**Join Method:** Hash Join

```
Sort  (cost=475.54..475.54 rows=2 width=40) (actual time=3.217..3.218 rows=4 loops=1)
   Sort Key: p.name
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=253.13..475.53 rows=2 width=40) (actual time=2.613..3.173 rows=4 loops=1)
         Hash Cond: (p.license_id = dl.id)
         ->  Seq Scan on person p  (cost=0.00..196.11 rows=10011 width=18) (actual time=0.027..0.472 rows=10011 loops=1)
         ->  Hash  (cost=253.10..253.10 rows=2 width=30) (actual time=1.958..1.958 rows=4 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on drivers_license dl  (cost=0.00..253.10 rows=2 width=30) (actual time=0.234..1.945 rows=4 loops=1)   
                     Filter: ((hair_color = 'red'::text) AND (car_make = 'Tesla'::text))
                     Rows Removed by Filter: 10003
 Planning Time: 1.368 ms
 Execution Time: 3.319 ms
```

---

## Q7 — Interview transcripts mentioning the gym or murder

**Execution Time:** 6.704 ms  
**Scan Type:** Seq Scan  
**Join Method:** Nested Loop

```
Nested Loop (cost=0.29..134.17 rows=1 width=61) (actual time=0.334..6.646 rows=4 loops=1) -> Seq Scan on interview i (cost=0.00..125.86 rows=1 width=51) (actual time=0.326..6.625 rows=4 loops=1) Filter: ((transcript ~~* '%gym%'::text) OR (transcript ~~* '%murder%'::text)) Rows Removed by Filter: 4987 -> Index Scan using person_pkey on person p (cost=0.29..8.30 rows=1 width=18) (actual time=0.004..0.004 rows=1 loops=4) Index Cond: (id = i.person_id) Planning Time: 1.022 ms Execution Time: 6.704 ms 
```

---

## Q8 — Average income by car make

**Execution Time:** 11.562 ms
**Scan Type:** Seq Scan + Index Scan
**Join Method:** Hash Join

```
car_make | drivers | avg_income | min_income | max_income ---------------+---------+------------+------------+------------ Bugatti | 4 | 133225 | 41900 | 362300 Tesla | 8 | 107863 | 12400 | 310000 FIAT | 1 | 77100 | 77100 | 77100 Foose | 1 | 67700 | 67700 | 67700 Daewoo | 23 | 65187 | 11000 | 357600 Ferrari | 27 | 60496 | 13000 | 324300 Scion | 41 | 60241 | 10000 | 324800 Porsche | 84 | 59415 | 10100 | 422200 Peugeot | 3 | 57867 | 44700 | 73600 Bentley | 69 | 57599 | 11700 | 431400 Oldsmobile | 80 | 57599 | 10100 | 403800 Eagle | 1 | 57500 | 57500 | 57500 Mercury | 116 | 56610 | 10100 | 112500 Plymouth | 20 | 56180 | 12100 | 168300 Pontiac | 158 | 56162 | 10000 | 448000 Subaru | 109 | 56131 | 10600 | 402400 Maybach | 41 | 56098 | 11500 | 89500 Chrysler | 133 | 55325 | 10200 | 475700 Volvo | 185 | 55286 | 11400 | 440900 GMC | 370 | 55141 | 10000 | 407100 Lexus | 225 | 54740 | 10100 | 498500 Suzuki | 141 | 54532 | 10200 | 426200 Land Rover | 110 | 54458 | 10200 | 439500 Acura | 151 | 54258 | 11100 | 446200 Lamborghini | 47 | 54091 | 11300 | 348300 Spyker | 7 | 53957 | 36200 | 80500 Honda | 212 | 53832 | 11200 | 489800 BMW | 292 | 53699 | 10100 | 312800 Jeep | 100 | 53680 | 10700 | 394900 Mercedes-Benz | 257 | 53653 | 10300 | 486600 Infiniti | 127 | 53511 | 10000 | 406100 Saab | 65 | 53292 | 10700 | 89800 Chevrolet | 589 | 52950 | 10000 | 446000 Hyundai | 180 | 52762 | 11000 | 400500 Maserati | 24 | 52725 | 11000 | 85300 Lotus | 34 | 52409 | 10200 | 88900Audi | 208 | 52160 | 10600 | 476300 Ford | 568 | 52034 | 10000 | 473100 Aptera | 13 | 51892 | 14500 | 87000 Mitsubishi | 214 | 51595 | 11000 | 88800 Mazda | 250 | 51582 | 10200 | 325200 Lincoln | 130 | 51538 | 10000 | 285600 Toyota | 449 | 51421 | 10000 | 449400 Ram | 7 | 51414 | 11500 | 87800 Panoz | 7 | 51186 | 17000 | 79100 Kia | 136 | 50928 | 10000 | 89600 Jaguar | 85 | 50885 | 10000 | 89500 Dodge | 345 | 50626 | 10100 | 410200 Buick | 113 | 49940 | 10200 | 89300 Isuzu | 74 | 49520 | 10600 | 88400 Aston Martin | 80 | 49259 | 11700 | 88900 Morgan | 8 | 48975 | 15200 | 81800 Volkswagen | 183 | 47893 | 10500 | 89900 Saturn | 52 | 47175 | 11500 | 81600 Smart | 16 | 47150 | 12400 | 86100 Panoz | 7 | 51186 | 17000 | 79100 Kia | 136 | 50928 | 10000 | 89600 Jaguar | 85 | 50885 | 10000 | 89500 Dodge | 345 | 50626 | 10100 | 410200 Buick | 113 | 49940 | 10200 | 89300 Isuzu | 74 | 49520 | 10600 | 88400 Aston Martin | 80 | 49259 | 11700 | 88900 Morgan | 8 | 48975 | 15200 | 81800 Volkswagen | 183 | 47893 | 10500 | 89900 Saturn | 52 | 47175 | 11500 | 81600 Smart | 16 | 47150 | 12400 | 86100 MINI | 34 | 45497 | 10500 | 89400 Rolls-Royce | 23 | 44674 | 13100 | 89600 Spyker Cars | 6 | 42733 | 10900 | 87000 HUMMER | 21 | 41381 | 10300 | 78400 Fiat | 1 | 33100 | 33100 | 33100 McLaren | 1 | 13000 | 13000 | 13000 
```
