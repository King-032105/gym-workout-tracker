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
    print("\n=== Alla träningspass ===")
    query = """
        SELECT w.workout_id, w.workout_date, w.notes, COUNT(we.id) AS antal_ovningar
        FROM workouts w
        JOIN workout_exercises we ON w.workout_id = we.workout_id
        GROUP BY w.workout_id, w.workout_date, w.notes
        ORDER BY w.workout_date DESC
    """
    cursor.execute(query)
    results = cursor.fetchall()
    if not results:
        print("  Inga träningspass hittades.")
        return
    for row in results:
        print(f"  Pass #{row[0]} | Datum: {row[1]} | Övningar: {row[3]} | {row[2]}")


def show_personal_records():
    print("\n=== Personliga rekord ===")
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
        print("  Inga rekord hittades.")
        return
    for row in results:
        print(f"  {row[0]} ({row[1]}): {row[2]} kg")


def show_workouts_per_week():
    print("\n=== Pass per vecka ===")
    query = """
        SELECT YEAR(workout_date), WEEK(workout_date, 1), COUNT(*) AS antal
        FROM workouts
        GROUP BY YEAR(workout_date), WEEK(workout_date, 1)
        ORDER BY YEAR(workout_date), WEEK(workout_date, 1)
    """
    cursor.execute(query)
    results = cursor.fetchall()
    if not results:
        print("  Ingen data hittades.")
        return
    for row in results:
        print(f"  År {row[0]}, Vecka {row[1]}: {row[2]} pass")


def show_workout_details():
    print("\n=== Visa detaljer för ett pass ===")
    # Visa alla pass så användaren vet vilket ID de ska välja
    show_all_workouts()
    workout_id = input("\n  Ange pass-ID: ")

    # Kontrollera att det är ett nummer
    if not workout_id.isdigit():
        print("  Fel: Ange ett giltigt nummer.")
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
        print("  Inget pass hittades med det ID:t.")
        return
    print(f"\n=== Detaljer för pass #{workout_id} ===")
    print(f"  Datum: {results[0][0]}")
    for row in results:
        print(f"  {row[1]}: {row[2]} sets x {row[3]} reps @ {row[4]} kg")


def show_exercises():
    print("\n=== Tillgängliga övningar ===")
    cursor.execute("SELECT exercise_id, name, category FROM exercises ORDER BY category, name")
    for row in cursor.fetchall():
        print(f"  [{row[0]}] {row[1]} ({row[2]})")


def add_workout():
    print("\n=== Lägg till nytt träningspass ===")

    # Datum med validering
    while True:
        date = input("  Datum (YYYY-MM-DD), t.ex. 2025-03-08: ")
        try:
            datetime.strptime(date, "%Y-%m-%d")
            break
        except ValueError:
            print("  Fel: Skriv datumet i formatet YYYY-MM-DD, t.ex. 2025-03-08")

    notes = input("  Anteckningar (valfritt, tryck Enter för att hoppa över): ")

    cursor.execute(
        "INSERT INTO workouts (workout_date, notes) VALUES (%s, %s)",
        (date, notes)
    )
    conn.commit()
    workout_id = cursor.lastrowid
    print(f"  Träningspass sparat! (ID: {workout_id})")

    # Lägg till övningar
    show_exercises()
    ovningar_tillagda = 0

    while True:
        print("\n  Lägg till övning (tryck bara Enter på ID för att avsluta)")
        exercise_id = input("  Övnings-ID: ")
        if exercise_id == "":
            break

        # Kontrollera att ID är ett nummer
        if not exercise_id.isdigit():
            print("  Fel: Ange ett giltigt nummer.")
            continue

        # Kontrollera sets
        sets = input("  Antal sets: ")
        if not sets.isdigit():
            print("  Fel: Ange ett giltigt nummer.")
            continue

        # Kontrollera reps
        reps = input("  Antal reps: ")
        if not reps.isdigit():
            print("  Fel: Ange ett giltigt nummer.")
            continue

        # Kontrollera vikt
        weight = input("  Vikt (kg), t.ex. 80 eller 82.5: ")
        try:
            float(weight)
        except ValueError:
            print("  Fel: Ange en giltig vikt, t.ex. 80 eller 82.5")
            continue

        cursor.execute(
            "INSERT INTO workout_exercises (workout_id, exercise_id, sets, reps, weight_kg) VALUES (%s, %s, %s, %s, %s)",
            (workout_id, exercise_id, sets, reps, weight)
        )
        conn.commit()
        ovningar_tillagda += 1
        print(f"  Övning tillagd! ({ovningar_tillagda} st totalt)")

    if ovningar_tillagda == 0:
        print("  Inga övningar lades till.")
    else:
        print(f"\n  Pass #{workout_id} sparat med {ovningar_tillagda} övning(ar)!")


def main():
    print("\nVälkommen till Gym Workout Tracker!")
    while True:
        print("\n=== Meny ===")
        print("  1. Visa alla träningspass")
        print("  2. Visa personliga rekord")
        print("  3. Visa pass per vecka")
        print("  4. Visa detaljer för ett pass")
        print("  5. Lägg till nytt träningspass")
        print("  6. Avsluta")

        val = input("\nVälj (1-6): ")

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
            print("\nHejdå!")
            break
        else:
            print("  Ogiltigt val, välj ett nummer mellan 1 och 6.")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
