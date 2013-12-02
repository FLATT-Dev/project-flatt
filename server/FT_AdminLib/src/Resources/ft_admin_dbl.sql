SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS `ft_admin_db` ;
CREATE SCHEMA IF NOT EXISTS `ft_admin_db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `ft_admin_db` ;

-- -----------------------------------------------------
-- Table `ft_admin_db`.`History`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`History` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`History` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `action_id` INT NOT NULL ,
  `state_id` INT NOT NULL default 1,
  `result_id` INT NOT NULL default 1 ,
  `host_id` INT  ,
  `hostgrp_id` INT ,
  `desc` TEXT ,
  `start` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `end` DATETIME  ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ft_admin_db`.`State`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`State` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`State` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NOT NULL ,
  `description` TEXT ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ft_admin_db`.`Action`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`Action` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`Action` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `guid` VARCHAR(255) NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  `version` VARCHAR(255) NOT NULL DEFAULT '1',
  `is_task` TINYINT(1) NOT NULL DEFAULT false ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ft_admin_db`.`Host`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`Host` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`Host` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `address` TEXT NOT NULL ,
  `permissions_id` INT DEFAULT 0,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ft_admin_db`.`Users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`User` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`User` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` varchar(255) NOT NULL default '' ,
  `permissions_id` INT NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ft_admin_db`.`HostGroup`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`HostGroup` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`HostGroup` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NOT NULL ,
  `username` VARCHAR(255) NOT NULL ,
  `password` VARCHAR(255) ,
  `ssh_key` VARCHAR(255) ,
  `permissions_id` INT NOT NULL DEFAULT 0 ,
   `host_ids` TEXT ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ft_admin_db`.`Permissions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`Permissions` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`Permissions` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NOT NULL ,
  `description` TEXT ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ft_admin_db`.`Result`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ft_admin_db`.`Result` ;

CREATE  TABLE IF NOT EXISTS `ft_admin_db`.`Result` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NOT NULL ,
  `description` TEXT ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


USE `ft_admin_db` ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

INSERT INTO `ft_admin_db`.`permissions` (`name`, `description`) VALUES ('Level0', 'Unlimited permissions');
INSERT INTO `ft_admin_db`.`permissions` (`name`, `description`) VALUES ('Level1', 'Level 1 permissions');
INSERT INTO `ft_admin_db`.`permissions` (`name`, `description`) VALUES ('Level2', 'Level 2 permissions');

INSERT INTO `ft_admin_db`.`state` (`name`, `description`) VALUES ('In Progress', 'Action execution in progress');
INSERT INTO `ft_admin_db`.`state` (`name`, `description`) VALUES ('Completed', 'Action execution completed');
INSERT INTO `ft_admin_db`.`state` (`name`, `description`) VALUES ('Paused', 'Action execution paused');
INSERT INTO `ft_admin_db`.`state` (`name`, `description`) VALUES ('Canceled', 'Action execution canceled');


INSERT INTO `ft_admin_db`.`result` (`name`, `description`) VALUES ('OK', 'Success');
INSERT INTO `ft_admin_db`.`result` (`name`, `description`) VALUES ('Error', 'Error');



