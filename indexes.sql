-- =============================================================
--  indexes.sql — SQL Murder Mystery Performance Investigation
--  Add your CREATE INDEX statements here (Task 2)
--
--  SQLite:  sqlite3 sql-murder-mystery.db < indexes.sql
--  Postgres: docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
-- =============================================================

-- Indexes used for this module's performance investigation.
-- Run: sqlite3 sql-murder-mystery.db < indexes.sql

-- Q1: crimes filtered by (city, type) and ordered by date
CREATE INDEX IF NOT EXISTS idx_crime_city_type_date
  ON crime_scene_report(city, type, date DESC);

-- Q2 / Q6: ordering and joining person <-> drivers_license
CREATE INDEX IF NOT EXISTS idx_person_name
  ON person(name);

CREATE INDEX IF NOT EXISTS idx_person_license_id
  ON person(license_id);

-- Q3: filter by check_in_date and order by check_in_time
CREATE INDEX IF NOT EXISTS idx_checkin_date_time
  ON get_fit_now_check_in(check_in_date, check_in_time);

CREATE INDEX IF NOT EXISTS idx_checkin_membership_id
  ON get_fit_now_check_in(membership_id);

-- Q4: filter gym members by membership_status; join to person
CREATE INDEX IF NOT EXISTS idx_member_status_person_id
  ON get_fit_now_member(membership_status, person_id);

-- Q5: filter events by date range and join to person
CREATE INDEX IF NOT EXISTS idx_facebook_date_person_id
  ON facebook_event_checkin(date, person_id);

-- Q6: filter licenses by (hair_color, car_make)
CREATE INDEX IF NOT EXISTS idx_license_hair_color_car_make
  ON drivers_license(hair_color, car_make);

-- Q8: GROUP BY / aggregation on car_make
CREATE INDEX IF NOT EXISTS idx_license_car_make
  ON drivers_license(car_make);

-- Q4 / Q8: join person <-> income via SSN
CREATE INDEX IF NOT EXISTS idx_person_ssn
  ON person(ssn);

-- Q7: join interview -> person
CREATE INDEX IF NOT EXISTS idx_interview_person_id
  ON interview(person_id);

