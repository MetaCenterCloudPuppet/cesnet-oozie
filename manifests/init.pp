# == Class: oozie
#
# Apache Oozie Workflow Scheduler - configure class.
#
class oozie (
  $acl = undef,
  $adminusers = undef,
  $alternatives = '::default',
  $alternatives_ssl = '::default',
  $database_setup_enable = true,
  $db = 'derby',
  $db_host = 'localhost',
  $db_name = 'oozie',
  $db_user = 'oozie',
  $db_password = ' ',
  $environment = true,
  $gui_enable = true,
  $https = false,
  $https_keystore = '/etc/security/server.keystore',
  $https_keystore_password = 'changeit',
  $https_keytab = '/etc/security/keytab/http.service.keytab',
  $hue_hostnames = [],
  $keytab = '/etc/security/keytab/oozie.service.keytab',
  $perform = false,
  $properties = {},
  $oozie_hostname = $::fqdn,
  $oozie_sharelib = $::oozie::params::oozie_sharelib,
  $realm = '',
  $version = 5,
) inherits ::oozie::params {

  case "${::oozie::version}." {
    /^4(\..*)?$/: {
      # alternatives for SSL only for Oozie 4.x
      $_alternatives_ssl = $::oozie::default_alternatives_ssl
      $security_property_name = 'oozie.service.AuthorizationService.security.enabled'
    }
    default: {
      $_alternatives_ssl = undef
      $security_property_name = 'oozie.service.AuthorizationService.authorization.enabled'
    }
  }

  if $https_keystore_password == '::undef' {
    $_https_keystore_password = ''
  } else {
    $_https_keystore_password = $https_keystore_password
  }

  $dyn_properties = {
    'oozie.service.ActionService.executor.ext.classes' => '
            org.apache.oozie.action.email.EmailActionExecutor,
            org.apache.oozie.action.hadoop.HiveActionExecutor,
            org.apache.oozie.action.hadoop.ShellActionExecutor,
            org.apache.oozie.action.hadoop.SqoopActionExecutor,
            org.apache.oozie.action.hadoop.DistcpActionExecutor,
            org.apache.oozie.action.hadoop.Hive2ActionExecutor
',
    'oozie.service.SchemaService.wf.ext.schemas' => '
            shell-action-0.1.xsd,shell-action-0.2.xsd,shell-action-0.3.xsd,email-action-0.1.xsd,email-action-0.2.xsd,
            hive-action-0.2.xsd,hive-action-0.3.xsd,hive-action-0.4.xsd,hive-action-0.5.xsd,sqoop-action-0.2.xsd,
            sqoop-action-0.3.xsd,sqoop-action-0.4.xsd,ssh-action-0.1.xsd,ssh-action-0.2.xsd,distcp-action-0.1.xsd,
            distcp-action-0.2.xsd,oozie-sla-0.1.xsd,oozie-sla-0.2.xsd,hive2-action-0.1.xsd
',
    'oozie.system.id' => 'oozie-${user.name}',
    'oozie.systemmode' => 'NORMAL',
    "${security_property_name}" => false,
    'oozie.service.PurgeService.older.than' => 30,
    'oozie.service.PurgeService.purge.interval' => 3600,
    'oozie.service.CallableQueueService.queue.size' => 10000,
    'oozie.service.CallableQueueService.threads' => 10,
    'oozie.service.CallableQueueService.callable.concurrency' => 3,
    'oozie.service.coord.normal.default.timeout' => 120,
    'oozie.db.schema.name' => 'oozie',
    'oozie.service.JPAService.create.db.schema' => false,
    'oozie.service.JPAService.pool.max.active.conn' => 10,
    'oozie.service.HadoopAccessorService.kerberos.enabled' => false,
    'oozie.service.HadoopAccessorService.jobTracker.whitelist' => ' ',
    'oozie.service.HadoopAccessorService.nameNode.whitelist' => ' ',
    'oozie.service.HadoopAccessorService.hadoop.configurations' => "*=${::oozie::hadoop_confdir}",
    'oozie.service.WorkflowAppService.system.libpath' => '/user/${user.name}/share/lib',
    'oozie.authentication.type' => 'simple',
    'oozie.authentication.token.validity' => 3600,
    'oozie.authentication.cookie.domain' => '',
    'oozie.authentication.simple.anonymous.allowed' => true,
    'oozie.action.mapreduce.uber.jar.enable' => true,
    'oozie.service.ProxyUserService.proxyuser.hue.hosts' => '*',
    'oozie.service.ProxyUserService.proxyuser.hue.groups' => '*',
  }

  $descriptions = {
    'oozie.credentials.credentialclasses' => 'To use kerberized Hive and HBase',
    'oozie.system.id' => 'The Oozie system ID',
    'oozie.systemmode' => 'System mode for Oozie at startup',
    'oozie.service.AuthorizationService.security.enabled' => 'Specifies whether security (user name/admin role) is enabled or not
            If disabled any user can manage Oozie system and manage any job.',
    'oozie.service.PurgeService.older.than' => 'Jobs older than this value, in days, will be purged by the PurgeService.',
    'oozie.service.PurgeService.purge.interval' => 'Interval at which the purge service will run, in seconds',
    'oozie.service.CallableQueueService.queue.size' => 'Max callable queue size',
    'oozie.service.CallableQueueService.threads' => 'Number of threads used for executing callables',
    'oozie.service.CallableQueueService.callable.concurrency' => 'Maximum concurrency for a given callable type.
            Each command is a callable type (submit, start, run, signal, job, jobs, suspend,resume, etc).
            Each action type is a callable type (Map-Reduce, Pig, SSH, FS, sub-workflow, etc).
            All commands that use action executors (action-start, action-end, action-kill and action-check) use
            the action type as the callable type.',
    'oozie.service.coord.normal.default.timeout' => 'Default timeout for a coordinator action input check (in minutes) for normal job.
            -1 means infinite timeout',
    'oozie.db.schema.name' => 'Oozie DataBase Name',
    'oozie.service.JPAService.create.db.schema' => 'Creates Oozie DB.
            If set to true, it creates the DB schema if it does not exist. If the DB schema exists is a NOP.
            If set to false, it does not create the DB schema. If the DB schema does not exist it fails start up.',
    'oozie.service.JPAService.jdbc.driver' => 'JDBC driver class',
    'oozie.service.JPAService.jdbc.url' => 'JDBC URL',
    'oozie.service.JPAService.jdbc.username' => 'DB user name',
    'oozie.service.JPAService.jdbc.password' => 'DB user password
            IMPORTANT: if password is emtpy leave a 1 space string, the service trims the value,
                       if empty Configuration assumes it is NULL.
',
    'oozie.service.JPAService.pool.max.active.conn' => 'Max number of connections',
    'oozie.service.HadoopAccessorService.kerberos.enabled' => 'Indicates if Oozie is configured to use Kerberos',
    'local.realm' => 'Kerberos Realm used by Oozie and Hadoop. To be aligned with Hadoop configuration.',
    'oozie.service.HadoopAccessorService.keytab.file' => 'Location of the Oozie user keytab file',
    'oozie.service.HadoopAccessorService.kerberos.principal' => 'Kerberos principal for Oozie service',
    'oozie.service.HadoopAccessorService.jobTracker.whitelist' => 'Whitelisted job tracker for Oozie service.',
    'oozie.service.HadoopAccessorService.nameNode.whitelist' => 'Whitelisted job tracker for Oozie service',
    'oozie.service.HadoopAccessorService.hadoop.configurations' => 'Comma separated AUTHORITY=HADOOP_CONF_DIR, where AUTHORITY is the HOST:PORT of
            the Hadoop service (JobTracker, HDFS). The wildcard "*" configuration is
            used when there is no exact match for an authority. The HADOOP_CONF_DIR contains
            the relevant Hadoop *-site.xml files. If the path is relative is looked within
            the Oozie configuration directory; though the path can be absolute (i.e. to point
            to Hadoop client conf/ directories in the local filesystem.',
    'oozie.service.WorkflowAppService.system.libpath' => 'System library path to use for workflow applications.
            This path is added to workflow application if their job properties sets
            the property "oozie.use.system.libpath" to true.',
    'use.system.libpath.for.mapreduce.and.pig.jobs' => 'If set to true, submissions of MapReduce and Pig jobs will include
            automatically the system library path, thus not requiring users to
            specify where the Pig JAR files are. Instead, the ones from the system
            library path are used.',
    'oozie.authentication.type' => 'Defines authentication used for Oozie HTTP endpoint.
            Supported values are: simple | kerberos | #AUTHENTICATION_HANDLER_CLASSNAME#',
    'oozie.authentication.token.validity' => 'Indicates how long (in seconds) an authentication token is valid before it has to be renewed',
    'oozie.authentication.cookie.domain' => 'The domain to use for the HTTP cookie that stores the authentication token.
        In order to authentiation to work correctly across multiple hosts
        the domain must be correctly set.',
    'oozie.authentication.simple.anonymous.allowed' => 'Indicates if anonymous requests are allowed.
            This setting is meaningful only when using "simple" authentication.',
    'oozie.authentication.kerberos.principal' => 'Indicates the Kerberos principal to be used for HTTP endpoint.
            The principal MUST start with "HTTP/" as per Kerberos HTTP SPNEGO specification.',
    'oozie.authentication.kerberos.keytab' => 'Location of the keytab file with the credentials for the principal.
            Referring to the same keytab file Oozie uses for its Kerberos credentials for Hadoop.',
      'oozie.authentication.kerberos.name.rules' => 'The kerberos names rules is to resolve kerberos principal names, refer to Hadoops
            KerberosName for more details.',
      'oozie.action.mapreduce.uber.jar.enable' => 'Handle uber JARs properly for the MapReduce action (as long as it does not include any streaming or pipes)',
  }

  case $db {
    'derby',default: {
      $db_properties = {
        'oozie.service.JPAService.jdbc.driver' => 'org.apache.derby.jdbc.EmbeddedDriver',
      }
    }
    'mariadb': {
      $db_properties = {
        'oozie.service.JPAService.jdbc.driver' => 'org.mariadb.jdbc.Driver',
        # oozie-mariadb-orm.xml not found ==> "mysql" instead of "mariadb"
        'oozie.service.JPAService.jdbc.url' => "jdbc:mysql://${db_host}:3306/${db_name}",
        'oozie.service.JPAService.jdbc.username' => $db_user,
        'oozie.service.JPAService.jdbc.password' => $db_password,
      }
    }
    'mysql': {
      $db_properties = {
        'oozie.service.JPAService.jdbc.driver' => 'com.mysql.jdbc.Driver',
        'oozie.service.JPAService.jdbc.url' => "jdbc:mysql://${db_host}:3306/${db_name}",
        'oozie.service.JPAService.jdbc.username' => $db_user,
        'oozie.service.JPAService.jdbc.password' => $db_password,
      }
    }
    'postgresql': {
      $db_properties = {
        'oozie.service.JPAService.jdbc.driver' => 'org.postgresql.Driver',
        'oozie.service.JPAService.jdbc.url' => "jdbc:postgresql://${db_host}:5432/${db_name}",
        'oozie.service.JPAService.jdbc.username' => $db_user,
        'oozie.service.JPAService.jdbc.password' => $db_password,
      }
    }
    'oracle': {
      $db_properties = {
        'oozie.service.JPAService.jdbc.driver' => 'oracle.jdbc.OracleDriver',
        'oozie.service.JPAService.jdbc.url' => "jdbc:oracle:thin:@//${db_host}:1521/${db_name}",
        'oozie.service.JPAService.jdbc.username' => $db_user,
        'oozie.service.JPAService.jdbc.password' => $db_password,
      }
    }
  }

  # Hadoop Authentication
  if $realm and $realm != '' {
    $sec_base_properties = {
      'local.realm' => $realm,
      'oozie.service.HadoopAccessorService.kerberos.enabled' => true,
      'oozie.service.HadoopAccessorService.kerberos.principal' => "\${user.name}/${::fqdn}@\${local.realm}",
      #'oozie.service.HadoopAccessorService.keytab.file' => '${user.home}/oozie.keytab',
      'oozie.service.HadoopAccessorService.keytab.file' => $keytab,
      "${security_property_name}" => true,
    }
    case "${::oozie::version}." {
      /^4(\..*)?$/: {
        $sec_versioned_properties = {
          'oozie.credentials.credentialclasses' => 'hcat=org.apache.oozie.action.hadoop.HCatCredentials, hbase=org.apache.oozie.action.hadoop.HbaseCredentials, hive2=org.apache.oozie.action.hadoop.Hive2Credentials',
        }
      }
      default: {
        $sec_versioned_properties = {
          'oozie.credentials.credentialclasses' => 'hcat=org.apache.oozie.action.hadoop.HCatCredentials, hbase=org.apache.oozie.action.hadoop.HbaseCredentials, hive2=org.apache.oozie.action.hadoop.Hive2Credentials, hdfs=org.apache.oozie.action.hadoop.HDFSCredentials, jhs=org.apache.oozie.action.hadoop.JHSCredentials, yarnrm=org.apache.oozie.action.hadoop.YarnRMCredentials',
        }
      }
    }
    $sec_properties = merge($sec_base_properties, $sec_versioned_properties)
  } else {
    $sec_properties = {}
  }

  # Oozie Authentication
  if $https {
    if $_https_keystore_password and $_https_keystore_password != '' {
      $https_password_properties = {
        'oozie.https.keystore.pass' => $_https_keystore_password,
      }
    } else {
      $https_password_properties = undef
    }
    $https_common_properties = {
      'local.realm' => $realm,
      'oozie.authentication.type' => 'kerberos',
      'oozie.authentication.cookie.domain' => downcase($realm),
      'oozie.authentication.kerberos.principal' => "HTTP/${::fqdn}@\${local.realm}",
      #'oozie.authentication.kerberos.keytab' => '${oozie.service.HadoopAccessorService.keytab.file}',
      'oozie.authentication.kerberos.keytab' => '${user.home}/http.service.keytab',
      'oozie.authentication.kerberos.name.rules' => "
RULE:[2:\$1;\$2@\$0](hue;.*@${realm})s/^.*$/hue/
RULE:[2:\$1;\$2@\$0](oozie;.*@${realm})s/^.*$/oozie/
DEFAULT
",
      'oozie.authentication.signature.secret' => "${::oozie::oozie_homedir}/http-auth-signature-secret",
      'oozie.base.url' => "https://${oozie_hostname}:11443/oozie",
    }
    case "${::oozie::version}." {
      /^4(\..*)?$/: {
        $https_versioned_properties = undef
      }
      default: {
        $https_versioned_properties = {
          'oozie.https.enabled' => true,
          'oozie.https.keystore.file' => "${::oozie::oozie_homedir}/.keystore",
        }
      }
    }
    $https_properties = merge($https_password_properties, $https_versioned_properties, $https_common_properties)
  } else {
    $https_properties = {
      'oozie.base.url' => "http://${oozie_hostname}:11000/oozie",
    }
  }

  if $hue_hostnames and !empty($hue_hostnames) {
    $hue_properties = {
      'oozie.service.ProxyUserService.proxyuser.hue.hosts' => join($hue_hostnames, ','),
      'oozie.service.ProxyUserService.proxyuser.hue.groups' => '*',
    }
  } else {
    $hue_properties = {}
  }

  $_properties = merge($dyn_properties, $db_properties, $sec_properties, $https_properties, $hue_properties, $properties)
}
