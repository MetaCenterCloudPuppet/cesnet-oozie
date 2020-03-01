class { 'hadoop':
  defaultFS => 'hdfs://master.example.com:8020',
}
include ::oozie
