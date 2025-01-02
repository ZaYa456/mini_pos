-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jan 02, 2025 at 08:49 AM
-- Server version: 8.2.0
-- PHP Version: 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mini_pos`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `register_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins--name--unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `password`, `register_date`) VALUES
(1, 'zak', '$2y$10$h0AG4PIxLRIokxx5MIL90OA7SN3VMovZ/qwisfuZEPs6ftXUO/vTq', '2024-10-24 09:47:50');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories--name--unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`) VALUES
(5, 'Baking & Cooking Supplies'),
(1, 'Food & Beverages'),
(2, 'Fruits & Vegetables'),
(4, 'Health & Personal Care'),
(3, 'Household Essentials'),
(7, 'Miscellaneous'),
(6, 'Pet Supplies');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `barcode` varchar(255) NOT NULL,
  `category_id` int NOT NULL,
  `register_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products--barcode--unique` (`barcode`),
  KEY `products--category_id--fk` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `price`, `barcode`, `category_id`, `register_date`) VALUES
(2, 'Tomato Paste', 3.00, '6950676209198', 1, '2024-09-22 11:03:45'),
(4, 'Canned Tuna', 3.00, '5285001953387', 1, '2024-09-23 12:09:23'),
(5, 'Rindo', 0.50, '5283023200601', 1, '2024-10-14 10:13:04'),
(7, 'Copy Book', 1.00, '5283001509528', 7, '2024-10-14 10:14:42'),
(8, 'Cheese', 5.00, '6952497504513', 1, '2024-12-20 10:03:55'),
(11, 'Peanuts', 10.00, '5283007434053', 2, '2024-12-25 09:15:08'),
(13, 'Chewing Gum', 0.60, '42112907', 1, '2024-12-25 09:36:18'),
(14, 'Water', 0.40, '6952497504515', 1, '2024-12-25 10:01:13'),
(17, 'b', 5.00, '3', 2, '2025-01-01 10:32:43');

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
  `id` int NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`id`, `total_amount`, `date`) VALUES
(95528, 16.00, '2024-12-20 10:25:49'),
(124931, 15.00, '2024-12-24 11:54:40'),
(173737, 15.00, '2024-12-24 11:47:19'),
(181050, 16.00, '2024-12-20 10:06:26'),
(443283, 10.00, '2025-01-01 10:33:35'),
(563352, 20.00, '2024-12-20 10:05:01'),
(651726, 26.00, '2024-12-22 08:26:50'),
(682134, 5.00, '2024-12-20 10:04:25'),
(758226, 15.00, '2024-12-25 09:30:13'),
(785719, 15.00, '2024-12-24 12:00:03'),
(954482, 3.00, '2024-12-14 12:21:56'),
(958054, 15.00, '2024-12-24 11:55:50'),
(989996, 15.00, '2024-12-24 11:59:12');

-- --------------------------------------------------------

--
-- Table structure for table `sales_items`
--

DROP TABLE IF EXISTS `sales_items`;
CREATE TABLE IF NOT EXISTS `sales_items` (
  `sale_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`sale_id`,`product_id`),
  KEY `sales_items--product_id--index` (`product_id`),
  KEY `sales_items--sale_id--index` (`sale_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sales_items`
--

INSERT INTO `sales_items` (`sale_id`, `product_id`, `quantity`, `price`) VALUES
(95528, 2, 2, 3.00),
(95528, 8, 2, 5.00),
(124931, 8, 3, 5.00),
(173737, 8, 3, 5.00),
(181050, 2, 2, 3.00),
(181050, 8, 2, 5.00),
(443283, 8, 2, 5.00),
(563352, 8, 4, 5.00),
(651726, 2, 2, 3.00),
(651726, 8, 4, 5.00),
(682134, 8, 1, 5.00),
(758226, 8, 3, 5.00),
(785719, 8, 3, 5.00),
(954482, 2, 1, 3.00),
(958054, 8, 3, 5.00),
(989996, 8, 3, 5.00);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products--category_id--fk` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sales_items`
--
ALTER TABLE `sales_items`
  ADD CONSTRAINT `sales_items--product_id--fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sales_items--sale_id--fk` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
