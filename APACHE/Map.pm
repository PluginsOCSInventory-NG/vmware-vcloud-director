###############################################################################
## OCSINVENTORY-NG
## Copyleft Gilles Dubois 2017
## Web : http://www.ocsinventory-ng.org
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################

package Apache::Ocsinventory::Plugins::Vmware_Vcloud_Director::Map;

use strict;

use Apache::Ocsinventory::Map;

$DATA_MAP{VMWARE_VCLOUD} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'IDVCLOUD',
    writeDiff => 0,
    cache => 0,
    fields => {
      IDVCLOUD => {},
      NAME => {},
      CAN_PUBLISH_CATALOGS => {},
      VAPP_NUMBER => {},
      ISENABLED => {},
      GROUP_NUMBER => {},
      RUNNING_VM_NUMBER => {},
      CATALOG_NUMBER => {},
      VDCS_NUMBER => {},
      READ_ONLY => {}
    }
  };

$DATA_MAP{VMWARE_VCLOUD_VDC} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'IDVDC',
    writeDiff => 0,
    cache => 0,
    fields => {
      IDVDC => {},
      ORG_NAME => {},
      VC_NAME => {},
      PROVIDER_VDC_NAME => {},
      IS_SYSTEM_VDC => {},
      IS_VC_ENABLED => {},
      IS_ENABLED => {},
      STATUS => {},
      IS_BUSY => {},
      TASK_STATUS => {},
      TASK_STATUS_NAME => {},
      TASK_DETAILS => {},
      MEMORY_RESERVED => {},
      CPU_RESERVED => {},
      STORAGE_LIMIT => {}
    }
  };

$DATA_MAP{VMWARE_VCLOUD_NETWORK} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'IDNETWORK',
    writeDiff => 0,
    cache => 0,
    fields => {
      IDNETWORK => {},
      ORG_NAME => {},
      PROVIDER_VDC_NAME => {},
      POOL_NAME => {},
      IS_LINKED => {},
      IS_BUSY => {},
      NETMASK => {},
      DNS_ONE => {},
      DNS_TWO => {},
      GATEWAY => {}
    }
  };

$DATA_MAP{VMWARE_VCLOUD_VAPP} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'IDVAPP',
    writeDiff => 0,
    cache => 0,
    fields => {
      IDVAPP => {},
      ORG_NAME => {},
      STATUS => {},
      LOWEST_HARDWARE_VERSION => {},
      VM_NUMBER => {},
      IS_ENABLED => {},
      IS_DEPLOYED => {},
      VDC_NAME => {},
      MEMORY_ALLOCATION => {},
      CPU_ALLOCATION => {}
    }
  };

$DATA_MAP{VMWARE_VCLOUD_VM} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'IDVM',
    writeDiff => 0,
    cache => 0,
    fields => {
      IDVM => {},
      REF => {},
      STATUS => {},
      HARDWARE_VERSION => {},
      VM_TOOLS_VERSION => {},
      MEMORY => {},
      DATASTORE_NAME => {},
      CONTAINER_NAME => {},
      OS => {},
      HOSTNAME => {},
      NETWORK => {}
    }
  };

1;
