## Apache Oozie Puppet Module

[![Build Status](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-oozie.svg?branch=master)](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-oozie) [![Puppet Forge](https://img.shields.io/puppetforge/v/cesnet/oozie.svg)](https://forge.puppetlabs.com/cesnet/oozie)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with oozie](#setup)
    * [What oozie affects](#what-oozie-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oozie](#beginning-with-oozie)
3. [Usage - Configuration options and additional functionality](#usage)
    * [MySQL](#mysql)
    * [PostgreSQL](#postgresql)
    * [Security](#security)
    * [Compatibility](#compatibility)
    * [Cluster with more HDFS Name nodes](#multinn)
    * [Upgrade](#upgrade)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Parameters (oozie class)](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="module-description"></a>
## Module Description

Oozie puppet module installs Oozie server or client, optionally with features:

* security based on Kerberos
* HTTPS

Supported are:

* **Debian 7/wheezy**: Cloudera distribution (tested with CDH 5.4.2, Oozie 4.1.0)
* **Ubuntu 14/trusty**: Cloudera distribution
* **RHEL 6 and clones**: Cloudera distribution (tested with CDH 5.4.2, Oozie 4.1.0)

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
* Databases: for supported databases and when not disabled: user created and database schema imported using puppetlabs modules

<a name="setup-requirements"></a>
### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories**: see cesnet-hadoop module Setup Requirements for details

* **Database setup**: MariaDB/MySQL or PostgreSQL are supported. You need to install puppetlabs-mysql or puppetlabs-postgresql module, because they are not in dependencies.

* **Secure mode**: keytabs must be prepared in /etc/security/keytabs/ (see *realm* parameter)

* **HTTPS**: HTTP/&lt;HOST&gt; keytab must be available, keystore must be prepared in *https\_keystore*, and signature secret file in */etc/security/http-auth-signature-secret*

* **No inter-node dependencies**

<a name="beginning-with-oozie"></a>
### Beginning with oozie

Basic example without security: configured Hadoop cluster without security is needed (at least **defaultFS** or **hdfs_hostname** parameters in hadoop class). You will also need to add permissions for Oozie to Hadoop.

    class{'hadoop':
      hdfs_hostname=...
	  #defaultFS=...
	  ...
      properties => {
        ...
        'hadoop.proxyuser.oozie.groups' => '*',
        'hadoop.proxyuser.oozie.hosts'  => '*',
      },

      ...
    }

    class{'oozie':
      realm     => '',
      version   => '4',
    }

    node default {
      include oozie::server
      include oozie::client
      include oozie::hdfs

      Class['oozie::hdfs'] -> Class['oozie::server::service']
    }

Note: The class *oozie::server::config* requires fully working HDFS (the namenode and enough datanodes), and *oozie::hdfs*. With multi-node cluster it may be needed to separate setup to more stages.

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

**Example MySQL**: Oozie with MySQL, puppetlabs-mysql module must be installed:

Add this to the initial example:

    class{'oozie':
      ...
      db          => 'mysql',
      #db          => 'mariadb',
      db_password => 'ooziepassword',
    }

    node ... {
      class { 'mysql::server':
        root_password => 'strongpassword',
      }

      class { 'mysql::bindings':
        java_enable => true,
        #java_package_name => 'libmariadb-java',
      }
    }

Database is created in *oozie::server::db* (*oozie::server*) class.

<a name="postgresql"></a>
### PostgreSQL

**Example PostgreSQL**: Oozie with PostgreSQL, using puppetlabs-postgresql module:

    class{'oozie':
      ...
      db          => 'postgresql',
      db_password => 'ooziepassword',
    }

    node ... {
      ...
      class { 'postgresql::server':
        listen_addresses => 'localhost',
      }
      include postgresql::lib::java
    }

Database is created in *oozie::server::db* (*oozie::server*) class.

<a name="security"></a>
### Security

Security is enabled by setting Kerberos realm in *realm* parameter. Optionally also HTTPS can be enabled.

Security files must be prepared on proper places (see [Requirements](#requirements)). But there can be used files from Hadoop. Keystore passphrase can't differ from the key passphrase inside the store.

**Example**:

    class{'oozie':
      ...
      https                   => true,
      https_keystore_password => 'changeit',
      realm                   => 'MY.REALM',
    }

Note: the class *oozie::hdfs* creates the directory on HDFS. With enabled security, it must be included at HDFS namenode (or the class must be launched on the machine with the HDFS service admin keytab).

Note 2: You can consider modify or remove *oozie.authentication.kerberos.name.rules*. The default value is needed only when using cross-realm authentication:

    properties => {
      'oozie.authentication.kerberos.name.rules' => '::undef',
    }

<a name="cross-realm"></a>
#### Cross-realm

Cross-realm environment is problematic, see issue [OOZIE-2704](https://issues.apache.org/jira/browse/OOZIE-2704).

Workarounds are possible:

* setup

The *krb5.conf* file must be modified temporarily so the default realm match the realm of *oozie/HOSTNAME* principal. Then you must launch setup manually (and mark it for *oozie* puppet module as done):

    #defaultfs='hdfs://....'
    oozie-setup sharelib create -fs $defaultfs -locallib /usr/lib/oozie/oozie-sharelib-yarn
    touch /var/lib/oozie/.puppet-oozie-setup

* runtime

Link */etc/hadoop/conf/core-site.xml* file to tomcat lib directory. For example:

    ln -s /etc/hadoop/conf/core-site.xml /usr/lib/bigtop-tomcat/lib/

This is already done by *site_hadoop* CESNET puppet module.

<a name="compatibility"></a>
#### Compatibility

For using with older versions of Cloudera (like CDH 5.3.1 / Oozie 4.0.0), you need to change parameters *alternatives_ssl* and *oozie_sharelib*. Defaults values are tested with CDH 5.4.2 / Oozie 4.1.0:

    alternatives_ssl => 'oozie-tomcat-conf',
    oozie_sharelib =>  '/usr/lib/oozie/oozie-sharelib-yarn.tar.gz',

<a name="multinn"></a>
###Cluster with more HDFS Name nodes

If there are used more HDFS namenodes in the Hadoop cluster (high availability, namespaces, ...), it is needed to have 'oozie' system user on all of them to authorization work properly. You could install full Oozie client (using *oozie::client::install*), but just creating the user is enough (using *oozie::user*).

Note, the *oozie::hdfs* class must be used too, but only on one of the HDFS namenodes. It includes the *oozie::user*.

**Example**:

    node <HDFS_NAMENODE> {
      include oozie::hdfs
    }

    node <HDFS_OTHER_NAMENODE> {
      include oozie::user
    }

<a name="upgrade"></a>
###Upgrade

#### Configurations

The best way is to refresh configurations from the new original (=remove the old) and relaunch puppet on top of it. You may need to remove helper file *~oozie/.puppet-ssl\**, when Hadoop SSL configuration files are recreated.

For example:

    alternative='cluster'
    d='oozie'
    mv /etc/{d}$/conf.${alternative} /etc/${d}/conf.cdhXXX
    update-alternatives --auto ${d}-conf
    rm -fv ~oozie/.puppet-ssl*

    # upgrade
    ...

    puppet agent --test
    #or: puppet apply ...

#### Database schema

Under *oozie* user:

    /usr/lib/oozie/bin/ooziedb.sh create -run

#### Shared library

    oozie-setup sharelib upgrade -fs hdfs://${DEFAULT_FS} -locallib /usr/lib/oozie/oozie-sharelib-yarn

<a name="reference"></a>
## Reference

<a name="classes"></a>
###Classes

* [**`oozie`**](#class-oozie): Apache Oozie Workflow Scheduler - configure class
* **`oozie::client`**: Oozie Client
 * `oozie::config`
 * `oozie::install`
* `oozie::common::config`
* `oozie::common::postinstall`
* **`oozie::server`**: Oozie Server
* `oozie::server::config`
* `oozie::server::install`
* `oozie::server::service`
* **`oozie::hdfs`**: HDFS Initializations
* `oozie::params`
* **`oozie::user`**: Create oozie system user

<a name="parameters"></a>
<a name="class-oozie"></a>
### Parameters (oozie class)

####`acl`

Determines, if setfacl command is available and /etc/hadoop is on filesystem supporting POSIX ACL. Default: undef.

It is used to set privileges of ssl-server.xml and ssl-client.xml for Oozie. If the POSIX ACL is not supported, disable this parameter also in cesnet-hadoop puppet module.

####`adminusers`

Administrator users. Default: undef.

####`alternatives`

Switches the alternatives used for the configuration. Default: 'cluster' (Debian) or undef.

It can be used only when supported (for example with Cloudera distribution).

####`alternatives_ssl`

Switches the alternatives used for tomcat http/https configuration. Default: 'oozie-tomcat-conf'.

It must have proper value according to the Oozie version used. There has been several changes in Cloudera. Other valid value may be *oozie-tomcat-deployment*.

####`database_setup_enable`

Enables database setup (if suported). Default: true.

####`db`

Database type. Default: 'derby'.

Values can be:

* **derby**
* **mysql**
* **postgresql**
* **oracle**

####`db_host`

Database host. Default: 'localhost'.

####`db_name`

Database name. Default: 'oozie'.

####`db_user`

Database user. Default: 'oozie'.

####`db_password`

Database password. Default: ' ' (space)

Note, Oozie requires a space, when using empty password.

####`environment`

Define environment variable OOZIE\_URL on clients. Default: true.

####`gui_enable`

Downloads and deploys Oozie extras GUI. Default: true.

There may be reasons to disable it:

* Its license is GPL (probably incompatible and less free than Apache 2.0, but IANAL)
* GUI is not compatible with Java >= 8 (tested with CDH <= 5.7.1, Oozie <= 4.1.0)

####`https`

Enable HTTPS. Default: false.

####`https_keystore`

Certificates keystore file. Default: '/etc/security/server.keystore'.

####`https_keystore_password`

Certificates keystore file password. Default: 'changeit'.

Note, the **::undef** value can reset *https_keystore_password* to empty value. But oozie doesn't accept empty password, the startup scripts will set its default value "password" in that case.

####`https_keytab`

Keytab file for SPNEGO HTTPS. Default: '/etc/security/keytab/http.service.keytab'.

The file is copied into oozie home directory.

####`keytab`

Oozie keytab file. Default: '/etc/security/keytab/oozie.service.keytab'.

####`hue_hostnames`

Authenticated Apache Hue hostnames. Default: [].

Sets properties *oozie.service.ProxyUserService.proxyuser.hue.hosts* and *oozie.service.ProxyUserService.proxyuser.hue.groups*. They can be overridden by *properties* parameter.

####`oozie_hostname`

Oozie server hostname. Default: $::fqdn.

Needed when any oozie client is also on separated node.

####`oozie_sharelib`

Path to oozie sharelib for setup. Default: '/usr/lib/oozie/oozie-sharelib-yarn'.

Note: there has been change in Cloudera somewhere between 5.3.1 and 5.4.2, the older path has been '/usr/lib/oozie/oozie-sharelib-yarn.tar.gz'.

####`realm`

Enable security and Kerberos realm to use. Default: ''.

Empty string disables the security.

####`version`

Oozie version. Default: '4'.

Oozie version to distinguish differences between Oozie 4.x and Oozie 5.x:

* moved from Tomcat to Jetty + SSL configured using properties instead of alternatives
* properties names changes
* credential classes list changes

<a name="limitations"></a>
## Limitations

See [Setup Requirements](#setup-requirements) section.

Only Puppet 3 can be tested by unit-tests, Puppet 4 can't use custom *site.pp*.

<a name="development"></a>
## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-oozie](https://github.com/MetaCenterCloudPuppet/cesnet-oozie)
* Testing:
 * basic: see *.travis.yml*
 * vagrant: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
