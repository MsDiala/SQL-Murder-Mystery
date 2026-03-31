--Q1
SELECT date, description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND type = 'murder'
ORDER BY date DESC;

--Q2
SELECT p.name, p.address_number, p.address_street_name,
       dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
ORDER BY p.name;

--Q3
SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
FROM get_fit_now_member m
JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
WHERE ci.check_in_date = 20180109
ORDER BY ci.check_in_time;

--Q4
SELECT m.name, m.membership_status, i.annual_income
FROM get_fit_now_member m
JOIN person p ON m.person_id = p.id
JOIN income i ON p.ssn = i.ssn
WHERE m.membership_status = 'gold'
ORDER BY i.annual_income DESC;

--Q5

SELECT p.name, fe.event_name, fe.date
FROM person p
JOIN facebook_event_checkin fe ON p.id = fe.person_id
WHERE fe.date BETWEEN 20180101 AND 20181231
ORDER BY fe.date DESC;

--Q6


SELECT p.name, dl.hair_color, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl ON p.license_id = dl.id
WHERE dl.hair_color = 'red'
  AND dl.car_make = 'Tesla'
ORDER BY p.name;

--Q7

SELECT p.name, i.transcript
FROM interview i
JOIN person p ON i.person_id = p.id
WHERE i.transcript LIKE '%gym%'
   OR i.transcript LIKE '%murder%';

   --Q8
  
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
