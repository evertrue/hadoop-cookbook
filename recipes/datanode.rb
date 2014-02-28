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
