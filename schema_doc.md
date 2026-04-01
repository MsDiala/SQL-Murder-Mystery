# Schema Documentation

## Overview
This database represents a fictional investigation scenario involving people, crimes, interviews, gym activities, and social media events.

---

## Table: person
Stores basic information about individuals.

Columns:
- id (Primary Key)
- name
- license_id (Foreign Key → drivers_license.id)
- address_number
- address_street_name
- ssn (Foreign Key → income.ssn)

---

## Table: drivers_license
Contains physical and vehicle information.

Columns:
- id (Primary Key)
- age
- height
- eye_color
- hair_color
- gender
- plate_number
- car_make
- car_model

---

## Table: income
Stores income information.

Columns:
- ssn (Primary Key)
- annual_income

---

## Table: interview
Stores interview transcripts.

Columns:
- person_id (Foreign Key → person.id)
- transcript

---

## Table: crime_scene_report
Stores crime details.

Columns:
- date
- type
- description
- city

---

## Table: facebook_event_checkin
Tracks event participation.

Columns:
- person_id (Foreign Key → person.id)
- event_id
- event_name
- date

---

## Table: get_fit_now_member
Stores gym membership data.

Columns:
- id (Primary Key)
- person_id (Foreign Key → person.id)
- name
- membership_start_date
- membership_status

---

## Table: get_fit_now_check_in
Stores gym check-in records.

Columns:
- membership_id (Foreign Key → get_fit_now_member.id)
- check_in_date
- check_in_time
- check_out_time

---

## Table: solution
Stores the final solution (not used in analysis).

---

## Relationships

- person → drivers_license (1:1)
- person → income (1:1)
- person → interview (1:many)
- person → facebook_event_checkin (1:many)
- person → get_fit_now_member (1:many)
- get_fit_now_member → get_fit_now_check_in (1:many)

---

## ERD (Text)

[person]
  |-- license_id → [drivers_license]
  |-- ssn → [income]
  |
  |-- id → [interview]
  |-- id → [facebook_event_checkin]
  |-- id → [get_fit_now_member]
                       |
                       → [get_fit_now_check_in]