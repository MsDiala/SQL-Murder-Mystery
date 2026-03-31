-- Q1: All murders in SQL City
EXPLAIN QUERY PLAN
SELECT date, description FROM crime_scene_report WHERE city = 'SQL City' AND type = 'murder' ORDER BY date DESC;

-- Q2: People with their driver's license details
EXPLAIN QUERY PLAN
SELECT p.name, dl.car_make, dl.car_model FROM person p JOIN drivers_license dl ON p.license_id = dl.id ORDER BY p.name;

-- Q3: Gym members on January 9, 2018
EXPLAIN QUERY PLAN
SELECT m.name, ci.check_in_time FROM get_fit_now_member m JOIN get_fit_now_check_in ci ON m.id = ci.membership_id WHERE ci.check_in_date = 20180109 ORDER BY ci.check_in_time;

-- Q4: Gold gym members and their income
EXPLAIN QUERY PLAN
SELECT m.name, i.annual_income FROM get_fit_now_member m JOIN person p ON m.person_id = p.id JOIN income i ON p.ssn = i.ssn WHERE m.membership_status = 'gold' ORDER BY i.annual_income DESC;

-- Q5: Facebook events in 2018
EXPLAIN QUERY PLAN
SELECT p.name, fe.event_name FROM person p JOIN facebook_event_checkin fe ON p.id = fe.person_id WHERE fe.date BETWEEN 20180101 AND 20181231 ORDER BY fe.date DESC;

-- Q6: Red-haired Tesla drivers
EXPLAIN QUERY PLAN
SELECT p.name, dl.car_make, dl.plate_number FROM person p JOIN drivers_license dl ON p.license_id = dl.id WHERE dl.hair_color = 'red' AND dl.car_make = 'Tesla';

-- Q7: Transcripts mentioning gym or murder
EXPLAIN QUERY PLAN
SELECT p.name, i.transcript FROM interview i JOIN person p ON i.person_id = p.id WHERE i.transcript LIKE '%gym%' OR i.transcript LIKE '%murder%';

-- Q8: Average income by car make
EXPLAIN QUERY PLAN
SELECT dl.car_make, ROUND(AVG(i.annual_income), 0) AS avg_income FROM drivers_license dl JOIN person p ON dl.id = p.license_id JOIN income i ON p.ssn = i.ssn GROUP BY dl.car_make ORDER BY avg_income DESC;