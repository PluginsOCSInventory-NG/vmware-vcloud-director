# Plugin VMWare VCloud director

<p align="center">
  <img src="https://cdn.ocsinventory-ng.org/common/banners/banner660px.png" height=300 width=660 alt="Banner">
</p>

<h1 align="center">Plugin VMWare VCloud director</h1>
<p align="center">
  <b>Some Links:</b><br>
  <a href="http://ask.ocsinventory-ng.org">Ask question</a> |
  <a href="https://www.ocsinventory-ng.org/?utm_source=github-ocs">Website</a> |
  <a href="https://www.ocsinventory-ng.org/en/#ocs-pro-en">OCS Professional</a>
</p>

## Description

This plugin is made to retrieve all VCloud Director informations using the REST api from VCloud Director.
Link : https://www.vmware.com/support/vcd/doc/rest-api-doc-1.5-html/

*NOTE : This plugin still not have any visual representation of inventoried data (WIP)*

## Prerequisite

*The following configuration need to be installed on your VCloud director :*
1. VCloud director 5.1 and newer
2. A user with read rights on the API and on head organization (system)

*The following OCS configuration need to be installed :*
1. Unix agent 2.3 and newer
2. OCS Inventory 2.3.X recommended

*The following dependencies need to be installed on agent :*
1. LWP::UserAgent
2. XML::Simple

## Used API routes

This following routes are used by the API :
- myvcloudserver/api/sessions
- myvcloudserver/api/admin/orgs/query
- myvcloudserver/api/admin/extension/orgNetworks/query
- myvcloudserver/api/admin/extension/orgVdcs/query
- myvcloudserver/api/admin/extension/vapps/query
- myvcloudserver/api/query?type=adminVM

## Configuration

To configure a new server to scan you need to edit the Vcloud.pm file.

See here for more informations on API logging here :
- https://pubs.vmware.com/vca/index.jsp?topic=%2Fcom.vmware.vcloud.api.doc_56%2FGUID-6DC15CF5-3BCF-4426-9988-C71E7A71CBD6.html

Line 18 :  
```
my @auth_hashes = (
    {
       URL  => "MY_FIRST_VCLOUD_SERVER",
       AUTH_DIG     => "user@organization:password in base 64",
    },
);
```

You need to change the URL to your VCloud server url / ip and set the AUTH_DIG to user + pass encoded in base 64

If you have more than one server you need to add the following line below the last URL + AUTH_DIG values :

```
    {
       URL  => "MY_SECOND_VCLOUD_SERVER",
       AUTH_DIG     => "user@organization:password in base 64",
    },
```

*Note : there is no limit on server number*

## Todo

1. Add GUI representations for inventoried data in ocsreports
