-- Gym Workout Tracker - SQL Queries
-- Kurs: Databaser, Slutprojekt

USE gym_tracker;

-- ============================================================
-- QUERY 1: Visa alla träningspass med antal övningar (JOIN + GROUP BY)
-- ============================================================
SELECT
    w.workout_id,
    w.workout_date,
    w.notes,
    COUNT(we.id) AS antal_ovningar
FROM workouts w
JOIN workout_exercises we ON w.workout_id = we.workout_id
GROUP BY w.workout_id, w.workout_date, w.notes
ORDER BY w.workout_date DESC;

-- ============================================================
-- QUERY 2: Personliga rekord – högsta vikt per övning (JOIN + MAX)
-- ============================================================
SELECT
    e.name AS ovning,
    e.category AS kategori,
    MAX(we.weight_kg) AS hogsta_vikt_kg
FROM exercises e
JOIN workout_exercises we ON e.exercise_id = we.exercise_id
GROUP BY e.exercise_id, e.name, e.category
ORDER BY hogsta_vikt_kg DESC;

-- ============================================================
-- QUERY 3: Antal träningspass per vecka
-- ============================================================
SELECT
    YEAR(workout_date) AS ar,
    WEEK(workout_date, 1) AS vecka,
    COUNT(*) AS antal_pass
FROM workouts
GROUP BY ar, vecka
ORDER BY ar, vecka;

-- ============================================================
-- QUERY 4: Detaljer för ett specifikt träningspass (JOIN)
-- Exempel: visa pass med workout_id = 1
-- ============================================================
SELECT
    w.workout_date,
    e.name AS ovning,
    we.sets,
    we.reps,
    we.weight_kg
FROM workouts w
JOIN workout_exercises we ON w.workout_id = we.workout_id
JOIN exercises e ON we.exercise_id = e.exercise_id
WHERE w.workout_id = 1;

-- ============================================================
-- QUERY 5: Totalt lyft volym per övning (sets * reps * vikt)
-- ============================================================
SELECT
    e.name AS ovning,
    SUM(we.sets * we.reps * we.weight_kg) AS total_volym_kg
FROM exercises e
JOIN workout_exercises we ON e.exercise_id = we.exercise_id
GROUP BY e.exercise_id, e.name
ORDER BY total_volym_kg DESC;

-- ============================================================
-- TRIGGER: Logga när ett personligt rekord sätts
-- Körs automatiskt varje gång en rad läggs till i workout_exercises
-- Sparar också sets, reps och kopplar till workout_exercises
-- ============================================================
DELIMITER //

CREATE TRIGGER check_pr
AFTER INSERT ON workout_exercises
FOR EACH ROW
BEGIN
    DECLARE current_pr DECIMAL(5,2);

    -- Hämta nuvarande rekord för övningen (exklusive den nya raden)
    SELECT MAX(weight_kg) INTO current_pr
    FROM workout_exercises
    WHERE exercise_id = NEW.exercise_id
      AND id != NEW.id;

    -- Om ny vikt är högre (eller det är första gången), logga det
    IF current_pr IS NULL OR NEW.weight_kg > current_pr THEN
        INSERT INTO pr_log (exercise_id, workout_exercise_id, old_weight, sets, reps, new_weight)
        VALUES (NEW.exercise_id, NEW.id, current_pr, NEW.sets, NEW.reps, NEW.weight_kg);
    END IF;
END//

DELIMITER ;

-- ============================================================
-- PROCEDURE: Visa sammanfattning av ett träningspass
-- Anrop: CALL workout_summary(1);
-- ============================================================
DELIMITER //

CREATE PROCEDURE workout_summary(IN p_workout_id INT)
BEGIN
    -- Visa datum och anteckningar
    SELECT workout_date, notes
    FROM workouts
    WHERE workout_id = p_workout_id;

    -- Visa övningar i passet
    SELECT
        e.name AS ovning,
        we.sets,
        we.reps,
        we.weight_kg
    FROM workout_exercises we
    JOIN exercises e ON we.exercise_id = e.exercise_id
    WHERE we.workout_id = p_workout_id;
END//

DELIMITER ;

-- Testa procedure:
-- CALL workout_summary(1);
