-- =============================================================
--  indexes.sql — SQL Murder Mystery Performance Investigation
--  Add your CREATE INDEX statements here (Task 2)
--
--  SQLite:  sqlite3 sql-murder-mystery.db < indexes.sql
--  Postgres: docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
-- =============================================================

--- Q1 — Murders in SQL City
CREATE INDEX IF NOT EXISTS idx_crime_city_type_date 
ON crime_scene_report(city, type, date DESC);

-- Q2 — People + license details
CREATE INDEX IF NOT EXISTS idx_person_license 
ON person(license_id);
CREATE INDEX IF NOT EXISTS idx_person_name 
ON person(name);

-- Q3 — Gym members checked in Jan 9
CREATE INDEX IF NOT EXISTS idx_checkin_membership 
ON get_fit_now_check_in(membership_id, check_in_date, check_in_time);

-- Q4 — Gold members + income
CREATE INDEX IF NOT EXISTS idx_gold_member 
ON get_fit_now_member(membership_status);
CREATE INDEX IF NOT EXISTS idx_income_ssn 
ON income(ssn);

-- Q5 — Facebook events 2018
CREATE INDEX IF NOT EXISTS idx_fb_checkin_date 
ON facebook_event_checkin(date);
CREATE INDEX IF NOT EXISTS idx_fb_person_id 
ON facebook_event_checkin(person_id);

-- Q6 — Red-haired Tesla drivers
CREATE INDEX IF NOT EXISTS idx_dl_hair_car 
ON drivers_license(hair_color, car_make);

-- Q7 — Interview keyword search
CREATE INDEX IF NOT EXISTS idx_interview_person 
ON interview(person_id);

-- Q8 — Average income by car make
CREATE INDEX IF NOT EXISTS idx_dl_id 
ON drivers_license(id);
CREATE INDEX IF NOT EXISTS idx_person_ssn 
ON person(ssn);
CREATE INDEX IF NOT EXISTS idx_income_ssn 
ON income(ssn);