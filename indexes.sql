-- =============================================================
--  indexes.sql — SQL Murder Mystery Performance Investigation
--  Add your CREATE INDEX statements here (Task 2)
--
--  SQLite:  sqlite3 sql-murder-mystery.db < indexes.sql
--  Postgres: docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
-- =============================================================
CREATE INDEX IF NOT EXISTS idx_crime_city_type
ON crime_scene_report(city, type);

CREATE INDEX IF NOT EXISTS idx_person_license
ON person(license_id);

CREATE INDEX IF NOT EXISTS idx_checkin_date
ON get_fit_now_check_in(check_in_date);

CREATE INDEX IF NOT EXISTS idx_facebook_date
ON facebook_event_checkin(date);

CREATE INDEX IF NOT EXISTS idx_facebook_person
ON facebook_event_checkin(person_id);

CREATE INDEX IF NOT EXISTS idx_member_status
ON get_fit_now_member(membership_status);

CREATE INDEX IF NOT EXISTS idx_person_ssn
ON person(ssn);

CREATE INDEX IF NOT EXISTS idx_income_ssn
ON income(ssn);

CREATE INDEX IF NOT EXISTS idx_dl_hair_make
ON drivers_license(hair_color, car_make);