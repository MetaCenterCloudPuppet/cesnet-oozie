#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with oozie](#setup)
    * [What oozie affects](#what-oozie-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oozie](#beginning-with-oozie)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="overview"></a>
## Overview

Oozie module installs Oozie server or client, optionally with enabled security.

<a name="module-description"></a>
## Module Description

This module install Oozie server or client with optional features:

* security based on Kerberos
* HTTPS

Supported are:

* Debian 7/wheezy (tested on Hadoop 2.5.0)

<a name="setup"></a>
## Setup

<a name="what-oozie-affects"></a>
### What oozie affects

* Packages: client and server packages can be installed
* Alternatives:
 * alternatives are used for */etc/oozie/conf* in Debian (Cloudera); This module switches to the new alternative by default, so the Cloudera original configuration can be kept intact.
 * alternatives are used between http/https for */etc/oozie/tomcat-conf*
* Files modified:
 * */etc/oozie/conf.\**
 * */var/lib/oozie/ext-2.2*: *ext-2.2.zip* is downloadd and extracted to */var/lib/oozie*. If the file is already available locally at */var/lib/oozie/ext-2.2.zip* (or the directory */var/lib/oozie/ext-2.2* already exists), the file is not downloaded.
 * */var/lib/oozie/\*.jar*: JDBC files are copied from */usr/share/java* according to configured database type in *db* parameter
 * */etc/profile.d/oozie.\**: created for client by default
* (TODO) Database schema imported: according to the selected database type
* Services:
 * *oozie*
* Helper Files: */var/lib/oozie/.puppet-oozie-setup*, */var/lib/hadoop-hdfs/.puppet-oozie-dir-created*
* Secret Files (keytabs, certificates): some files are copied to oozi home directory */var/lib/oozie*
* HDFS directory and its content: */user/oozie*

<a name="setup-requirements"></a>
### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories** - see cesnet-hadoop module Setup Requirements for details

* **Secure mode**: keytabs must be prepared in /etc/security/keytabs/ (see *realm* parameter)

* **HTTPS**: keystore must be prepared in *https\_keystore*

<a name="beginning-with-oozie"></a>
### Beginning with oozie

Basic example without security: configured Hadoop cluster without security is needed.

    hdfs_hostname=...
    
    class{'oozie':
      defaultFS => "hdfs://${hdfs_hostname}:8020",
      realm     => '',
    }
    
    node default {
      include oozie::server
      include oozie::client
      include oozie::hdfs
    }

<a name="usage"></a>
## Usage

<a name="security"></a>
### Security

You will also need to add permissions for Oozie to Hadoop. Optionally also HTTPS can be enabled.

**Example**:

    class{'hadoop':
      ...

      properties => {
        ...
        'hadoop.proxyuser.oozie.groups' => '*',
        'hadoop.proxyuser.oozie.hosts'  => '*',
      },

      ...
    }

    hdfs_hostname=...

    class{'oozie':
      ...
      https     => true,
      https_keystore_password => 'changeit',
      realm     => 'MY.REALM',
    }

Note: the class *oozie::hdfs* creates the directory on HDFS. With enabled security, it must be included at HDFS namenode, or additional namenode keytab must exists.

Note 2: You can consider modify or remove *oozie.authentication.kerberos.name.rules*. The default value is needed when using cross-realm authentization:

    properties => {
      'oozie.authentication.kerberos.name.rules' => '::undef',
    }

<a name="parameters"></a>
### Parameters

####`db` *derby*

Database type. Values can be *derby*, *mysql*, *postgres*, or *oracle*.

TODO: only Derby supported for now

####`db_host` *localhost*

Database host.

####`db_name` *oozie*

Database name.

####`db_user` *oozie*

Database user.

####`db_password` (space)

Database password. Oozie will need a space, when using empty password.

####`defaultFS` *hdfs://${hdfs\_hostname}:8020*

Hadoop URI. Used hdfs://${hdfs\_hostname}:8020, if not specified.

####`environment` true

Define environment variable OOZIE\_URL on clients.

####`hdfs_hostname` *localhost*

Hadoop namenode. Not needed, you can use *defautFS* instead.

####`https` *false*

Enable HTTPS.

####`https_keystore` '/etc/security/server.keystore'

Certificates keystore file.

####`https_keystore_password` 'changeit'

Certificates keystore file password.

####`realm` (required)

Kerberos realm. Empty string, if the security is disabled.


<a name="reference"></a>
## Reference

<a name="classes"></a>
###Classes

* **client**: Oozie Client
 * config
 * install
* common:
 * config
 * postinstall
* **server**: Oozie Server
 * config
 * install
 * service
* **hdfs**: HDFS Initializations
* init
* params

<a name="limitations"></a>
## Limitations

See [Setup Requirements](#setup-requirements) section.

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-oozie](https://github.com/MetaCenterCloudPuppet/cesnet-oozie)
* Testing: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
