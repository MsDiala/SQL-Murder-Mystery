-- =============================================================
--  indexes.sql — SQL Murder Mystery Performance Investigation
--  Add your CREATE INDEX statements here (Task 2)
--
--  SQLite:  sqlite3 sql-murder-mystery.db < indexes.sql
--  Postgres: docker exec -i murder_db psql -U postgres -d murder_mystery < indexes.sql
-- =============================================================

-- ✅ Starter indexes — uncomment what you think will help, add your own

CREATE INDEX idx_crime_city_type 
ON crime_scene_report(city, type);

CREATE INDEX idx_person_license_id 
ON person(license_id);

CREATE INDEX idx_checkin_date 
ON get_fit_now_check_in(check_in_date);

CREATE INDEX idx_checkin_membership 
ON get_fit_now_check_in(membership_id);

CREATE INDEX idx_member_status 
ON get_fit_now_member(membership_status);

CREATE INDEX idx_member_person_id 
ON get_fit_now_member(person_id);

CREATE INDEX idx_facebook_date 
ON facebook_event_checkin(date);

CREATE INDEX idx_facebook_person_id 
ON facebook_event_checkin(person_id);

CREATE INDEX idx_interview_person_id 
ON interview(person_id);

CREATE INDEX idx_person_ssn 
ON person(ssn);

CREATE INDEX idx_license_hair_car 
ON drivers_license(hair_color, car_make);