import sqlite3
import time

def run_baseline_analysis():
    try:
        conn = sqlite3.connect('sql-murder-mystery.db')
        cursor = conn.cursor()
        
        # Read your SQL file
        with open('explainquery.sql', 'r') as f:
            # Splitting by semicolon and removing empty lines
            queries = [q.strip() for q in f.read().split(';') if q.strip()]
        
        print("🚀 Starting Full Baseline Analysis...\n")
        
        for i, q in enumerate(queries, 1):
            print(f"--- ANALYZING QUERY {i} ---")
            
            # A. Get Execution Time & Data Sample
            start_time = time.perf_counter()
            cursor.execute(q)
            results = cursor.fetchall()
            end_time = time.perf_counter()
            
            exec_time_ms = (end_time - start_time) * 1000
            
            # B. Get Query Plan (Explain)
            # Remove any existing 'EXPLAIN' from the string if present
            clean_q = q.replace("EXPLAIN QUERY PLAN", "").strip()
            cursor.execute(f"EXPLAIN QUERY PLAN {clean_q}")
            plan = cursor.fetchall()
            
            # C. Print Everything clearly
            print(f"⏱️  Time: {exec_time_ms:.3f} ms")
            print(f"📋 Plan:")
            for row in plan:
                print(f"   -> {row[3]}")
            
            print(f"📊 Sample Data (First 2 rows):")
            for row in results[:2]:
                print(f"   {row}")
            
            print("-" * 40 + "\n")
            
        conn.close()
        print("✅ Baseline Analysis Complete.")
        
    except Exception as e:
        print(f"❌ Error occurred: {e}")

if __name__ == "__main__":
    run_baseline_analysis()