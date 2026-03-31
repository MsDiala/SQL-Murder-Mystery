# Task 1 — Baseline Execution Plans

### Q1 — All murders in SQL City
**Execution Plan:**
1. `SCAN TABLE crime_scene_report`
2. `USE TEMP B-TREE FOR ORDER BY`

---

### Q2 — People with their driver's license details
**Execution Plan:**
1. `SCAN TABLE person AS p`
2. `SEARCH TABLE drivers_license AS dl USING INTEGER PRIMARY KEY (rowid=?)`
3. `USE TEMP B-TREE FOR ORDER BY`

---

### Q3 — Gym members on January 9, 2018
**Execution Plan:**
1. `SCAN TABLE get_fit_now_check_in AS ci`
2. `SEARCH TABLE get_fit_now_member AS m USING INDEX sqlite_autoindex_get_fit_now_member_1 (id=?)`
3. `USE TEMP B-TREE FOR ORDER BY`

---

### Q4 — Gold gym members and their income
**Execution Plan:**
1. `SCAN TABLE get_fit_now_member AS m`
2. `SEARCH TABLE person AS p USING INTEGER PRIMARY KEY (rowid=?)`
3. `SEARCH TABLE income AS i USING INDEX sqlite_autoindex_income_1 (ssn=?)`
4. `USE TEMP B-TREE FOR ORDER BY`

---

### Q5 — Facebook events in 2018
**Execution Plan:**
1. `SCAN TABLE facebook_event_checkin AS fe`
2. `SEARCH TABLE person AS p USING INTEGER PRIMARY KEY (rowid=?)`
3. `USE TEMP B-TREE FOR ORDER BY`

---

### Q6 — Red-haired Tesla drivers
**Execution Plan:**
1. `SCAN TABLE drivers_license AS dl`
2. `SEARCH TABLE person AS p USING INDEX sqlite_autoindex_person_1 (license_id=?)`

---

### Q7 — Transcripts mentioning gym or murder
**Execution Plan:**
1. `SCAN TABLE interview AS i`
2. `SEARCH TABLE person AS p USING INTEGER PRIMARY KEY (rowid=?)`

---

### Q8 — Average income by car make
**Execution Plan:**
1. `SCAN TABLE drivers_license AS dl`
2. `SEARCH TABLE person AS p USING INDEX sqlite_autoindex_person_1 (license_id=?)`
3. `SEARCH TABLE income AS i USING INDEX sqlite_autoindex_income_1 (ssn=?)`
4. `USE TEMP B-TREE FOR GROUP BY`