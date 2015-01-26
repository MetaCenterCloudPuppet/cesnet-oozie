#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with oozie](#setup)
    * [What oozie affects](#what-oozie-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oozie](#beginning-with-oozie)
4. [Usage - Configuration options and additional functionality](#usage)
    * [MySQL](#mysql)
    * [PostgreSQL](#postgresql)
    * [Security](#security)
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
 * */var/lib/oozie/ext-2.2*: *ext-2.2.zip* is downloaded and extracted to */var/lib/oozie*. If the file is already available locally at */var/lib/oozie/ext-2.2.zip* (or the directory */var/lib/oozie/ext-2.2* already exists), the file is not downloaded.
 * */var/lib/oozie/\*.jar*: JDBC files are copied from */usr/share/java* according to configured database type in *db* parameter
 * */etc/profile.d/oozie.\**: created for client by default
* Database schema imported: according to the selected database type
* Services:
 * *oozie*
* Helper Files: */var/lib/oozie/.puppet-oozie-setup*, */var/lib/oozie/.puppet-oozie-schema-created*, */var/lib/hadoop-hdfs/.puppet-oozie-dir-created*
* Secret Files (keytabs, certificates): some files are copied to oozie home directory */var/lib/oozie*
* HDFS directory and its content: */user/oozie*

<a name="setup-requirements"></a>
### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories**: see cesnet-hadoop module Setup Requirements for details

* **No Database Setup**: there is no database setup in this module, only the schema is imported. See [Usage](#usage) for examples, how to use cesnet-oozie module with puppetlabs database modules.

* **Secure mode**: keytabs must be prepared in /etc/security/keytabs/ (see *realm* parameter)

* **HTTPS**: HTTP/&lt;HOST&gt; keytab must be available, keystore must be prepared in *https\_keystore*, and signature secret file in */etc/security/http-auth-signature-secret*

* **No inter-node dependencies**

<a name="beginning-with-oozie"></a>
### Beginning with oozie

Basic example without security: configured Hadoop cluster without security is needed. You will also need to add permissions for Oozie to Hadoop.

    hdfs_hostname=...

    class{'hadoop':
      ...

      properties => {
        ...
        'hadoop.proxyuser.oozie.groups' => '*',
        'hadoop.proxyuser.oozie.hosts'  => '*',
      },

      ...
    }

    class{'oozie':
      defaultFS => "hdfs://${hdfs_hostname}:8020",
      realm     => '',
    }

    node default {
      include oozie::server
      include oozie::client
      include oozie::hdfs
    }

Note: The class *oozie::server::config* requires fully working HDFS (the namenode and enough datanodes), and *oozie::hdfs*. But with multi-node cluster puppetdb or other method may be needed for that.

<a name="usage"></a>
## Usage

It is recommended to use real database backend. See following sections [MySQL](#mysql), and [PostgreSQL](#postgresql). If choosing Oracle, you will also need to copy JDBC jar file to */var/lib/oozie*.

Note: When changing database type and creating new schema, the puppet helper file */var/lib/oozie/.puppet-oozie-schema-created* needs to be removed, or you can create the new schema manually:

    su oozie -s /bin/bash
    /usr/lib/oozie/bin/ooziedb.sh create -run

Note 2: You can override any module presets by the properties:

    class{'oozie':
      ...
      properties => {
        'oozie.service.JPAService.jdbc.driver' => 'my.custom.jdbc.Driver',
        'oozie.service.JPAService.jdbc.url' => 'jdbc:mysql://myserver:myport/oozie'
      },
      ...
    }

<a name="mysql"></a>
### MySQL

**Example MySQL**: Oozie with MySQL, using puppetlabs-mysql module:

    class{'oozie':
      ...
      db => 'mysql',
      db_password => 'ooziepassword',
    }

    node ... {
      class { 'mysql::server':
        root_password    => 'strongpassword',
      }

      mysql::db { 'oozie':
        user     => 'oozie',
        password => 'ooziepassword',
        host     => 'localhost',
        grant    => ['CREATE', 'INDEX', 'SELECT', 'INSERT', 'UPDATE', 'DELETE'],
      }

      class { 'mysql::bindings':
        java_enable => true,
      }

      Class['mysql::bindings'] -> Class['oozie::server::config']
      Mysql::Db['oozie'] -> Class['oozie::server::service']
    }

As you can see, MySQL JDBC driver needs to be available for setup class *oozie::server::config* and the database needs to be available for startup class *oozie::server::service*.

<a name="postgresql"></a>
### PostgreSQL

**Example PostgreSQL**: Oozie with PostgreSQL, using puppetlabs-postgresql module:

    class{'oozie':
      ...
      db => 'postgresql',
      db_password => 'ooziepassword',
    }

    node ... {
      class { 'postgresql::server':
        listen_addresses => 'localhost',
      }

      postgresql::server::db { 'oozie':
        user     => 'oozie',
        password => postgresql_password('oozie', 'ooziepassword'),
      }

      include postgresql::lib::java

      Class['postgresql::lib::java'] -> Class['oozie::server::config']
      Postgresql::Server::Db['oozie'] -> Class['oozie::server::service']
    }

As you can see, PostgreSQL JDBC driver needs to be available for setup class *oozie::server::config* and the database needs to be available for startup class *oozie::server::service*.

<a name="security"></a>
### Security

Optionally also HTTPS can be enabled.

Security files must be prepared on proper places (see [Requirements](#requirements)). But there can be used files from Hadoop. Keystore passphrase should not differ from key passphrase.

**Example**:

    class{'oozie':
      ...
      https     => true,
      https_keystore_password => 'changeit',
      realm     => 'MY.REALM',
    }

Note: the class *oozie::hdfs* creates the directory on HDFS. With enabled security, it must be included at HDFS namenode, or additional namenode keytab must exists.

Note 2: You can consider modify or remove *oozie.authentication.kerberos.name.rules*. The default value is needed only when using cross-realm authentication:

    properties => {
      'oozie.authentication.kerberos.name.rules' => '::undef',
    }

<a name="parameters"></a>
### Parameters

####`adminusers` undef

Administrator users.

####`db` *derby*

Database type. Values can be **derby**, **mysql**, **postgresql**, or **oracle**.

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

Hadoop namenode. Not needed, you can use *defaultFS* instead.

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
