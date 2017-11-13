###############################################################################
## OCSINVENTORY-NG
## Copyleft Gilles Dubois 2017
## Web : http://www.ocsinventory-ng.org
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################

package Ocsinventory::Agent::Modules::Vcloud;

# use
use LWP::UserAgent;
use XML::Simple;

# Auth
my @auth_hashes = (
    {
       URL  => "MY_VCLOUD_SERVER",
       AUTH_DIG     => "DIGEST",
    },
  );

# Configuration
my $server_url = "";
my $session_id = "";
my $auth_digest = "";
my $auth_return;
my $api_filter;

# sub routines var
my $server_endpoint;
my $restpath;
my $auth_dig;
my $lwp_useragent;
my $resp;
my $req;
my $message;

# VmWare references api hash
my %vmware_api_references = (
    "vcloud_login" => "api/sessions",
    "vcloud_orgs" =>  "api/admin/orgs/query",
    "vcloud_networks" => "api/admin/extension/orgNetworks/query",
    "vcloud_vdc" =>  "api/admin/extension/orgVdcs/query",
    "vcloud_vapp" =>  "api/admin/extension/vapps/query",
    "vcloud_vm" =>  "api/query?type=adminVM",
);

sub new {

   my $name="vcloud";   # Name of the module

   my (undef,$context) = @_;
   my $self = {};

   #Create a special logger for the module
   $self->{logger} = new Ocsinventory::Logger ({
            config => $context->{config}
   });

   $self->{logger}->{header}="[$name]";

   $self->{context}=$context;

   $self->{structure}= {
                        name => $name,
                        start_handler => undef,    #or undef if don't use this hook
                        prolog_writer => undef,    #or undef if don't use this hook
                        prolog_reader => undef,    #or undef if don't use this hook
                        inventory_handler => $name."_inventory_handler",    #or undef if don't use this hook
                        end_handler => undef    #or undef if don't use this hook
   };

   bless $self;
}

######### Hook methods ############

sub vcloud_inventory_handler {

  my $self = shift;
  my $logger = $self->{logger};

  my $common = $self->{context}->{common};

  # Processing part
  my $org_infos;
  my $vdc_infos;
  my $vdc_org_infos;
  my $vapps_infos;
  my $vapps_org_infos;
  my $networks_infos;
  my $vms_infos;

  # Debug log for inventory
  $logger->debug("Starting VMWare Vcloud inventory plugin");

  foreach (@auth_hashes){

      # Get auth informations
      $server_url = $_->{'URL'};
      $auth_digest = $_->{'AUTH_DIG'};

      # Get Auth Token
      $session_id = send_auth_api_query($server_url, $vmware_api_references{"vcloud_login"}, $auth_digest);
      $logger->debug("VCloud Auth token has been provided");

      # Get organisations
      $org_infos = send_api_query($server_url, $vmware_api_references{"vcloud_orgs"}, $session_id, 1);
      $it_number = get_page_iteration_number($org_infos->{'pageSize'},$org_infos->{'total'});
      for( $a = 1; $a < $it_number; $a = $a + 1 ){
        $org_infos = send_api_query($server_url, $vmware_api_references{"vcloud_orgs"}, $session_id, $a);
        foreach (keys %{$org_infos->{'OrgRecord'}}){
          $logger->debug("Processing Organization : ".$_);
          # Add XML
          push @{$common->{xmltags}->{VMWARE_VCLOUD}},
          {
             IDVCLOUD => [$_],
             NAME => [$org_infos->{'OrgRecord'}->{$_}->{'displayName'}],
             CAN_PUBLISH_CATALOGS => [$org_infos->{'OrgRecord'}->{$_}->{'canPublishCatalogs'}],
             VAPP_NUMBER => [$org_infos->{'OrgRecord'}->{$_}->{'numberOfVApps'}],
             ISENABLED => [$org_infos->{'OrgRecord'}->{$_}->{'isEnabled'}],
             GROUP_NUMBER => [$org_infos->{'OrgRecord'}->{$_}->{'numberOfGroups'}],
             RUNNING_VM_NUMBER => [$org_infos->{'OrgRecord'}->{$_}->{'numberOfRunningVMs'}],
             CATALOG_NUMBER => [$org_infos->{'OrgRecord'}->{$_}->{'numberOfCatalogs'}],
             VDCS_NUMBER => [$org_infos->{'OrgRecord'}->{$_}->{'numberOfVdcs'}],
             READ_ONLY => [$org_infos->{'OrgRecord'}->{$_}->{'isReadOnly'}],
          };
        }
      }


      # Get VDC
      $vdc_infos = send_api_query($server_url, $vmware_api_references{"vcloud_vdc"}, $session_id, 1);
      $it_number = get_page_iteration_number($vdc_infos->{'pageSize'},$vdc_infos->{'total'});
      for( $a = 1; $a < $it_number; $a = $a + 1 ){
        $vdc_infos = send_api_query($server_url, $vmware_api_references{"vcloud_vdc"}, $session_id, $a);
        foreach (keys %{$vdc_infos->{'AdminVdcRecord'}}){
          $logger->debug("Processing VDC : ".$_);
          $vdc_org_infos = send_api_query($vdc_infos->{'AdminVdcRecord'}->{$_}->{'org'}, "", $session_id, 1);
          # Add XML
          push @{$common->{xmltags}->{VMWARE_VCLOUD_VDC}},
          {
             IDVDC =>[$_],
             ORG_NAME => [$vdc_org_infos->{'name'}],
             VC_NAME => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'vcName'}],
             PROVIDER_VDC_NAME => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'providerVdcName'}],
             IS_SYSTEM_VDC => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'isSystemVdc'}],
             IS_VC_ENABLED => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'isVCEnabled'}],
             IS_ENABLED => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'isEnabled'}],
             STATUS => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'status'}],
             IS_BUSY => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'isBudy'}],
             TASK_STATUS => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'taskStatus'}],
             TASK_STATUS_NAME => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'taskStatusName'}],
             TASK_DETAILS => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'taskDetails'}],
             MEMORY_RESERVED => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'memoryReservedMB'}],
             CPU_RESERVED => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'cpuReservedMhz'}],
             STORAGE_LIMIT => [$vdc_infos->{'AdminVdcRecord'}->{$_}->{'storageLimitMB'}],
          };
        }
      }


      # Get networks
      $networks_infos = send_api_query($server_url, $vmware_api_references{"vcloud_networks"}, $session_id, 1);
      $it_number = get_page_iteration_number($networks_infos->{'pageSize'},$networks_infos->{'total'});
      for( $a = 1; $a < $it_number; $a = $a + 1 ){
        $networks_infos = send_api_query($server_url, $vmware_api_references{"vcloud_networks"}, $session_id, $a);
        foreach (keys %{$networks_infos->{'AdminOrgNetworkRecord'}}){
          $logger->debug("Processing Network : ".$_);
          # Add XML
          push @{$common->{xmltags}->{VMWARE_VCLOUD_NETWORK}},
          {
             IDNETWORK =>[$_],
             ORG_NAME => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'orgName'}],
             PROVIDER_VDC_NAME => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'providerVdcName'}],
             POOL_NAME => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'networkPoolName'}],
             IS_LINKED => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'isLinked'}],
             IS_BUSY => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'isBusy'}],
             NETMASK => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'netmask'}],
             DNS_ONE => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'dns1'}],
             DNS_TWO => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'dns2'}],
             GATEWAY => [$networks_infos->{'AdminOrgNetworkRecord'}->{$_}->{'gateway'}],
          };
        }
      }


      # Get vapps
      $vapps_infos = send_api_query($server_url, $vmware_api_references{"vcloud_vapp"}, $session_id, 1);
      $it_number = get_page_iteration_number($vapps_infos->{'pageSize'},$vapps_infos->{'total'});
      $logger->debug("VApp page length : ".$vapps_infos->{'pageSize'});
      $logger->debug("VApp number : ".$vapps_infos->{'total'});
      $logger->debug("VApp Iteration number : ".$it_number);
      for( $a = 1; $a < $it_number; $a = $a + 1 ){
        $vapps_infos = send_api_query($server_url, $vmware_api_references{"vcloud_vapp"}, $session_id, $a);
        foreach (keys %{$vapps_infos->{'AdminVAppRecord'}}){
          $logger->debug("Processing VApp : ".$_);
          $vapps_org_infos = send_api_query($vapps_infos->{'AdminVAppRecord'}->{$_}->{'org'}, "", $session_id, 1);
          # Add XML
          push @{$common->{xmltags}->{VMWARE_VCLOUD_VAPP}},
          {
             IDVAPP =>[$_],
             ORG_NAME => [$vapps_org_infos->{'name'}],
             STATUS => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'status'}],
             LOWEST_HARDWARE_VERSION => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'lowestHardwareVersionInVApp'}],
             VM_NUMBER => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'numberOfVMs'}],
             IS_ENABLED => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'isEnabled'}],
             IS_DEPLOYED => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'isDeployed'}],
             VDC_NAME => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'vdcName'}],
             MEMORY_ALLOCATION => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'memoryAllocationMB'}],
             CPU_ALLOCATION => [$vapps_infos->{'AdminVAppRecord'}->{$_}->{'cpuAllocationInMhz'}],
          };
        }
      }

      # Get VMs
      $vms_infos = send_api_query($server_url, $vmware_api_references{"vcloud_vm"}, $session_id, 1);
      $it_number = get_page_iteration_number($vms_infos->{'pageSize'},$vms_infos->{'total'});
      $logger->debug("VM number to process : ".$vms_infos->{'total'});
      for( $a = 1; $a < $it_number; $a = $a + 1 ){
        $vms_infos = send_api_query($server_url, $vmware_api_references{"vcloud_vm"}, $session_id, $a);
        foreach (keys %{$vms_infos->{'AdminVMRecord'}}){
          $logger->debug("Processing VM : ".$_);
          # Add XML
          push @{$common->{xmltags}->{VMWARE_VCLOUD_VM}},
          {
             IDVM =>[$_],
             REF => [$vms_infos->{'AdminVMRecord'}->{$_}->{'moref'}],
             STATUS => [$vms_infos->{'AdminVMRecord'}->{$_}->{'status'}],
             HARDWARE_VERSION => [$vms_infos->{'AdminVMRecord'}->{$_}->{'hardwareVersion'}],
             VM_TOOLS_VERSION => [$vms_infos->{'AdminVMRecord'}->{$_}->{'vmToolsVersion'}],
             MEMORY => [$vms_infos->{'AdminVMRecord'}->{$_}->{'memoryMB'}],
             DATASTORE_NAME => [$vms_infos->{'AdminVMRecord'}->{$_}->{'datastoreName'}],
             CONTAINER_NAME => [$vms_infos->{'AdminVMRecord'}->{$_}->{'containerName'}],
             OS => [$vms_infos->{'AdminVMRecord'}->{$_}->{'guestOs'}],
             HOSTNAME => [$vms_infos->{'AdminVMRecord'}->{$_}->{'hostName'}],
             NETWORK => [$vms_infos->{'AdminVMRecord'}->{$_}->{'networkName'}],
          };
        }
      }

  }

}

sub get_page_iteration_number
{

    # Get passed arguments
    ($page_size, $total) = @_;

    if($page_size > $total){
      return 2;
    }else{
      return $total / $page_size + 1;
    }

}

# Auth to the vmware server
sub send_auth_api_query
{
  # Get passed arguments
  ($server_endpoint, $restpath, $auth_dig) = @_;

  $lwp_useragent = LWP::UserAgent->new;

  # set custom HTTP request header fields
  $req = HTTP::Request->new(POST => $server_endpoint . $restpath);
  $req->header('authorization' => "Basic $auth_dig");
  $req->header('cache-control' => 'no-cache');
  $req->header('accept' => 'application/*+xml;version=1.5');

  # Disable SSL Verify hostname
  $lwp_useragent->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);

  $resp = $lwp_useragent->request($req);
  if ($resp->is_success) {
      # return vmware api token
      my $data = $resp->{'_headers'}->{'x-vcloud-authorization'};
      return $data;
  }
  else {
      return $resp->message;
  }
}

# Query api and return the json decoded
sub send_api_query
{

  # Page number
  my $page_number;

  # Get passed arguments
  ($server_endpoint, $restpath, $session_id, $page_number) = @_;

  $lwp_useragent = LWP::UserAgent->new;

  # set custom HTTP request header fields
  if (index($restpath, "?") != -1) {
    $req = HTTP::Request->new(GET => $server_endpoint . $restpath . "&pageSize=128&page=" . $page_number);
  } else{
    $req = HTTP::Request->new(GET => $server_endpoint . $restpath . "?pageSize=128&page=" . $page_number);
  }
  $req->header('accept' => 'application/*+xml;version=1.5');
  $req->header('cache-control' => 'no-cache');
  $req->header('x-vcloud-authorization' => $session_id);

  # Disable SSL Verify hostname
  $lwp_useragent->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);

  $resp = $lwp_useragent->request($req);
  if ($resp->is_success) {
      $message = $resp->decoded_content;

      my $data = XMLin($message);
      return $data;
  }
  else {
      return $resp->message;
  }
}
