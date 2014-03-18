# coding=utf-8

node.set['hadoop']['hdfs-site']['dfs.datanode.name.dir'] =
  node['hadoop']['data_dir'] + '/dn'

include_recipe 'hadoop::repo'

%w{
  hadoop-0.20-mapreduce-tasktracker
  hadoop-hdfs-datanode
}.each do |pkg|
  package pkg
end

include_recipe 'hadoop::default'

directory node['hadoop']['hdfs-site']['dfs.datanode.name.dir'] do
  owner node['hadoop']['hdfs_user']
  group node['hadoop']['hdfs_group']
  mode 0700
  action :create
  recursive true
end

%w{
  hadoop-hdfs-datanode
  hadoop-0.20-mapreduce-tasktracker
}.each do |hadoop_svc|
  service hadoop_svc do
    supports status: :true, restart: :true
    action [:enable, :start]
  end
end

%w(
  lib_dir
  mapred_lib_dir
  hdfs_lib_dir
).each do |dir|
  node['hadoop']['replace_libs'].each do |lib|
    file node['hadoop'][dir] + lib['delete_file'] do
      action :delete
    end

    remote_file node['hadoop'][dir] + lib['new_file'] do
      owner    'root'
      group    'root'
      mode     0644
      source   'file://' + Chef::Config['file_cache_path'] + '/hadoop' +
        lib['new_file']
      checksum lib['checksum']
      notifies :restart, 'service[hadoop-hdfs-datanode]'
      notifies :restart, 'service[hadoop-0.20-mapreduce-tasktracker]'
    end
  end
end
