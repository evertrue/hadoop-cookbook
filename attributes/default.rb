# coding: utf-8
default['hadoop']['package_version'] =
  value_for_platform_family(
    'debian' => '2.0.0+1604-1.cdh4.7.0.p0.17~precise-cdh4.7.0'
  )

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

default['hadoop']['lib_dir'] = '/usr/lib/hadoop'
default['hadoop']['mapred_lib_dir'] = '/usr/lib/hadoop-0.20-mapreduce'
default['hadoop']['hdfs_lib_dir'] = '/usr/lib/hadoop-hdfs'

case node['platform_family']
when 'redhat'
  default['hadoop']['conf_root'] = '/etc/hadoop-0.20'
when 'debian'
  default['hadoop']['conf_root'] = '/etc/hadoop'
end

default['hadoop']['data_root'] = ['/mnt/data']
default['hadoop']['tmp_root'] = ['/mnt/tmp']

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

# hdfs-site.xml
default['hadoop']['hdfs-site']['dfs.permissions.superusergroup'] = 'hadoop'
default['hadoop']['local_fqdn'] = node['fqdn']

set['java']['jdk_version'] = '7'
