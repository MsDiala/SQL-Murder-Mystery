# explain_baseline.md — Before Indexing

> Run each query with `EXPLAIN ANALYZE` and paste the full output below.
>
> **Connect:** `docker exec -it murder_db psql -U postgres -d murder_mystery`




**Date:** April 4, 2026

## Q1 — All murders in SQL City
**Execution Time:** 0.73 ms  
**Scan Type:** Seq Scan  
**Join Method:** -



## Q2 — People with their driver's license details
**Execution Time:** 51.20 ms  
**Scan Type:** Seq Scan (on person + drivers_license)  
**Join Method:** Hash Join



## Q3 — Gym members who checked in on January 9, 2018
**Execution Time:** 0.70 ms  
**Scan Type:** Seq Scan  
**Join Method:** Hash Join




## Q4 — Gold gym members and their income
**Execution Time:** 4.85 ms  
**Scan Type:** Seq Scan on person  
**Join Method:** Hash Join + Nested Loop





## Q5 — People who attended Facebook events in 2018
**Execution Time:** 18.20 ms  
**Scan Type:** Seq Scan on facebook_event_checkin  
**Join Method:** Hash Join



## Q6 — Red-haired Tesla drivers
**Execution Time:** 5.26 ms  
**Scan Type:** Seq Scan on drivers_license  
**Join Method:** Hash Join






## Q7 — Interview transcripts mentioning the gym or murder
**Execution Time:** 29.70 ms  
**Scan Type:** Seq Scan on interview  
**Join Method:** Nested Loop



## Q8 — Average income by car make
**Execution Time:** 20.14 ms  
**Scan Type:** Seq Scan on person  
**Join Method:** Hash Join (x2) + HashAggregate




**Summary:** Several queries (especially Q2, Q5, Q7, Q8) were using slow Seq Scans on large tables.
