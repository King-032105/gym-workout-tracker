-- Gym Workout Tracker - Databasschema
-- Kurs: Databaser, Slutprojekt

CREATE DATABASE IF NOT EXISTS gym_tracker;
USE gym_tracker;

-- Tabell: övningar
CREATE TABLE exercises (
    exercise_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50)
);

-- Tabell: träningspass
CREATE TABLE workouts (
    workout_id INT AUTO_INCREMENT PRIMARY KEY,
    workout_date DATE NOT NULL,
    notes VARCHAR(255)
);

-- Tabell: övningar per pass (sets, reps, vikt)
CREATE TABLE workout_exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    workout_id INT NOT NULL,
    exercise_id INT NOT NULL,
    sets INT NOT NULL,
    reps INT NOT NULL,
    weight_kg DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (workout_id) REFERENCES workouts(workout_id),
    FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id)
);

-- Tabell: logg för personliga rekord (fylls av trigger)
CREATE TABLE pr_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    exercise_id INT NOT NULL,
    old_weight DECIMAL(5,2),
    new_weight DECIMAL(5,2),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exercise_id) REFERENCES exercises(exercise_id)
);

-- Exempeldata: 18 gymövningar
INSERT INTO exercises (name, category) VALUES
('Bänkpress', 'Bröst'),
('Incline Bänkpress', 'Bröst'),
('Kabelflyes', 'Bröst'),
('Marklyft', 'Rygg'),
('Skivstångsrodd', 'Rygg'),
('Latsdrag', 'Rygg'),
('Militärpress', 'Axlar'),
('Sidolyft', 'Axlar'),
('Bicepscurl', 'Armar'),
('Hammarcurl', 'Armar'),
('Tricepsnedpressning', 'Armar'),
('Knäböj', 'Ben'),
('Benpress', 'Ben'),
('Utfallssteg', 'Ben'),
('Benlyft', 'Ben'),
('Plankan', 'Mage'),
('Crunches', 'Mage'),
('Rygglyft', 'Rygg');

-- Exempeldata: träningspass
INSERT INTO workouts (workout_date, notes) VALUES
('2025-01-06', 'Bra pass, kände mig stark'),
('2025-01-08', 'Bröstdag'),
('2025-01-10', 'Bendag, trött'),
('2025-01-13', 'Ryggdag'),
('2025-01-15', 'Axlar och armar'),
('2025-01-17', 'Full body'),
('2025-01-20', 'Bendag'),
('2025-01-22', 'Bröst och triceps');

-- Exempeldata: övningar per träningspass
INSERT INTO workout_exercises (workout_id, exercise_id, sets, reps, weight_kg) VALUES
(1, 1, 4, 8, 80.00),
(1, 2, 3, 10, 60.00),
(1, 3, 3, 12, 20.00),
(2, 1, 4, 6, 85.00),
(2, 2, 3, 8, 65.00),
(2, 11, 3, 12, 30.00),
(3, 12, 4, 8, 100.00),
(3, 13, 3, 10, 120.00),
(3, 14, 3, 12, 20.00),
(4, 4, 4, 5, 120.00),
(4, 5, 3, 8, 70.00),
(4, 6, 3, 10, 55.00),
(5, 7, 4, 8, 50.00),
(5, 8, 3, 15, 10.00),
(5, 9, 3, 12, 20.00),
(6, 1, 3, 10, 82.50),
(6, 12, 3, 10, 95.00),
(6, 7, 3, 10, 52.50),
(7, 12, 4, 8, 105.00),
(7, 13, 3, 10, 125.00),
(8, 1, 4, 8, 87.50),
(8, 2, 3, 10, 67.50),
(8, 11, 4, 10, 32.50);
