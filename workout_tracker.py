import mysql.connector
from datetime import datetime

# Anslutning till databasen
conn = mysql.connector.connect(
    host="127.0.0.1",
    port=3306,
    user="root",
    password="Deliar0501052005",
    database="gym_tracker",
    unix_socket="/var/run/mysqld/mysqld.sock"
)
cursor = conn.cursor()


def show_all_workouts():
    # Visar alla träningspass med antal övningar
    print("\n=== All Workouts ===")
    query = """
        SELECT w.workout_id, w.workout_date, w.notes, COUNT(we.id) AS num_exercises
        FROM workouts w
        JOIN workout_exercises we ON w.workout_id = we.workout_id
        GROUP BY w.workout_id, w.workout_date, w.notes
        ORDER BY w.workout_date DESC
    """
    cursor.execute(query)
    results = cursor.fetchall()
    if not results:
        print("  No workouts found.")
        return
    for row in results:
        print(f"  Workout #{row[0]} | Date: {row[1]} | Exercises: {row[3]} | {row[2]}")


def show_personal_records():
    # Visar personliga rekord - högsta vikt per övning
    print("\n=== Personal Records ===")
    query = """
        SELECT e.name, e.category, MAX(we.weight_kg) AS pr
        FROM exercises e
        JOIN workout_exercises we ON e.exercise_id = we.exercise_id
        GROUP BY e.exercise_id, e.name, e.category
        ORDER BY pr DESC
    """
    cursor.execute(query)
    results = cursor.fetchall()
    if not results:
        print("  No records found.")
        return
    for row in results:
        print(f"  {row[0]} ({row[1]}): {row[2]} kg")


def show_workouts_per_week():
    # Visar antal träningspass per vecka
    print("\n=== Workouts Per Week ===")
    query = """
        SELECT YEAR(workout_date), WEEK(workout_date, 1), COUNT(*) AS total
        FROM workouts
        GROUP BY YEAR(workout_date), WEEK(workout_date, 1)
        ORDER BY YEAR(workout_date), WEEK(workout_date, 1)
    """
    cursor.execute(query)
    results = cursor.fetchall()
    if not results:
        print("  No data found.")
        return
    for row in results:
        print(f"  Year {row[0]}, Week {row[1]}: {row[2]} session(s)")


def show_workout_details():
    # Visar detaljer för ett specifikt träningspass
    print("\n=== Workout Details ===")
    show_all_workouts()
    workout_id = input("\n  Enter workout ID: ")

    # Kontrollera att det är ett nummer
    if not workout_id.isdigit():
        print("  Error: Please enter a valid number.")
        return

    query = """
        SELECT w.workout_date, e.name, we.sets, we.reps, we.weight_kg
        FROM workouts w
        JOIN workout_exercises we ON w.workout_id = we.workout_id
        JOIN exercises e ON we.exercise_id = e.exercise_id
        WHERE w.workout_id = %s
    """
    cursor.execute(query, (workout_id,))
    results = cursor.fetchall()
    if not results:
        print("  No workout found with that ID.")
        return
    print(f"\n  Date: {results[0][0]}")
    for row in results:
        print(f"  {row[1]}: {row[2]} sets x {row[3]} reps @ {row[4]} kg")


def show_exercises():
    # Visar alla tillgängliga övningar
    print("\n=== Available Exercises ===")
    cursor.execute("SELECT exercise_id, name, category FROM exercises ORDER BY category, name")
    for row in cursor.fetchall():
        print(f"  [{row[0]}] {row[1]} ({row[2]})")


def add_workout():
    # Lägger till ett nytt träningspass med övningar
    print("\n=== Add New Workout ===")

    # Datum med validering
    while True:
        date = input("  Date (YYYY-MM-DD), e.g. 2025-03-08: ")
        try:
            datetime.strptime(date, "%Y-%m-%d")
            break
        except ValueError:
            print("  Error: Use the format YYYY-MM-DD, e.g. 2025-03-08")

    notes = input("  Notes (optional, press Enter to skip): ")

    cursor.execute(
        "INSERT INTO workouts (workout_date, notes) VALUES (%s, %s)",
        (date, notes)
    )
    conn.commit()
    workout_id = cursor.lastrowid
    print(f"  Workout saved! (ID: {workout_id})")

    # Lägg till övningar i passet
    show_exercises()
    exercises_added = 0

    while True:
        print("\n  Add exercise (press Enter on ID to finish)")
        exercise_id = input("  Exercise ID: ")
        if exercise_id == "":
            break

        # Kontrollera att ID är ett nummer
        if not exercise_id.isdigit():
            print("  Error: Please enter a valid number.")
            continue

        # Kontrollera sets
        sets = input("  Sets: ")
        if not sets.isdigit():
            print("  Error: Please enter a valid number.")
            continue

        # Kontrollera reps
        reps = input("  Reps: ")
        if not reps.isdigit():
            print("  Error: Please enter a valid number.")
            continue

        # Kontrollera vikt
        weight = input("  Weight (kg), e.g. 80 or 82.5: ")
        try:
            float(weight)
        except ValueError:
            print("  Error: Please enter a valid weight, e.g. 80 or 82.5")
            continue

        cursor.execute(
            "INSERT INTO workout_exercises (workout_id, exercise_id, sets, reps, weight_kg) VALUES (%s, %s, %s, %s, %s)",
            (workout_id, exercise_id, sets, reps, weight)
        )
        conn.commit()
        exercises_added += 1
        print(f"  Exercise added! ({exercises_added} total)")

    if exercises_added == 0:
        print("  No exercises were added.")
    else:
        print(f"\n  Workout #{workout_id} saved with {exercises_added} exercise(s)!")


def main():
    # Huvudmeny
    print("\nWelcome to Gym Workout Tracker!")
    while True:
        print("\n=== Menu ===")
        print("  1. View all workouts")
        print("  2. View personal records")
        print("  3. View workouts per week")
        print("  4. View workout details")
        print("  5. Add new workout")
        print("  6. Exit")

        val = input("\nChoose (1-6): ")

        if val == "1":
            show_all_workouts()
        elif val == "2":
            show_personal_records()
        elif val == "3":
            show_workouts_per_week()
        elif val == "4":
            show_workout_details()
        elif val == "5":
            add_workout()
        elif val == "6":
            print("\nGoodbye!")
            break
        else:
            print("  Invalid choice, please choose a number between 1 and 6.")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
