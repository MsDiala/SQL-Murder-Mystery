import sqlite3
import time

conn = sqlite3.connect("sql-murder-mystery.db")
cur = conn.cursor()

# List of queries + index info
queries = [
    {
        "name": "Q1 — Murders in SQL City",
        "sql": """
        SELECT date, description
        FROM crime_scene_report
        WHERE city = 'SQL City' AND type = 'murder'
        ORDER BY date DESC;
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_crime_city_type_date ON crime_scene_report(city, type, date DESC)"
        ]
    },
    {
        "name": "Q2 — People + license details",
        "sql": """
        SELECT p.name, p.address_number, p.address_street_name,
               dl.age, dl.eye_color, dl.hair_color, dl.car_make, dl.car_model
        FROM person p
        JOIN drivers_license dl ON p.license_id = dl.id
        ORDER BY p.name;
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_person_license ON person(license_id)",
            "CREATE INDEX IF NOT EXISTS idx_person_name ON person(name)"
        ]
    },
    {
        "name": "Q3 — Gym members checked in Jan 9",
        "sql": """
        SELECT m.name, m.membership_status, ci.check_in_time, ci.check_out_time
        FROM get_fit_now_member m
        JOIN get_fit_now_check_in ci ON m.id = ci.membership_id
        WHERE ci.check_in_date = 20180109
        ORDER BY ci.check_in_time;
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_checkin_membership ON get_fit_now_check_in(membership_id, check_in_date, check_in_time)"
        ]
    },
    {
        "name": "Q4 — Gold members and income",
        "sql": """
        SELECT m.name, m.membership_status, i.annual_income
        FROM get_fit_now_member m
        JOIN person p ON m.person_id = p.id
        JOIN income i ON p.ssn = i.ssn
        WHERE m.membership_status = 'gold'
        ORDER BY i.annual_income DESC;
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_gold_member ON get_fit_now_member(membership_status)",
            "CREATE INDEX IF NOT EXISTS idx_income_ssn ON income(ssn)"
        ]
    },
    {
        "name": "Q5 — Facebook events 2018",
        "sql": """
        SELECT p.name, fe.event_name, fe.date
        FROM person p
        JOIN facebook_event_checkin fe ON p.id = fe.person_id
        WHERE fe.date BETWEEN 20180101 AND 20181231
        ORDER BY fe.date DESC;
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_fb_checkin_date ON facebook_event_checkin(date)",
            "CREATE INDEX IF NOT EXISTS idx_fb_person_id ON facebook_event_checkin(person_id)"
        ]
    },
    {
        "name": "Q6 — Red-haired Tesla drivers",
        "sql": """
        SELECT p.name, dl.hair_color, dl.car_make, dl.car_model, dl.plate_number
        FROM person p
        JOIN drivers_license dl ON p.license_id = dl.id
        WHERE dl.hair_color = 'red' AND dl.car_make = 'Tesla'
        ORDER BY p.name;
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_dl_hair_car ON drivers_license(hair_color, car_make)",
            "CREATE INDEX IF NOT EXISTS idx_person_name ON person(name)"
        ]
    },
    {
        "name": "Q7 — Interview keyword search",
        "sql": """
        SELECT p.name, i.transcript
        FROM interview i
        JOIN person p ON i.person_id = p.id
        WHERE i.transcript LIKE '%gym%' OR i.transcript LIKE '%murder%';
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_interview_person ON interview(person_id)"
        ]
    },
    {
        "name": "Q8 — Average income by car make",
        "sql": """
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
        """,
        "indexes": [
            "CREATE INDEX IF NOT EXISTS idx_dl_id ON drivers_license(id)",
            "CREATE INDEX IF NOT EXISTS idx_person_ssn ON person(ssn)",
            "CREATE INDEX IF NOT EXISTS idx_income_ssn ON income(ssn)"
        ]
    }
]

# Helper function to measure query time
def measure_time(sql):
    start = time.time()
    cur.execute(sql)
    rows = cur.fetchall()
    end = time.time()
    return (end - start) * 1000, len(rows)  # ms, row count

# Run each query
summary = []

for q in queries:
    print(f"\n=== {q['name']} ===")
    
    # Drop indexes for baseline
    for idx_sql in q["indexes"]:
        # Extract index name from SQL (simple split)
        idx_name = idx_sql.split("INDEX IF NOT EXISTS")[1].split("ON")[0].strip()
        cur.execute(f"DROP INDEX IF EXISTS {idx_name}")
    conn.commit()
    
    baseline_ms, rows_count = measure_time(q["sql"])
    print(f"Baseline: {baseline_ms:.3f} ms, Rows: {rows_count}")
    
    # Create indexes
    #q["indexes"]:""""خد القيمة المرتبطة بالمفتاح indexes من المتغير q""""
    for idx_sql in q["indexes"]:
        cur.execute(idx_sql)
    conn.commit()
    
    indexed_ms, rows_count2 = measure_time(q["sql"])
    print(f"Indexed: {indexed_ms:.3f} ms, Rows: {rows_count2}")
    
    # Improvement %
    improvement = ((baseline_ms - indexed_ms) / baseline_ms) * 100 if baseline_ms != 0 else 0
    
    # Check if index used
    cur.execute(f"EXPLAIN QUERY PLAN {q['sql']}")# ال اكسبيلن هاي متل مبدأ ال AI tools chatgpt  بدخل وبحكيلي شو الي استخدمهع لحله وبرجع نتيجه
    plan = cur.fetchall()
    print(f"Query Plan: {plan}")
    index_used = any("USING INDEX" in row[3] for row in plan)
    
    summary.append({
        "Query": q["name"],
        "Baseline (ms)": round(baseline_ms, 3),
        "Indexed (ms)": round(indexed_ms, 3),
        "Improvement (%)": round(improvement, 2),
        "Index Used?": "YES" if index_used else "NO"
    })

# Print summary table
print("\n=== Summary Table ===")
print("| Query | Baseline (ms) | Indexed (ms) | Improvement (%) | Index Used? |")
print("|-------|---------------|-------------|----------------|-------------|")
for s in summary:
    print(f"| {s['Query']} | {s['Baseline (ms)']} | {s['Indexed (ms)']} | {s['Improvement (%)']} | {s['Index Used?']} |")

conn.close()