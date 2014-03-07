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
  file node['hadoop'][dir] +
    "/lib/guava-#{node['hadoop']['guava']['delete_version']}.jar" do
    action :delete
  end

  remote_file node['hadoop'][dir] +
    "/lib/guava-#{node['hadoop']['guava']['version']}.jar" do
    owner    'root'
    group    'root'
    mode     0644
    source   'file://' + Chef::Config['file_cache_path'] +
      "/guava-#{node['hadoop']['guava']['version']}.jar"
    checksum node['hadoop']['guava']['checksum']
    notifies :restart, 'service[hadoop-hdfs-datanode]'
    notifies :restart, 'service[hadoop-0.20-mapreduce-tasktracker]'
  end
end
