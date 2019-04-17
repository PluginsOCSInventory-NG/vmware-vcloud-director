<?php
/*
 * Copyright 2005-2017 PluginsOCSInventory-NG/vmware-vcloud-director contributors.
 * See the Contributors file for more details about them.
 *
 * This file is part of PluginsOCSInventory-NG/vmware-vcloud-director.
 *
 * PluginsOCSInventory-NG/vmware-vcloud-director is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * PluginsOCSInventory-NG/vvmware-vcloud-director is distributed in the hope that it
 * will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PluginsOCSInventory-NG/vmware-vcenter. if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

 /**
  * This class will show a detailed view of what's in the VCenter infrastructure
  */
 class VcloudDetails {

  private $tableName = null;
  private $fieldArray = null;

  private $queryRepo = array(
    "SHOW_COLUMNS" => "SHOW COLUMNS FROM %s",
    "SELECT_FROM_TABLE" => "SELECT %s FROM %s"
  );

  public $finalQuery = null;

  public $viewList = array(
    "Vcloud list" => "VMWARE_VCLOUD",
    "Vapp list" => "VMWARE_VCLOUD_VAPP",
    "VM list" => "VMWARE_VCLOUD_VM",
    "Network list" => "VMWARE_VCLOUD_NETWORK",
    "VDC list" => "VMWARE_VCLOUD_VDC",
  );

  public function setTableName($tableName){
    $this->tableName = $tableName;
  }

  public function getTableName(){
    return $this->tableName;
  }

  private function getTableFieldList(){
     $result = mysql2_query_secure($this->queryRepo['SHOW_COLUMNS'], $_SESSION['OCS']["readServer"], $this->tableName);

    if($result != false){
      while($row = $result->fetch_assoc()){
        if($row['Field'] != "HARDWARE_ID"){
           $this->fieldArray[] = $row['Field'];
        }
      }
      return true;
    }else{
      return false;
    }

  }

  private function generateQueryFromFieldList(){
     $fieldList = implode(', ', $this->fieldArray);
     $this->finalQuery =  sprintf($this->queryRepo['SELECT_FROM_TABLE'], $fieldList, $this->tableName);
  }

  private function generateDatatable(){

    $listFields = array();
    foreach ($this->fieldArray as $field) {
      $listFields[$field] = $field;
    }
    $defaultFields = $listFields;

    $listColCantDel = array('ID' => 'ID');

    $tabOptions['form_name'] = $this->tableName;
    $tabOptions['table_name'] = $this->tableName;

    $tableDetails = array();

    $tableDetails["listFields"] = $listFields;
    $tableDetails["defaultFields"] = $defaultFields;
    $tableDetails["tabOptions"] = $tabOptions;
    $tableDetails["listColCantDel"] = $listColCantDel;

    return $tableDetails;

  }

  public function processTable($tabName){
    if(!in_array($tabName, $this->viewList)){
      return false;
    }

    $this->setTableName($tabName);
    if($this->getTableFieldList()){
      $this->generateQueryFromFieldList();
      return($this->generateDatatable());
    }

  }

  public function showVcenterLeftMenu($activeMenu){
    $menuArray = $this->viewList;

    echo '<ul class="nav nav-pills nav-stacked navbar-left">';
    foreach ($menuArray as $key=>$value){

        echo "<li ";
        if ($activeMenu == $value) {
            echo "class='active'";
        }
        echo " ><a href='?function=vcloud&list=".$value."'>".$key."</a></li>";
    }
    echo '</ul>';
  }

 }
