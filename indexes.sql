CREATE INDEX idx_crime_city_type
ON crime_scene_report(city, type);

CREATE INDEX idx_person_license
ON person(license_id);

CREATE INDEX idx_checkin_date
ON get_fit_now_check_in(check_in_date);

CREATE INDEX idx_facebook_date
ON facebook_event_checkin(date);

CREATE INDEX idx_facebook_person
ON facebook_event_checkin(person_id);

CREATE INDEX idx_license_hair_car
ON drivers_license(hair_color, car_make);
