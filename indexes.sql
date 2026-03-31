-- indexes.sql — Performance Optimization Indexes
-- Module 3 Stretch: SQL Performance Investigation

-- Q1: Filter on city and type in crime_scene_report
CREATE INDEX IF NOT EXISTS idx_crime_city_type ON crime_scene_report(city, type);

-- Q2, Q6, Q8: person.license_id used in JOIN to drivers_license
CREATE INDEX IF NOT EXISTS idx_person_license ON person(license_id);

-- Q3: Filter on check_in_date in get_fit_now_check_in
CREATE INDEX IF NOT EXISTS idx_checkin_date ON get_fit_now_check_in(check_in_date);

-- Q4: Filter on membership_status in get_fit_now_member
CREATE INDEX IF NOT EXISTS idx_member_status ON get_fit_now_member(membership_status);

-- Q5: Filter and sort on date in facebook_event_checkin
CREATE INDEX IF NOT EXISTS idx_facebook_date ON facebook_event_checkin(date);

-- Q5: JOIN on person_id in facebook_event_checkin
CREATE INDEX IF NOT EXISTS idx_facebook_person ON facebook_event_checkin(person_id);

-- Q6: Filter on hair_color and car_make in drivers_license
CREATE INDEX IF NOT EXISTS idx_license_hair_car ON drivers_license(hair_color, car_make);
