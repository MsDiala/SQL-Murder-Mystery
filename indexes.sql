
-- ✅ Starter indexes — uncomment what you think will help, add your own

-- Q1 — All murders in SQL City

SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND type = 'murder'
ORDER BY date DESC;

-- Q2 — People with their driver's license details

SELECT p.name, p.address_number, p.address_street_name,
       dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;

-- Q3 — Gym members who checked in on January 9, 2018

SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;

-- Q4 — Gold gym members and their income

SELECT m.name, m.membership_status, i.annual_income
FROM get_fit_now_member m
JOIN person p ON m.person_id = p.id
JOIN income i ON p.ssn = i.ssn
WHERE m.membership_status = 'gold'
ORDER BY i.annual_income DESC;

-- Q5 — People who attended Facebook events in 2018


SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;

-- Q6 — Red-haired Tesla drivers

SELECT p.name, dl.hair_color, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.hair_color = 'red'
  AND dl.car_make = 'Tesla'
ORDER BY p.name;

-- Q7 — Interview transcripts mentioning the gym or murder

SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript LIKE '%gym%'
   OR i.transcript LIKE '%murder%';

-- Q8 — Average income by car make

SELECT dl.car_make,
       COUNT(*) AS drivers,
       ROUND(AVG(i.annual_income), 0) AS avg_income,
       MIN(i.annual_income) AS min_income,
       MAX(i.annual_income) AS max_income
FROM drivers_license dl
JOIN person p ON dl.id = p.license_id
JOIN income i ON p.ssn = i.ssn
GROUP BY dl.car_make
ORDER BY avg_income DESC;

-- ➕ Add your own indexes below based on your EXPLAIN QUERY PLAN analysis:
-- Q1: 
CREATE INDEX idx_crime_date_desc 
ON crime_scene_report(date DESC);

-- Q2: 
CREATE INDEX idx_person_name 
ON person(name);

-- Q3:
CREATE INDEX idx_checkin_membership_id 
ON get_fit_now_check_in(membership_id);

-- Q4: 
CREATE INDEX idx_income_ssn 
ON income(ssn);

-- Q5: 
CREATE INDEX idx_facebook_date_desc 
ON facebook_event_checkin(date DESC);

-- Q6:
CREATE INDEX idx_license_car_hair 
ON drivers_license(car_make, hair_color);

-- Q8:
CREATE INDEX idx_license_car_make 
ON drivers_license(car_make);

