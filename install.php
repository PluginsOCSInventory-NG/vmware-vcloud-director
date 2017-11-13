<?php
/*
 * Copyright 2005-2016 OCSInventory-NG/OCSInventory-ocsreports contributors.
 * See the Contributors file for more details about them.
 *
 * This file is part of OCSInventory-NG/OCSInventory-ocsreports.
 *
 * OCSInventory-NG/OCSInventory-ocsreports is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 2 of the License,
 * or (at your option) any later version.
 *
 * OCSInventory-NG/OCSInventory-ocsreports is distributed in the hope that it
 * will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with OCSInventory-NG/OCSInventory-ocsreports. if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

function plugin_version_vcloud()
{
return array('name' => 'VCloud inventory',
'version' => '1.0',
'author'=> 'Gilles Dubois',
'license' => 'GPLv2',
'verMinOcs' => '2.3');
}

function plugin_init_vcloud()
{

$object = new plugins;

// VMWARE Vcloud table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VMWARE_VCLOUD` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `IDVCLOUD` VARCHAR(255) DEFAULT NULL,
                      `CAN_PUBLISH_CATALOGS` VARCHAR(255) DEFAULT NULL,
                      `CATALOG_NUMBER` VARCHAR(255) DEFAULT NULL,
                      `GROUP_NUMBER` VARCHAR(255) DEFAULT NULL,
                      `ISENABLED` VARCHAR(255) DEFAULT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `READ_ONLY` VARCHAR(255) DEFAULT NULL,
                      `RUNNING_VM_NUMBER` VARCHAR(255) DEFAULT NULL,
                      `VAPP_NUMBER` VARCHAR(255) DEFAULT NULL,
                      `VDCS_NUMBER` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// VMWARE Vcloud vdc
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VMWARE_VCLOUD_VDC` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `IDVDC` VARCHAR(255) DEFAULT NULL,
                      `CPU_RESERVED` VARCHAR(255) DEFAULT NULL,
                      `IS_BUSY` VARCHAR(255) DEFAULT NULL,
                      `IS_ENABLED` VARCHAR(255) DEFAULT NULL,
                      `IS_SYSTEM_VDC` VARCHAR(255) DEFAULT NULL,
                      `IS_VC_ENABLED` VARCHAR(255) DEFAULT NULL,
                      `MEMORY_RESERVED` VARCHAR(255) DEFAULT NULL,
                      `ORG_NAME` VARCHAR(255) DEFAULT NULL,
                      `PROVIDER_VDC_NAME` VARCHAR(255) DEFAULT NULL,
                      `STATUS` VARCHAR(255) DEFAULT NULL,
                      `STORAGE_LIMIT` VARCHAR(255) DEFAULT NULL,
                      `TASK_DETAILS` VARCHAR(255) DEFAULT NULL,
                      `TASK_STATUS` VARCHAR(255) DEFAULT NULL,
                      `TASK_STATUS_NAME` VARCHAR(255) DEFAULT NULL,
                      `VC_NAME` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// VMWARE Vcloud networks
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VMWARE_VCLOUD_NETWORK` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `IDNETWORK` VARCHAR(255) DEFAULT NULL,
                      `DNS_ONE` VARCHAR(255) DEFAULT NULL,
                      `DNS_TWO` VARCHAR(255) DEFAULT NULL,
                      `GATEWAY` VARCHAR(255) DEFAULT NULL,
                      `IS_BUSY` VARCHAR(255) DEFAULT NULL,
                      `IS_LINKED` VARCHAR(255) DEFAULT NULL,
                      `NETMASK` VARCHAR(255) DEFAULT NULL,
                      `ORG_NAME` VARCHAR(255) DEFAULT NULL,
                      `POOL_NAME` VARCHAR(255) DEFAULT NULL,
                      `PROVIDER_VDC_NAME` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// VMWARE Vcloud VAPPS
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VMWARE_VCLOUD_VAPP` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `IDVAPP` VARCHAR(255) DEFAULT NULL,
                      `CPU_ALLOCATION` VARCHAR(255) DEFAULT NULL,
                      `MEMORY_ALLOCATION` VARCHAR(255) DEFAULT NULL,
                      `STATUS` VARCHAR(255) DEFAULT NULL,
                      `ORG_NAME` VARCHAR(255) DEFAULT NULL,
                      `VDC_NAME` VARCHAR(255) DEFAULT NULL,
                      `VM_NUMBER` VARCHAR(255) DEFAULT NULL,
                      `LOWEST_HARDWARE_VERSION` VARCHAR(255) DEFAULT NULL,
                      `IS_ENABLED` VARCHAR(255) DEFAULT NULL,
                      `IS_DEPLOYED` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// VMWARE Vcloud VM
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VMWARE_VCLOUD_VM` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `IDVM` VARCHAR(255) DEFAULT NULL,
                      `HOSTNAME` VARCHAR(255) DEFAULT NULL,
                      `DATASTORE_NAME` VARCHAR(255) DEFAULT NULL,
                      `CONTAINER_NAME` VARCHAR(255) DEFAULT NULL,
                      `NETWORK` VARCHAR(255) DEFAULT NULL,
                      `OS` VARCHAR(255) DEFAULT NULL,
                      `REF` VARCHAR(255) DEFAULT NULL,
                      `STATUS` VARCHAR(255) DEFAULT NULL,
                      `MEMORY` VARCHAR(255) DEFAULT NULL,
                      `HARDWARE_VERSION` VARCHAR(255) DEFAULT NULL,
                      `VM_TOOLS_VERSION` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

}

function plugin_delete_vcloud()
{

$object = new plugins;
// VMWARE Vcloud table
$object -> sql_query("DROP TABLE `VMWARE_VCLOUD`;");
$object -> sql_query("DROP TABLE `VMWARE_VCLOUD_VDC`;");
$object -> sql_query("DROP TABLE `VMWARE_VCLOUD_NETWORK`;");
$object -> sql_query("DROP TABLE `VMWARE_VCLOUD_VAPP`;");
$object -> sql_query("DROP TABLE `VMWARE_VCLOUD_VM`;");

}
