# Performance Report

## 1. Most Improved Queries
- **Q6 (Red-haired Tesla drivers):** Execution time dropped significantly from 4.100 ms to 0.145 ms. The composite index on `(hair_color, car_make)` allowed PostgreSQL to use a `Bitmap Index Scan` instead of a `Seq Scan`. Since the query was highly selective (returning only 4 rows out of 10,007), index lookup vastly outperformed a full table scan.
- **Q1 (All murders in SQL City) & Q3 (Gym check-ins by date):** Both saw execution times cut roughly in half (e.g., 0.450 ms -> 0.209 ms for Q3). The planner was able to perform `Index Scans` and `Bitmap Index Scans` instead of full sequence scans because the filter conditions (date, city, type) narrowed the result set efficiently.
- **Q5 (Facebook events in 2018):** Showed moderate improvement using a `Bitmap Index Scan` on the `date` column, skipping full scan despite returning a significant number of rows.

## 2. Queries with No Improvement
- **Q2 (People with driver's license details) & Q8 (Average income by car make):** Execution times remained identical (or slightly higher due to caching/overhead variations). PostgreSQL completely ignored the created index and stuck with a `Seq Scan` and `Hash Join`. This happens because the query fetches a huge portion of the tables (thousands of rows) to join or aggregate, making a full sequence scan more efficient than performing thousands of individual index lookups.
- **Q7 (Interview transcripts mentioning gym or murder):** No improvement (15.964 ms -> 15.953 ms). The query uses `ILIKE '%...%'` wildcard matching. A standard B-tree index cannot optimize searches with a leading wildcard (`%`), forcing the engine to fall back to a full `Seq Scan` on the `interview` table.
- **Q4 (Gold gym members and income):** Execution was unchanged. The `get_fit_now_member` table is tiny (184 rows). The overhead of using an index is often higher than simply scanning the entire small table into memory.

## 3. The Tradeoffs
Adding indexes speeds up data retrieval (`SELECT` queries) by reducing the number of disk accesses required. However, there are significant tradeoffs:
- **Write Performance Degradation:** Every time records are `INSERT`ed, `UPDATE`d, or `DELETE`d, the database must also update the active indexes, slowing down write-heavy operations.
- **Storage Profile:** Indexes consume additional disk space and memory.
- **Planner Decisions:** As observed, the database planner evaluates if an index is worth using. Adding an unnecessary index creates the write/storage penalties without any read benefits if PostgreSQL opts for a Seq Scan anyway limit.

## 4. Production Recommendations
I would recommend keeping the following indexes, as they tangibly accelerated highly-selective queries:
1. `idx_license_hair_car ON drivers_license(hair_color, car_make)`: Crucial for extremely specific search parameters where full table scans on large tables (10k+ rows) are wasteful.
2. `idx_checkin_date ON get_fit_now_check_in(check_in_date)`: Dates are frequently queried ranges in production systems, making this index highly reusable.
3. `idx_crime_city_type ON crime_scene_report(city, type)`: Reduces latency for common lookup dashboards filtering simple facts like location and incident type.
4. `idx_facebook_date ON facebook_event_checkin(date)`: Beneficial for bounding the date-range query.

Indexes that should be **dropped**:
- `idx_person_license_id` and `idx_person_ssn`: These didn't improve our heavy aggregation or bulk-join queries (Q2, Q8).
- `idx_member_status`: Table is too small to benefit.
- `idx_interview_person_id`: Since we have to sequence scan the transcript string anyway resulting in slow text matching, this does nothing useful for our workload. To actually fix Q7, we would need to implement Full-Text Search (FTS) or a `pg_trgm` index instead of a standard B-tree index.
