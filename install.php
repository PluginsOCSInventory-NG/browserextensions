<?php

/**
 * This function is called on installation and is used to create database schema for the plugin
 */
function extension_install_browserextensions()
{
    $commonObject = new ExtensionCommon;

    $commonObject -> sqlQuery("DROP TABLE `browserextensions`");

    $commonObject -> sqlQuery("CREATE TABLE `browserextensions` (
                              `ID` INT(11) NOT NULL AUTO_INCREMENT,
                              `HARDWARE_ID` INT(11) NOT NULL,
                              `USERNAME` VARCHAR(255) DEFAULT NULL,
                              `BROWSERNAME` VARCHAR(255) DEFAULT NULL,
                              `EXTENSIONNAME` VARCHAR(255) DEFAULT NULL,
                              `EXTENSIONVERSION` VARCHAR(255) DEFAULT NULL,
                              `EXTENSIONID` VARCHAR(255) DEFAULT NULL,
                              PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                            ) ENGINE=INNODB ;");
}

/**
 * This function is called on removal and is used to destroy database schema for the plugin
 */
function extension_delete_browserextensions()
{
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE `browserextensions`");
}

/**
 * This function is called on plugin upgrade
 */
function extension_upgrade_browserextensions()
{

}