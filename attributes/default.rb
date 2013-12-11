default['hadoop']['core-site'] = {}
default['hadoop']['hdfs-site'] = {}
default['hadoop']['hadoop-policy'] = {}
default['hadoop']['mapred-site'] = {}

default['hadoop']['cluster-name'] = "default"
default['hadoop']['group'] = 'hadoop'
default['hadoop']['hdfs_group'] = 'hdfs'
default['hadoop']['hdfs_user'] = 'hdfs'
default['hadoop']['mapred_user'] = 'mapred'

case node['platform_family']
when 'redhat'
  default['hadoop']['conf_root'] = '/etc/hadoop-0.20'
when 'debian'
  default['hadoop']['conf_root'] = '/etc/hadoop'
end

default['hadoop']['data_root'] = "/data"
default['hadoop']['data_dir'] = "#{node['hadoop']['data_root']}/dfs"

default['hadoop']['conf_dir'] = "#{node['hadoop']['conf_root']}/conf.live"

## Main Hadoop XML files...

# core-site.xml

# hdfs-site.xml
default['hadoop']['hdfs-site']['dfs.permissions.superusergroup'] = 'hadoop'
