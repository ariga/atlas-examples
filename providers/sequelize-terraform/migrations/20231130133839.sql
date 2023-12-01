-- Create "Users" table
CREATE TABLE `Users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "Tasks" table
CREATE TABLE `Tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `complete` bool NULL DEFAULT 0,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `userID` int NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `userID` (`userID`),
  CONSTRAINT `Tasks_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `Users` (`id`) ON UPDATE CASCADE ON DELETE NO ACTION
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
