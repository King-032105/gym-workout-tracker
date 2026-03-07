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
# generate test data
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
# log a new workout
# -------------------------------------------------------
def log_workout():
    conn = get_connection()
    cursor = conn.cursor()

    workout_date = input("Date (YYYY-MM-DD): ")
    notes = input("Notes (e.g. Push day, Leg day): ")

    cursor.callproc("addWorkout", [1, workout_date, notes, 0])
    conn.commit()
    cursor.execute("SELECT LAST_INSERT_ID()")
    workout_id = cursor.fetchone()[0]
    print(f"Workout created! ID: {workout_id}")

    while True:
        cursor.execute("SELECT ExerciseID, Name, MuscleGroup FROM Exercise ORDER BY ExerciseID")
        exercises = cursor.fetchall()
        print("\n--- Available Exercises ---")
        for ex in exercises:
            print(f"  {ex[0]}. {ex[1]} ({ex[2]})")

        ex_input = input("\nEnter exercise number (0 = done with workout): ").strip()
        if ex_input == "0":
            break

        try:
            exercise_id = int(ex_input)
        except ValueError:
            print("Please enter a number!")
            continue

        cursor.execute(
            "INSERT INTO WorkoutExercise (WorkoutID, ExerciseID) VALUES (%s, %s)",
            (workout_id, exercise_id)
        )
        we_id = cursor.lastrowid
        conn.commit()

        set_num = 1
        while True:
            print(f"  Set {set_num} - enter weight and reps separated by space (e.g. 80 10)")
            set_input = input(f"  Set {set_num} (0 = done with this exercise): ").strip()
            if set_input == "0":
                break
            try:
                parts = set_input.split()
                weight = float(parts[0])
                reps = int(parts[1])
                cursor.execute(
                    "INSERT INTO WorkoutSet (WorkoutExerciseID, SetNumber, Weight, Reps) VALUES (%s, %s, %s, %s)",
                    (we_id, set_num, weight, reps)
                )
                conn.commit()
                print(f"  Saved: {weight} kg x {reps} reps")
                set_num += 1
            except:
                print("  Wrong format! Example: 80 10  (weight space reps)")

    print("\nWorkout saved!")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# show all workouts
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
        print(f"  ID: {row[0]} | {row[2]} | {row[3]}")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# show details of one workout
# -------------------------------------------------------
def show_workout_details():
    show_all_workouts()
    workout_id = input("\nEnter workout ID to see details: ").strip()
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT e.Name, ws.SetNumber, ws.Weight, ws.Reps
        FROM WorkoutSet ws
        JOIN WorkoutExercise we ON ws.WorkoutExerciseID = we.WorkoutExerciseID
        JOIN Exercise e ON we.ExerciseID = e.ExerciseID
        WHERE we.WorkoutID = %s
        ORDER BY e.Name, ws.SetNumber
    """, (workout_id,))
    rows = cursor.fetchall()
    print(f"\n--- Workout {workout_id} Details ---")
    if not rows:
        print("No exercises found for this workout.")
    current_exercise = ""
    for row in rows:
        if row[0] != current_exercise:
            current_exercise = row[0]
            print(f"\n  {current_exercise}:")
        print(f"    Set {row[1]}: {row[2]} kg x {row[3]} reps")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# show personal records
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
        print(f"  {row[0]}: {row[1]} kg")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# show workouts per week
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
        print(f"  Year: {row[0]} | Week: {row[1]} | Workouts: {row[2]}")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# show total weight lifted
# -------------------------------------------------------
def show_total_weight():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT getTotalWeight(1)")
    total = cursor.fetchone()[0]
    print(f"\n--- Total Weight Lifted ---")
    print(f"  {total} kg")
    cursor.close()
    conn.close()

# -------------------------------------------------------
# menu
# -------------------------------------------------------
def menu():
    print("\n=== Gym Workout Tracker ===")
    print("1. Show all workouts")
    print("2. Show workout details")
    print("3. Show personal records")
    print("4. Show workouts per week")
    print("5. Show total weight lifted")
    print("6. Log new workout")
    print("7. Generate test data")
    print("0. Exit")
    choice = input("Choose: ").strip()

    if choice == "1":
        show_all_workouts()
    elif choice == "2":
        show_workout_details()
    elif choice == "3":
        show_personal_records()
    elif choice == "4":
        show_workouts_per_week()
    elif choice == "5":
        show_total_weight()
    elif choice == "6":
        log_workout()
    elif choice == "7":
        generate_test_data()
    elif choice == "0":
        return False
    return True

if __name__ == "__main__":
    running = True
    while running:
        running = menu()
