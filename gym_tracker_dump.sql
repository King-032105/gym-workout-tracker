-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: gym_tracker
-- ------------------------------------------------------
-- Server version	8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `exercises`
--

DROP TABLE IF EXISTS `exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercises` (
  `exercise_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`exercise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercises`
--

LOCK TABLES `exercises` WRITE;
/*!40000 ALTER TABLE `exercises` DISABLE KEYS */;
INSERT INTO `exercises` VALUES (1,'Bänkpress','Bröst'),(2,'Incline Bänkpress','Bröst'),(3,'Kabelflyes','Bröst'),(4,'Marklyft','Rygg'),(5,'Skivstångsrodd','Rygg'),(6,'Latsdrag','Rygg'),(7,'Militärpress','Axlar'),(8,'Sidolyft','Axlar'),(9,'Bicepscurl','Armar'),(10,'Hammarcurl','Armar'),(11,'Tricepsnedpressning','Armar'),(12,'Knäböj','Ben'),(13,'Benpress','Ben'),(14,'Utfallssteg','Ben'),(15,'Benlyft','Ben'),(16,'Plankan','Mage'),(17,'Crunches','Mage'),(18,'Rygglyft','Rygg');
/*!40000 ALTER TABLE `exercises` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pr_log`
--

DROP TABLE IF EXISTS `pr_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pr_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `exercise_id` int NOT NULL,
  `workout_exercise_id` int DEFAULT NULL,
  `old_weight` decimal(5,2) DEFAULT NULL,
  `sets` int DEFAULT NULL,
  `reps` int DEFAULT NULL,
  `new_weight` decimal(5,2) DEFAULT NULL,
  `log_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `exercise_id` (`exercise_id`),
  KEY `workout_exercise_id` (`workout_exercise_id`),
  CONSTRAINT `pr_log_ibfk_1` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`exercise_id`),
  CONSTRAINT `pr_log_ibfk_2` FOREIGN KEY (`workout_exercise_id`) REFERENCES `workout_exercises` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pr_log`
--

LOCK TABLES `pr_log` WRITE;
/*!40000 ALTER TABLE `pr_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `pr_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workout_exercises`
--

DROP TABLE IF EXISTS `workout_exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workout_exercises` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workout_id` int NOT NULL,
  `exercise_id` int NOT NULL,
  `sets` int NOT NULL,
  `reps` int NOT NULL,
  `weight_kg` decimal(5,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `workout_id` (`workout_id`),
  KEY `exercise_id` (`exercise_id`),
  CONSTRAINT `workout_exercises_ibfk_1` FOREIGN KEY (`workout_id`) REFERENCES `workouts` (`workout_id`),
  CONSTRAINT `workout_exercises_ibfk_2` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`exercise_id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workout_exercises`
--

LOCK TABLES `workout_exercises` WRITE;
/*!40000 ALTER TABLE `workout_exercises` DISABLE KEYS */;
INSERT INTO `workout_exercises` VALUES (1,1,1,4,8,80.00),(2,1,2,3,10,60.00),(3,1,3,3,12,20.00),(4,2,1,4,6,85.00),(5,2,2,3,8,65.00),(6,2,11,3,12,30.00),(7,3,12,4,8,100.00),(8,3,13,3,10,120.00),(9,3,14,3,12,20.00),(10,4,4,4,5,120.00),(11,4,5,3,8,70.00),(12,4,6,3,10,55.00),(13,5,7,4,8,50.00),(14,5,8,3,15,10.00),(15,5,9,3,12,20.00),(16,6,1,3,10,82.50),(17,6,12,3,10,95.00),(18,6,7,3,10,52.50),(19,7,12,4,8,105.00),(20,7,13,3,10,125.00),(21,8,1,4,8,87.50),(22,8,2,3,10,67.50),(23,8,11,4,10,32.50),(24,9,7,4,8,55.00),(25,9,8,3,15,12.00),(26,10,7,4,8,55.00),(27,10,8,3,15,12.00),(28,11,1,2,3,20.00),(29,11,2,3,4,34.00),(30,12,18,21,4,43.30),(31,13,1,15,3,35.00),(32,15,5,21,2,21.00),(33,16,12,32,2,40.00),(34,17,18,23,3,23.00);
/*!40000 ALTER TABLE `workout_exercises` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `check_pr` AFTER INSERT ON `workout_exercises` FOR EACH ROW BEGIN
    DECLARE current_pr DECIMAL(5,2);

    
    SELECT MAX(weight_kg) INTO current_pr
    FROM workout_exercises
    WHERE exercise_id = NEW.exercise_id
      AND id != NEW.id;

    
    IF current_pr IS NULL OR NEW.weight_kg > current_pr THEN
        INSERT INTO pr_log (exercise_id, old_weight, new_weight)
        VALUES (NEW.exercise_id, current_pr, NEW.weight_kg);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `workouts`
--

DROP TABLE IF EXISTS `workouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workouts` (
  `workout_id` int NOT NULL AUTO_INCREMENT,
  `workout_date` date NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`workout_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workouts`
--

LOCK TABLES `workouts` WRITE;
/*!40000 ALTER TABLE `workouts` DISABLE KEYS */;
INSERT INTO `workouts` VALUES (1,'2025-01-06','Bra pass, kände mig stark'),(2,'2025-01-08','Bröstdag'),(3,'2025-01-10','Bendag, trött'),(4,'2025-01-13','Ryggdag'),(5,'2025-01-15','Axlar och armar'),(6,'2025-01-17','Full body'),(7,'2025-01-20','Bendag'),(8,'2025-01-22','Bröst och triceps'),(9,'2025-01-24','Axeldag'),(10,'2025-01-24','Axeldag'),(11,'2026-01-02','12'),(12,'2026-01-05',''),(13,'2026-03-08',''),(14,'2012-12-21',''),(15,'2026-03-08',''),(16,'2026-03-08',''),(17,'2026-03-09','');
/*!40000 ALTER TABLE `workouts` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-09 17:57:34
