-- creating database
CREATE DATABASE IF NOT EXISTS flats;

CREATE USER 'flat'@'localhost' IDENTIFIED BY 'flat';

GRANT ALL PRIVILEGES ON flats.* TO 'flat'@'localhost';

DROP TABLE IF EXISTS `global`;
CREATE TABLE `global` (
  `code` int(11) NOT NULL,
  `address` varchar(70) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `rooms` varchar(3) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `price_history`;
CREATE TABLE `price_history` (
  `code` int(11) NOT NULL,
  `price` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

