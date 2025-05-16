-- #####################################################################
-- # Bee Farming Records Database Schema                             #
-- #####################################################################
--
-- This script creates the tables for a bee farming management system.
--
-- Entities:
-- 1. Beekeepers: Information about the individuals managing the bees.
-- 2. Apiaries: Locations where beehives are kept.
-- 3. Hives: Individual beehive units.
-- 4. Queens: Information about queen bees in the hives.
-- 5. Inspections: Records of hive checks and colony status.
-- 6. Harvests: Records of honey and other bee product collection.
-- 7. Treatments: Records of any treatments applied to hives/colonies.
-- 8. Feedings: Records of supplementary feeding provided to colonies.
--
-- #####################################################################
-- #####################################################################
-- Database 'hivebase'
CREATE DATABASE hivebase;
use hivebase;
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Table `Beekeepers`
-- Stores information about the beekeepers.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Beekeepers` (
  `beekeeper_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the beekeeper.',
  `first_name` VARCHAR(100) NOT NULL COMMENT 'First name of the beekeeper.',
  `last_name` VARCHAR(100) NOT NULL COMMENT 'Last name of the beekeeper.',
  `email` VARCHAR(255) NULL UNIQUE COMMENT 'Email address of the beekeeper (optional, but unique if provided).',
  `phone_number` VARCHAR(20) NULL COMMENT 'Phone number of the beekeeper (optional).',
  `join_date` DATE NULL COMMENT 'Date the beekeeper started or joined (optional).',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.'
) ENGINE=InnoDB COMMENT='Stores information about the beekeepers.';

-- -----------------------------------------------------
-- Table `Apiaries`
-- Stores information about the locations where hives are kept (apiaries).
-- An apiary can be managed by a beekeeper.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Apiaries` (
  `apiary_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the apiary.',
  `beekeeper_id` INT NULL COMMENT 'Foreign key referencing the beekeeper managing this apiary. Can be NULL if unassigned or collectively managed.',
  `apiary_name` VARCHAR(255) NOT NULL COMMENT 'User-friendly name for the apiary (e.g., "Home Garden", "North Field").',
  `location_description` TEXT NULL COMMENT 'Detailed location of the apiary (e.g., address, GPS coordinates, or descriptive text).',
  `establishment_date` DATE NULL COMMENT 'Date the apiary was established (optional).',
  `notes` TEXT NULL COMMENT 'General notes about the apiary.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  FOREIGN KEY (`beekeeper_id`) REFERENCES `Beekeepers` (`beekeeper_id`)
    ON DELETE SET NULL -- If the beekeeper is deleted, set this field to NULL. The apiary record itself remains.
    ON UPDATE CASCADE -- If the beekeeper_id in Beekeepers table changes, update it here too.
) ENGINE=InnoDB COMMENT='Stores information about apiary locations.';

-- -----------------------------------------------------
-- Table `Hives`
-- Stores information about individual beehives.
-- A hive belongs to an apiary.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Hives` (
  `hive_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the hive.',
  `apiary_id` INT NOT NULL COMMENT 'Foreign key referencing the apiary this hive belongs to.',
  `hive_identifier` VARCHAR(100) NOT NULL COMMENT 'User-defined name or number for the hive (e.g., "Hive A", "103"). Must be unique within its apiary.',
  `hive_type` VARCHAR(50) NULL COMMENT 'Type of hive (e.g., "Langstroth", "Top Bar", "Warre", "Flow Hive").',
  `date_established` DATE NULL COMMENT 'Date the hive was set up with a colony (optional).',
  `source_of_colony` VARCHAR(100) NULL COMMENT 'Origin of the bee colony (e.g., "Nuc", "Swarm Capture", "Package", "Split").',
  `status` VARCHAR(50) DEFAULT 'Active' COMMENT 'Current status of the hive (e.g., "Active", "Empty", "Destroyed", "Sold", "Combined").',
  `notes` TEXT NULL COMMENT 'General notes about the hive.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  UNIQUE (`apiary_id`, `hive_identifier`) COMMENT 'Ensures hive_identifier is unique within each apiary.',
  FOREIGN KEY (`apiary_id`) REFERENCES `Apiaries` (`apiary_id`)
    ON DELETE RESTRICT -- Prevent deletion of an apiary if it still has hives. Hives must be moved or deleted first.
    ON UPDATE CASCADE -- If the apiary_id in Apiaries table changes, update it here too.
) ENGINE=InnoDB COMMENT='Stores information about individual beehives.';

-- -----------------------------------------------------
-- Table `Queens`
-- Stores information about the queen bees.
-- A hive typically has one active queen at a time. This table tracks current and past queens for a hive.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Queens` (
  `queen_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the queen record.',
  `hive_id` INT NOT NULL COMMENT 'Foreign key referencing the hive this queen is or was associated with.',
  `date_introduced` DATE NULL COMMENT 'Date the queen was introduced to the hive.',
  `source` VARCHAR(100) NULL COMMENT 'Origin of the queen (e.g., "Raised in hive", "Purchased", "From Split").',
  `breed` VARCHAR(100) NULL COMMENT 'Breed of the queen (e.g., "Italian", "Carniolan", "Buckfast", "Russian").',
  `mark_color_year` VARCHAR(50) NULL COMMENT 'Color mark on the queen and corresponding year(s) (e.g., "White (2021/2026)", "Yellow (2022/2027)").',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'Indicates if this is the current active queen for the hive (TRUE) or a past queen (FALSE).',
  `notes` TEXT NULL COMMENT 'General notes about the queen.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  FOREIGN KEY (`hive_id`) REFERENCES `Hives` (`hive_id`)
    ON DELETE CASCADE -- If the hive is deleted, queen records associated with it are also deleted.
    ON UPDATE CASCADE -- If the hive_id in Hives table changes, update it here too.
) ENGINE=InnoDB COMMENT='Tracks current and past queen bees for hives.';

-- -----------------------------------------------------
-- Table `Inspections`
-- Records details of hive inspections, including colony health and status.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Inspections` (
  `inspection_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the inspection record.',
  `hive_id` INT NOT NULL COMMENT 'Foreign key referencing the hive that was inspected.',
  `beekeeper_id` INT NULL COMMENT 'Foreign key referencing the beekeeper who performed the inspection (optional).',
  `inspection_date` DATETIME NOT NULL COMMENT 'Date and time of the inspection.',
  `weather` VARCHAR(255) NULL COMMENT 'Weather conditions during inspection (e.g., "Sunny, 25C, Light Breeze").',
  `temperament` VARCHAR(50) NULL COMMENT 'Temperament of the colony (e.g., "Calm", "Nervous", "Aggressive", "Defensive").',
  `queen_seen` BOOLEAN NULL COMMENT 'Was the queen observed during this inspection?',
  `queen_status` VARCHAR(100) NULL COMMENT 'Observations about the queen or queen cells (e.g., "Laying well", "Spotted", "Queen cells present", "No queen signs").',
  `eggs_seen` BOOLEAN NULL COMMENT 'Were eggs observed?',
  `larvae_seen` BOOLEAN NULL COMMENT 'Were young larvae observed?',
  `capped_brood_seen` BOOLEAN NULL COMMENT 'Was capped brood observed?',
  `brood_pattern` VARCHAR(100) NULL COMMENT 'Pattern of the brood (e.g., "Solid", "Spotty", "Compact").',
  `frames_of_bees` DECIMAL(4,1) NULL COMMENT 'Number of frames covered with bees (e.g., 7.5).',
  `frames_of_brood` DECIMAL(4,1) NULL COMMENT 'Number of frames containing brood (all stages).',
  `frames_of_honey` DECIMAL(4,1) NULL COMMENT 'Number of frames primarily containing honey stores.',
  `frames_of_pollen` DECIMAL(4,1) NULL COMMENT 'Number of frames primarily containing pollen stores.',
  `colony_strength` VARCHAR(50) NULL COMMENT 'Overall strength of the colony (e.g., "Strong", "Moderate", "Weak", "Nuc").',
  `pests_observed` TEXT NULL COMMENT 'Description of any pests observed (e.g., "Varroa mites (low count)", "Small hive beetle (3 seen)").',
  `diseases_observed` TEXT NULL COMMENT 'Description of any diseases observed (e.g., "Chalkbrood (minor)", "No signs of EFB/AFB").',
  `actions_taken` TEXT NULL COMMENT 'Actions performed during the inspection (e.g., "Added super", "Replaced frame #3", "Treated for varroa").',
  `recommendations` TEXT NULL COMMENT 'Recommendations for future actions (e.g., "Check for queen cells next week", "Consider feeding if weather turns cold").',
  `notes` TEXT NULL COMMENT 'General notes about the inspection.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  FOREIGN KEY (`hive_id`) REFERENCES `Hives` (`hive_id`)
    ON DELETE CASCADE -- If the hive is deleted, its inspection records are also deleted.
    ON UPDATE CASCADE,
  FOREIGN KEY (`beekeeper_id`) REFERENCES `Beekeepers` (`beekeeper_id`)
    ON DELETE SET NULL -- If the beekeeper is deleted, keep the inspection record but nullify the beekeeper link.
    ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Records details of hive inspections.';

-- -----------------------------------------------------
-- Table `Harvests`
-- Records details of products harvested from hives (e.g., honey, beeswax).
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Harvests` (
  `harvest_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the harvest record.',
  `hive_id` INT NOT NULL COMMENT 'Foreign key referencing the hive from which the product was harvested.',
  `beekeeper_id` INT NULL COMMENT 'Foreign key referencing the beekeeper who performed the harvest (optional).',
  `harvest_date` DATE NOT NULL COMMENT 'Date of the harvest.',
  `product_type` VARCHAR(50) NOT NULL COMMENT 'Type of product harvested (e.g., "Honey", "Beeswax", "Pollen", "Propolis", "Royal Jelly").',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT 'Amount of product harvested.',
  `unit` VARCHAR(20) NOT NULL COMMENT 'Unit of measurement for the quantity (e.g., "kg", "lbs", "frames", "grams", "liters").',
  `honey_type` VARCHAR(100) NULL COMMENT 'Specific type of honey, if applicable (e.g., "Wildflower", "Clover", "Manuka", "Comb Honey").',
  `notes` TEXT NULL COMMENT 'General notes about the harvest.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  FOREIGN KEY (`hive_id`) REFERENCES `Hives` (`hive_id`)
    ON DELETE CASCADE -- If the hive is deleted, its harvest records are also deleted.
    ON UPDATE CASCADE,
  FOREIGN KEY (`beekeeper_id`) REFERENCES `Beekeepers` (`beekeeper_id`)
    ON DELETE SET NULL -- If the beekeeper is deleted, keep the harvest record but nullify the beekeeper link.
    ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Records details of products harvested from hives.';

-- -----------------------------------------------------
-- Table `Treatments`
-- Records details of treatments applied to hives for pests or diseases.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Treatments` (
  `treatment_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the treatment record.',
  `hive_id` INT NOT NULL COMMENT 'Foreign key referencing the hive that was treated.',
  `beekeeper_id` INT NULL COMMENT 'Foreign key referencing the beekeeper who administered the treatment (optional).',
  `treatment_date_start` DATE NOT NULL COMMENT 'Start date of the treatment application.',
  `treatment_date_end` DATE NULL COMMENT 'End date of the treatment, if applicable (e.g. for strips).',
  `target_pest_or_disease` VARCHAR(255) NOT NULL COMMENT 'The pest or disease being targeted (e.g., "Varroa mites", "Nosema", "American Foulbrood").',
  `product_used` VARCHAR(255) NOT NULL COMMENT 'Name of the treatment product used (e.g., "Apivar", "Formic Pro", "Oxalic Acid Vaporization").',
  `dosage` VARCHAR(100) NULL COMMENT 'Dosage of the product used.',
  `application_method` VARCHAR(255) NULL COMMENT 'Method of application (e.g., "Strips", "Vaporization", "Drench").',
  `duration_days` INT NULL COMMENT 'Intended duration of the treatment in days, if applicable.',
  `withdrawal_period_days` INT NULL COMMENT 'Honey withdrawal period in days after treatment, if applicable.',
  `notes` TEXT NULL COMMENT 'General notes about the treatment.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  FOREIGN KEY (`hive_id`) REFERENCES `Hives` (`hive_id`)
    ON DELETE CASCADE -- If the hive is deleted, its treatment records are also deleted.
    ON UPDATE CASCADE,
  FOREIGN KEY (`beekeeper_id`) REFERENCES `Beekeepers` (`beekeeper_id`)
    ON DELETE SET NULL -- If the beekeeper is deleted, keep the treatment record but nullify the beekeeper link.
    ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Records details of treatments applied to hives.';

-- -----------------------------------------------------
-- Table `Feedings`
-- Records details of supplementary feeding provided to bee colonies.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Feedings` (
  `feeding_id` INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the feeding record.',
  `hive_id` INT NOT NULL COMMENT 'Foreign key referencing the hive that was fed.',
  `beekeeper_id` INT NULL COMMENT 'Foreign key referencing the beekeeper who performed the feeding (optional).',
  `feeding_date` DATE NOT NULL COMMENT 'Date the feeding was provided.',
  `feed_type` VARCHAR(100) NOT NULL COMMENT 'Type of feed provided (e.g., "Sugar syrup 1:1", "Sugar syrup 2:1", "Pollen patty", "Fondant", "Dry sugar").',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT 'Amount of feed provided.',
  `unit` VARCHAR(20) NOT NULL COMMENT 'Unit of measurement for the quantity (e.g., "liters", "kg", "grams", "gallons", "patties").',
  `reason_for_feeding` VARCHAR(255) NULL COMMENT 'Reason for providing the feed (e.g., "Stimulative", "Winter stores", "New colony establishment", "Darth period").',
  `notes` TEXT NULL COMMENT 'General notes about the feeding.',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was created.',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of when the record was last updated.',
  FOREIGN KEY (`hive_id`) REFERENCES `Hives` (`hive_id`)
    ON DELETE CASCADE -- If the hive is deleted, its feeding records are also deleted.
    ON UPDATE CASCADE,
  FOREIGN KEY (`beekeeper_id`) REFERENCES `Beekeepers` (`beekeeper_id`)
    ON DELETE SET NULL -- If the beekeeper is deleted, keep the feeding record but nullify the beekeeper link.
    ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Records details of supplementary feeding for hives.';


-- -----------------------------------------------------
-- Sample Data for `Beekeepers`
-- -----------------------------------------------------
-- Inserting data into `Beekeepers` table
INSERT INTO `Beekeepers` (first_name, last_name, email, phone_number, join_date) VALUES
('John', 'Mwangi', 'john.mwangi@gmail.com', '0712345678', '2015-03-21'),
('Grace', 'Odhiambo', 'grace.odhiambo@yahoo.com', '0723456789', '2017-06-15'),
('Musa', 'Kibet', 'musa.kibet@gmail.com', '0734567890', '2018-11-12'),
('Anne', 'Njeri', 'anne.njeri@hotmail.com', '0745678901', '2019-01-08'),
('Juma', 'Ochieng', 'juma.ochieng@gmail.com', '0756789012', '2016-04-03'),
('Peter', 'Kimani', 'peter.kimani@outlook.com', '0767890123', '2017-09-25'),
('Jane', 'Kariuki', 'jane.kariuki@yahoo.com', '0778901234', '2019-02-19'),
('Samuel', 'Wambui', 'samuel.wambui@gmail.com', '0789012345', '2020-08-10'),
('Ruth', 'Achieng', 'ruth.achieng@icloud.com', '0790123456', '2021-06-18'),
('David', 'Mutai', 'david.mutai@gmail.com', '0701234567', '2014-07-22');

-- Inserting data into `Apiaries` table
INSERT INTO `Apiaries` (beekeeper_id, apiary_name, location_description, establishment_date, notes) VALUES
(1, 'Kiambu East Apiary', 'Kiambu County, near Karuri town. Coordinates: -1.142, 36.767', '2015-03-22', 'Honey production focused on highland flora.'),
(2, 'Lake Victoria Apiary', 'Kisumu County, near Dunga Beach. Coordinates: -0.054, 34.754', '2017-06-16', 'Apiary established to diversify honey collection from lakeside plants.'),
(3, 'Kisii West Apiary', 'Kisii County, near Nyansiongo. Coordinates: -0.725, 34.762', '2018-11-13', 'Focus on honey and beeswax for local markets.'),
(4, 'Central Highlands Apiary', 'Nyeri County, Mount Kenya foothills. Coordinates: -0.410, 36.938', '2019-01-09', 'High-altitude flora with varied wildflower species for honey collection.'),
(5, 'Nyanza Apiary', 'Homabay County, near Lake Victoria. Coordinates: -0.551, 34.688', '2016-04-04', 'Specializing in honey production from tropical vegetation.'),
(6, 'Murang’a Apiary', 'Murang’a County, Thika region. Coordinates: -0.711, 37.026', '2017-09-26', 'Widely known for production of raw honey from eucalyptus trees.'),
(7, 'Rift Valley Apiary', 'Nakuru County, near Menengai Crater. Coordinates: -0.296, 36.034', '2019-02-20', 'Focusing on diverse bee products for the urban market in Nairobi.'),
(8, 'Mt. Kenya Apiary', 'Embu County, on the slopes of Mount Kenya. Coordinates: -0.485, 37.292', '2020-08-11', 'High-altitude honey production aimed at export.'),
(9, 'Western Kenya Apiary', 'Vihiga County, near Sabatia town. Coordinates: -0.233, 34.760', '2021-06-19', 'Combining both honey and propolis collection from natural forests.'),
(10, 'Eastern Highlands Apiary', 'Meru County, lower slopes of Mt. Kenya. Coordinates: -0.155, 37.636', '2014-07-23', 'Variety of floral sources producing both honey and beeswax.');

-- Inserting data into `Hives` table
INSERT INTO `Hives` (apiary_id, hive_identifier, hive_type, date_established, source_of_colony, status) VALUES
(1, 'Hive A', 'Langstroth', '2015-03-23', 'Swarm Capture', 'Active'),
(2, 'Hive B', 'Top Bar', '2017-06-17', 'Package', 'Active'),
(3, 'Hive C', 'Warre', '2018-11-14', 'Nuc', 'Active'),
(4, 'Hive D', 'Flow Hive', '2019-01-10', 'Swarm Capture', 'Active'),
(5, 'Hive E', 'Langstroth', '2016-04-05', 'Package', 'Active'),
(6, 'Hive F', 'Top Bar', '2017-09-27', 'Nuc', 'Active'),
(7, 'Hive G', 'Warre', '2019-02-21', 'Swarm Capture', 'Active'),
(8, 'Hive H', 'Flow Hive', '2020-08-12', 'Package', 'Active'),
(9, 'Hive I', 'Langstroth', '2021-06-20', 'Nuc', 'Active'),
(10, 'Hive J', 'Top Bar', '2014-07-24', 'Swarm Capture', 'Active');

-- Inserting data into `Queens` table
INSERT INTO `Queens` (hive_id, date_introduced, source, breed, mark_color_year, is_active) VALUES
(1, '2015-03-24', 'Purchased', 'Italian', 'White (2015/2020)', TRUE),
(2, '2017-06-18', 'Raised in hive', 'Carniolan', 'Yellow (2017/2022)', TRUE),
(3, '2018-11-15', 'From Split', 'Buckfast', 'Red (2018/2023)', TRUE),
(4, '2019-01-11', 'Purchased', 'Russian', 'Blue (2019/2024)', TRUE),
(5, '2016-04-06', 'Purchased', 'Italian', 'White (2016/2021)', TRUE),
(6, '2017-09-28', 'Raised in hive', 'Carniolan', 'Yellow (2017/2022)', TRUE),
(7, '2019-02-22', 'From Split', 'Buckfast', 'Red (2019/2024)', TRUE),
(8, '2020-08-13', 'Purchased', 'Russian', 'Blue (2020/2025)', TRUE),
(9, '2021-06-21', 'From Split', 'Italian', 'White (2021/2026)', TRUE),
(10, '2014-07-25', 'Raised in hive', 'Carniolan', 'Yellow (2014/2019)', TRUE);

-- Inserting data into `Inspections` table
INSERT INTO `Inspections` 
(hive_id, beekeeper_id, inspection_date, weather, temperament, queen_seen, queen_status, eggs_seen, larvae_seen, capped_brood_seen, brood_pattern, frames_of_bees, frames_of_brood, frames_of_honey, frames_of_pollen, colony_strength, pests_observed, diseases_observed, actions_taken, recommendations, notes) 
VALUES 
(1, 1, '2023-05-01 10:00:00', 'Sunny, 26C', 'Calm', TRUE, 'Laying well', TRUE, TRUE, TRUE, 'Solid', 8.0, 6.0, 4.0, 2.0, 'Strong', 'None', 'None', 'Added super', 'Check for queen cells next month', 'Healthy colony, no issues observed.'),
(2, 2, '2023-06-02 09:30:00', 'Cloudy, 20C', 'Nervous', TRUE, 'Spotted', TRUE, TRUE, TRUE, 'Spotty', 7.0, 5.0, 3.0, 2.0, 'Moderate', 'Varroa mites (low count)', 'No signs of diseases', 'Replaced frame #3', 'Monitor mite levels closely', 'Hive needs monitoring for mite management.'),
(3, 3, '2023-06-10 11:15:00', 'Sunny, 28C', 'Calm', TRUE, 'Spotted', TRUE, TRUE, TRUE, 'Compact', 9.0, 7.0, 5.0, 3.0, 'Strong', 'Small hive beetle (3 seen)', 'No diseases observed', 'Treated for small hive beetle', 'Consider adding super for expansion', 'Strong hive with minor pest issue.'),
(5, 5, '2023-07-15 08:45:00', 'Sunny, 24C', 'Defensive', TRUE, 'Spotted', TRUE, TRUE, TRUE, 'Spotty', 6.5, 4.5, 2.5, 1.0, 'Moderate', 'Varroa mites (moderate count)', 'No diseases observed', 'Treated for varroa mites', 'Monitor hive closely', 'Hive in recovery from varroa treatment.'),
(6, 6, '2023-08-01 10:00:00', 'Cloudy, 22C', 'Calm', TRUE, 'Laying well', TRUE, TRUE, TRUE, 'Solid', 9.0, 7.5, 5.0, 2.0, 'Strong', 'None', 'No diseases observed', 'Added super', 'Check for honey stores next week', 'Healthy colony with strong brood pattern.'),
(7, 7, '2023-08-10 12:00:00', 'Sunny, 27C', 'Nervous', TRUE, 'Laying well', TRUE, TRUE, TRUE, 'Compact', 8.0, 6.5, 4.5, 2.5, 'Moderate', 'None', 'No diseases observed', 'Replaced damaged frames', 'Consider adding pollen supplements', 'Hive performing well but with minor repairs needed.'),
(8, 8, '2023-09-05 09:30:00', 'Rainy, 20C', 'Aggressive', TRUE, 'Spotted', TRUE, TRUE, TRUE, 'Spotty', 7.5, 5.0, 3.5, 2.0, 'Moderate', 'Varroa mites (high count)', 'No diseases observed', 'Treated for varroa mites', 'Monitor queen status closely', 'Hive under treatment for mites, observed aggressive behavior.'),
(9, 9, '2023-09-12 13:00:00', 'Sunny, 28C', 'Calm', TRUE, 'Laying well', TRUE, TRUE, TRUE, 'Solid', 9.5, 8.0, 6.0, 3.0, 'Strong', 'None', 'No diseases observed', 'Added super', 'Check honey stores before winter', 'Colony in excellent condition with healthy brood pattern.'),
(10, 10, '2023-10-04 10:30:00', 'Cloudy, 23C', 'Defensive', TRUE, 'Laying well', TRUE, TRUE, TRUE, 'Compact', 7.0, 5.0, 3.0, 1.5, 'Moderate', 'None', 'No diseases observed', 'Replaced damaged frames', 'Monitor for queen cells next month', 'Hive under observation, defensive temperament observed.');



-- Inserting data into `Harvests` table
INSERT INTO `Harvests` (hive_id, beekeeper_id, harvest_date, product_type, quantity, unit, honey_type, notes) VALUES
(1, 1, '2023-06-15', 'Honey', 50.00, 'kg', 'Wildflower', 'Harvested from highland flora.'),
(2, 2, '2023-07-20', 'Honey', 35.00, 'kg', 'Clover', 'Produced from lakeside vegetation.'),
(3, 3, '2023-08-12', 'Honey', 45.00, 'kg', 'Manuka', 'Harvested during the peak flowering season.'),
(4, 4, '2023-09-02', 'Honey', 40.00, 'kg', 'Comb Honey', 'Harvested from high-altitude apiary.'),
(5, 5, '2023-06-18', 'Beeswax', 10.00, 'kg', 'None', 'Used for local crafting.'),
(6, 6, '2023-07-25', 'Pollen', 20.00, 'kg', 'None', 'For local market sales.'),
(7, 7, '2023-08-19', 'Propolis', 12.00, 'kg', 'None', 'Used for medicinal purposes.'),
(8, 8, '2023-09-10', 'Honey', 60.00, 'kg', 'Comb Honey', 'Harvested with excellent honey flow.'),
(9, 9, '2023-07-13', 'Honey', 55.00, 'kg', 'Wildflower', 'From forested apiary region.'),
(10, 10, '2023-08-15', 'Beeswax', 8.00, 'kg', 'None', 'Used for candles and cosmetics.');

-- Inserting data into `Treatments` table
INSERT INTO `Treatments` (hive_id, beekeeper_id, treatment_date_start, treatment_date_end, target_pest_or_disease, product_used, dosage, application_method, duration_days, withdrawal_period_days, notes) VALUES
(1, 1, '2023-05-10', '2023-05-20', 'Varroa mites', 'Apivar', '2 strips', 'Strips', 10, 21, 'Applied during mite season for mite control.'),
(2, 2, '2023-06-22', '2023-06-30', 'Small hive beetle', 'Formic Pro', '1 pad', 'Vaporization', 8, 14, 'Used for small hive beetle control during rainy season.'),
(3, 3, '2023-07-10', '2023-07-17', 'Nosema', 'Oxalic Acid Vaporization', '20g', 'Vaporization', 7, 21, 'Treatment for Nosema to improve colony health.'),
(4, 4, '2023-08-15', '2023-08-25', 'Varroa mites', 'Apivar', '2 strips', 'Strips', 10, 21, 'Applied for mite control in early autumn.'),
(5, 5, '2023-06-30', '2023-07-10', 'Small hive beetle', 'Formic Pro', '1 pad', 'Vaporization', 8, 14, 'Vaporization method to control beetles during dry season.'),
(6, 6, '2023-07-18', '2023-07-28', 'Varroa mites', 'Apivar', '2 strips', 'Strips', 10, 21, 'Treatment during high mite season.'),
(7, 7, '2023-08-12', '2023-08-22', 'Nosema', 'Oxalic Acid Vaporization', '20g', 'Vaporization', 7, 21, 'Nosema treatment to enhance brood development.'),
(8, 8, '2023-09-10', '2023-09-20', 'Varroa mites', 'Apivar', '2 strips', 'Strips', 10, 21, 'Strips applied to manage mite infestation.'),
(9, 9, '2023-07-15', '2023-07-25', 'Small hive beetle', 'Formic Pro', '1 pad', 'Vaporization', 8, 14, 'Control for small hive beetle with moderate infestation.'),
(10, 10, '2023-08-05', '2023-08-15', 'Varroa mites', 'Apivar', '2 strips', 'Strips', 10, 21, 'Varroa control applied during mite peak season.');

-- Inserting data into `Feedings` table
INSERT INTO `Feedings` (hive_id, beekeeper_id, feeding_date, feed_type, quantity, unit, reason_for_feeding, notes) VALUES
(1, 1, '2023-05-05', 'Sugar syrup 1:1', 5.00, 'liters', 'Stimulative', 'Feeding during early spring to stimulate colony growth.'),
(2, 2, '2023-06-10', 'Pollen patty', 1.00, 'kg', 'Stimulative', 'Added to boost protein intake during rainy season.'),
(3, 3, '2023-07-05', 'Sugar syrup 2:1', 3.00, 'liters', 'Winter stores', 'Feeding to prepare the colony for winter.'),
(4, 4, '2023-08-10', 'Fondant', 2.00, 'kg', 'New colony establishment', 'Fed during establishment of new colony.'),
(5, 5, '2023-06-15', 'Dry sugar', 4.00, 'kg', 'Winter stores', 'Feeding to ensure winter honey stores are sufficient.'),
(6, 6, '2023-07-10', 'Sugar syrup 2:1', 6.00, 'liters', 'Stimulative', 'Feeding to strengthen hive for honey production.'),
(7, 7, '2023-08-14', 'Pollen patty', 1.50, 'kg', 'Stimulative', 'Encouraging early brood development.'),
(8, 8, '2023-09-05', 'Fondant', 3.00, 'kg', 'Winter stores', 'Preparing the colony for the winter season.'),
(9, 9, '2023-07-20', 'Sugar syrup 1:1', 2.00, 'liters', 'Stimulative', 'Stimulated hive for increased honey production.'),
(10, 10, '2023-08-25', 'Dry sugar', 5.00, 'kg', 'Winter stores', 'Feeding to boost stores for the winter months.');

