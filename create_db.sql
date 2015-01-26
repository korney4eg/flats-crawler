CREATE DATABASE IF NOT EXISTS flats;
USE FLATS;
DROP TABLE IF EXISTS `global`;
CREATE TABLE `global` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `address` varchar(70) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `rooms` varchar(3) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS `price_history`;
CREATE TABLE `price_history` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `code` int(11) NOT NULL,
  `price` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8;
