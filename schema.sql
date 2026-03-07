import mysql.connector
import random
from datetime import date, timedelta

def get_connection():
    return mysql.connector.connect(
        host="172.18.0.1",
        user="root",
        password="",
        database="gym_tracker"
    )

# -------------------------------------------------------
# generate test data - 6 weeks of workouts
# -------------------------------------------------------
def generate_test_data():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT ExerciseID FROM Exercise")
    exercise_ids = [row[0] for row in cursor.fetchall()]

    start_date = date.today() - timedelta(weeks=6)

    for week in range(6):
        for day in [0, 2, 4, 6]:
            workout_date = start_date + timedelta(weeks=week, days=day)

            cursor.execute(
                "INSERT INTO Workout (UserID, WorkoutDate, Notes) VALUES (%s, %s, %s)",
                (1, workout_date, "Training session")
            )
            workout_id = cursor.lastrowid

            chosen_exercises = random.sample(exercise_ids, 4)
            for ex_id in chosen_exercises:
                cursor.execute(
                    "INSERT INTO WorkoutExercise (WorkoutID, ExerciseID) VALUES (%s, %s)",
                    (workout_id, ex_id)
                )
                we_id = cursor.lastrowid

                for set_num in range(1, 4):
                    weight = round(random.uniform(20, 120), 2)
                    reps = random.randint(5, 12)
                    cursor.execute(
                        "INSERT INTO WorkoutSet (WorkoutExerciseID, SetNumber, Weight, Reps) VALUES (%s, %s, %s, %s)",
                        (we_id, set_num, weight, reps)
                    )

    conn.commit()
    cursor.close()
    conn.close()
    print("Test data generated!")

# -------------------------------------------------------
# 1. show all workouts
# -------------------------------------------------------
def show_all_workouts():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT w.WorkoutID, u.Name, w.WorkoutDate, w.Notes
        FROM Workout w
        JOIN User u ON w.UserID = u.UserID
        WHERE u.UserID = 1
        ORDER BY w.WorkoutDate DESC
    """)
    rows = cursor.fetchall()
    print("\n--- All Workouts ---")
    if not rows:
        print("No workouts found.")
    for row in rows:
        print(f"ID: {row[0]} | {row[1]} | {row[2]} | {row[3]}")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# 2. show personal records
# -------------------------------------------------------
def show_personal_records():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT e.Name, MAX(ws.Weight) AS PersonalRecord
        FROM WorkoutSet ws
        JOIN WorkoutExercise we ON ws.WorkoutExerciseID = we.WorkoutExerciseID
        JOIN Exercise e ON we.ExerciseID = e.ExerciseID
        JOIN Workout w ON we.WorkoutID = w.WorkoutID
        WHERE w.UserID = 1
        GROUP BY e.ExerciseID, e.Name
        ORDER BY e.Name
    """)
    rows = cursor.fetchall()
    print("\n--- Personal Records ---")
    if not rows:
        print("No records found.")
    for row in rows:
        print(f"{row[0]}: {row[1]} kg")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# 3. show workouts per week
# -------------------------------------------------------
def show_workouts_per_week():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT YEAR(WorkoutDate), WEEK(WorkoutDate), COUNT(*) AS Workouts
        FROM Workout
        WHERE UserID = 1
        GROUP BY YEAR(WorkoutDate), WEEK(WorkoutDate)
        ORDER BY YEAR(WorkoutDate), WEEK(WorkoutDate)
    """)
    rows = cursor.fetchall()
    print("\n--- Workouts Per Week ---")
    if not rows:
        print("No data found.")
    for row in rows:
        print(f"Year: {row[0]} | Week: {row[1]} | Workouts: {row[2]}")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# 4. show total weight lifted (uses function)
# -------------------------------------------------------
def show_total_weight():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT getTotalWeight(1)")
    total = cursor.fetchone()[0]
    print(f"\n--- Total Weight Lifted ---")
    print(f"{total} kg")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# 5. add new workout (uses procedure)
# -------------------------------------------------------
def add_workout():
    workout_date = input("Date (YYYY-MM-DD): ")
    notes = input("Notes: ")
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc("addWorkout", [1, workout_date, notes, 0])
    conn.commit()
    cursor.execute("SELECT LAST_INSERT_ID()")
    workout_id = cursor.fetchone()[0]
    print(f"Workout added! ID: {workout_id}")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# menu
# -------------------------------------------------------
def menu():
    print("\n=== Gym Workout Tracker ===")
    print("1. Show all workouts")
    print("2. Show personal records")
    print("3. Show workouts per week")
    print("4. Show total weight lifted")
    print("5. Add new workout")
    print("6. Generate test data")
    print("0. Exit")
    choice = input("Choose: ")

    if choice == "1":
        show_all_workouts()
    elif choice == "2":
        show_personal_records()
    elif choice == "3":
        show_workouts_per_week()
    elif choice == "4":
        show_total_weight()
    elif choice == "5":
        add_workout()
    elif choice == "6":
        generate_test_data()
    elif choice == "0":
        return False
    return True

if __name__ == "__main__":
    running = True
    while running:
        running = menu()
