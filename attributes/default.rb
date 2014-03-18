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
default['hadoop']['data_dir'] = "#{node['hadoop']['data_root']}/dfs"

default['hadoop']['conf_dir'] = "#{node['hadoop']['conf_root']}/conf.live"

## Main Hadoop XML files...

# core-site.xml

# hdfs-site.xml
default['hadoop']['hdfs-site']['dfs.permissions.superusergroup'] = 'hadoop'
default['hadoop']['local_fqdn'] = node['fqdn']

set['java']['jdk_version'] = '7'
