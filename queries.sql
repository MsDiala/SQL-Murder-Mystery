-- Q1
-- Business question: Who are the highest earning individuals?
-- Reason: income table suggests financial analysis

SELECT p.name, i.annual_income
FROM person p
JOIN income i ON p.ssn = i.ssn
ORDER BY i.annual_income DESC
LIMIT 10;


-- Q2
-- Business question: Who owns a Tesla?
-- Reason: car_make suggests vehicle analysis

SELECT p.name, d.car_make, d.car_model
FROM person p
JOIN drivers_license d ON p.license_id = d.id
WHERE d.car_make = 'Tesla';


-- Q3
-- Business question: Who visited the gym on a specific day?
-- Reason: check-in system suggests activity tracking

SELECT p.name, g.check_in_date
FROM person p
JOIN get_fit_now_member m ON p.id = m.person_id
JOIN get_fit_now_check_in g ON m.id = g.membership_id
WHERE g.check_in_date = 20180109;


-- Q4
-- Business question: Who attended events in 2018?
-- Reason: event tracking data exists

SELECT p.name, f.event_name
FROM person p
JOIN facebook_event_checkin f ON p.id = f.person_id
WHERE f.date LIKE '2018%';


-- Q5
-- Business question: Which people mentioned "murder" in interviews?
-- Reason: transcript field suggests keyword analysis

SELECT p.name, i.transcript
FROM person p
JOIN interview i ON p.id = i.person_id
WHERE i.transcript LIKE '%murder%';