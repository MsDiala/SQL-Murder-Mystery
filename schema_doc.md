      table_name       
------------------------
 crime_scene_report
 drivers_license
 facebook_event_checkin
 get_fit_now_check_in
 get_fit_now_member
 income
 interview
 person
 solution

       table_name       |      column_name      | data_type | is_nullable | column_default 
------------------------+-----------------------+-----------+-------------+----------------
 crime_scene_report     | date                  | integer   | YES         |
 crime_scene_report     | type                  | text      | YES         |
 crime_scene_report     | description           | text      | YES         |
 crime_scene_report     | city                  | text      | YES         |
 drivers_license        | id                    | integer   | NO          |
 drivers_license        | age                   | integer   | YES         |
 drivers_license        | height                | integer   | YES         |
 drivers_license        | eye_color             | text      | YES         |
 drivers_license        | hair_color            | text      | YES         |
 drivers_license        | gender                | text      | YES         |
 drivers_license        | plate_number          | text      | YES         |
 drivers_license        | car_make              | text      | YES         |
 drivers_license        | car_model             | text      | YES         |
 facebook_event_checkin | person_id             | integer   | YES         |
 facebook_event_checkin | event_id              | integer   | YES         |
 facebook_event_checkin | event_name            | text      | YES         |
 facebook_event_checkin | date                  | integer   | YES         |
 get_fit_now_check_in   | membership_id         | text      | YES         |
 get_fit_now_check_in   | check_in_date         | integer   | YES         |
 get_fit_now_check_in   | check_in_time         | integer   | YES         |
 get_fit_now_check_in   | check_out_time        | integer   | YES         |
 get_fit_now_member     | id                    | text      | NO          |
 get_fit_now_member     | person_id             | integer   | YES         |
 get_fit_now_member     | name                  | text      | YES         |
 get_fit_now_member     | membership_start_date | integer   | YES         |
 get_fit_now_member     | membership_status     | text      | YES         |
 income                 | ssn                   | integer   | NO          |
 income                 | annual_income         | integer   | YES         |
 interview              | person_id             | integer   | YES         |
 interview              | transcript            | text      | YES         |
 person                 | id                    | integer   | NO          |
 person                 | name                  | text      | YES         |
 person                 | license_id            | integer   | YES         |
 person                 | address_number        | integer   | YES         |
 person                 | address_street_name   | text      | YES         |
 person                 | ssn                   | integer   | YES         |
 solution               | user                  | integer   | YES         |
 solution               | value                 | text      | YES         |

       table_name       |  column_name  | constraint_type | foreign_table_name | foreign_column_name
------------------------+---------------+-----------------+--------------------+---------------------
 drivers_license        | id            | PRIMARY KEY     | drivers_license    | id
 facebook_event_checkin | person_id     | FOREIGN KEY     | person             | id
 get_fit_now_check_in   | membership_id | FOREIGN KEY     | get_fit_now_member | id
 get_fit_now_member     | person_id     | FOREIGN KEY     | person             | id
 get_fit_now_member     | id            | PRIMARY KEY     | get_fit_now_member | id
 income                 | ssn           | PRIMARY KEY     | income             | ssn
 interview              | person_id     | FOREIGN KEY     | person             | id
 person                 | license_id    | FOREIGN KEY     | drivers_license    | id
 person                 | id            | PRIMARY KEY     | person             | id
