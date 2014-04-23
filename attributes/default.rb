# coding: utf-8
default['hadoop']['core-site'] = {}
default['hadoop']['hdfs-site'] = {}
default['hadoop']['hadoop-policy'] = {}
default['hadoop']['mapred-site'] = {}
default['hadoop']['hosts'] = {}

default['hadoop']['cluster-name'] = 'default'
default['hadoop']['group'] = 'hadoop'
default['hadoop']['hdfs_group'] = 'hdfs'
default['hadoop']['hdfs_user'] = 'hdfs'
default['hadoop']['mapred_user'] = 'mapred'

default['hadoop']['guava']['version'] = '14.0.1'
default['hadoop']['guava']['delete_version'] = '11.0.2'
default['hadoop']['guava']['checksum'] =
  'd69df3331840605ef0e5fe4add60f2d28e870e3820937ea29f713d2035d9ab97'

default['hadoop']['custom_libs'] = [
  {
    'delete_file' => '/lib/guava-11.0.2.jar',
    'new_file' => '/lib/guava-14.0.1.jar',
    'source' => 'http://search.maven.org/remotecontent?' \
      'filepath=com/google/guava/guava/14.0.1/guava-14.0.1.jar',
    'checksum' => 'd69df3331840605ef0e5fe4add60f2d28e870e3820937ea29f713d2035d9ab97'
  },
  {
    'delete_file' => '/lib/jackson-core-asl-1.8.8.jar',
    'new_file' => '/lib/jackson-core-asl-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-core-asl-1.9.12.jar',
    'checksum' => 'eb1fcba3554c8408fa40d17fb5d085ce1502d990c08940766e90d18801ad9c3a'
  },
  {
    'delete_file' => '/lib/jackson-jaxrs-1.8.8.jar',
    'new_file' => '/lib/jackson-jaxrs-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-jaxrs-1.9.12.jar',
    'checksum' => '401e6d16a19cef22deac363dcc2e7790707c2c19e0f1eb173172f09d9da33adb'
  },
  {
    'delete_file' => '/lib/jackson-mapper-asl-1.8.8.jar',
    'new_file' => '/lib/jackson-mapper-asl-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-mapper-asl-1.9.12.jar',
    'checksum' => '1a6d65351d7d7645719391e9336bd2f9296073b08eac082935d9b1650da351be'
  },
  {
    'delete_file' => '/lib/jackson-xc-1.8.8.jar',
    'new_file' => '/lib/jackson-xc-1.9.12.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/jackson-xc-1.9.12.jar',
    'checksum' => '63b43105cb043bf23e8e8302458ce5ffa67c70c514bb58f89da2855f410d2f61'
  },
  {
    'new_file' => '/lib/mysql-connector-java-5.1.24.jar',
    'source' => 'http://ops.evertrue.com.s3.amazonaws.com/pkgs/mysql-connector-java-5.1.24.jar',
    'checksum' => 'f4349b4f3770fabc8eda03b86015edb3cf07b19009c97158b64ebba45c2cb4ba'
  }
]

default['hadoop']['lib_dir'] = '/usr/lib/hadoop'
default['hadoop']['mapred_lib_dir'] = '/usr/lib/hadoop-0.20-mapreduce'
default['hadoop']['hdfs_lib_dir'] = '/usr/lib/hadoop-hdfs'

case node['platform_family']
when 'redhat'
  default['hadoop']['conf_root'] = '/etc/hadoop-0.20'
when 'debian'
  default['hadoop']['conf_root'] = '/etc/hadoop'
end

default['hadoop']['data_root'] = '/mnt/data'
default['hadoop']['tmp_root'] = '/mnt/tmp'

default['hadoop']['data_dir'] = "#{node['hadoop']['data_root']}/dfs"

default['hadoop']['conf_dir'] = "#{node['hadoop']['conf_root']}/conf.live"

default['hadoop']['env_default'] = {
  'hadoop' => {
    'HADOOP_HOME_WARN_SUPPRESS' => 'true',
    'HADOOP_PREFIX' => node['hadoop']['lib_dir'],
    'HADOOP_LIBEXEC_DIR' => "#{node['hadoop']['lib_dir']}/libexec",
    'HADOOP_CONF_DIR' => "#{node['hadoop']['conf_root']}/conf",
    'HADOOP_COMMON_HOME' => node['hadoop']['lib_dir'],
    'HADOOP_HDFS_HOME' => node['hadoop']['hdfs_lib_dir'],
    'HADOOP_MAPRED_HOME' => node['hadoop']['mapred_lib_dir'],
    'YARN_HOME' => '/usr/lib/hadoop-yarn',
    'JSVC_HOME' => '/usr/lib/bigtop-utils'
  }
}

## Main Hadoop XML files...

# hadoop-site.xml
default['hadoop']['hadoop-site']['hadoop.tmp.dir'] =
  "#{node['hadoop']['tmp_root']}/hadoop-${user.name}"

# hdfs-site.xml
default['hadoop']['hdfs-site']['dfs.permissions.superusergroup'] = 'hadoop'
default['hadoop']['local_fqdn'] = node['fqdn']

set['java']['jdk_version'] = '7'
