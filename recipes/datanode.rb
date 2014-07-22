# coding=utf-8

include_recipe 'hadoop::repo'

%w(
  hadoop-0.20-mapreduce-tasktracker
  hadoop-hdfs-datanode
).each do |pkg|
  package pkg
end

node.set['hadoop']['data_dir'] =
  node['hadoop']['data_root'].map { |d| "#{d}/dfs" }
node.set['hadoop']['hdfs-site']['dfs.datanode.name.dir'] =
  node['hadoop']['data_dir'].map { |dir| dir + '/dn' }

%w(
  namenode
  jobtracker
).each do |nodetype|
  r = search(
    :node,
    "chef_environment:#{node.chef_environment} AND " \
      "hadoop_cluster-name:#{node['hadoop']['cluster-name']} AND " \
      "(recipes:hadoop\\:\\:#{nodetype} OR " \
      "roles:#{nodetype})"
  )

  if r.empty?
    fail "Could not find the #{nodetype}"
  elsif r.count > 1
    fail "Found #{r.count} servers with role #{nodetype}: " \
      "#{r.map { |s| s['fqdn'] }.join(', ')}"
  else
    node.set['hadoop']['hosts'][nodetype] = r.first['fqdn']
  end

  Chef::Log.info "Hadoop: Set #{nodetype} to " \
    "<#{node['hadoop']['hosts'][nodetype]}>"
end

node.set['hadoop']['core-site']['fs.defaultFS'] =
  "hdfs://#{node['hadoop']['hosts']['namenode']}/"

include_recipe 'hadoop::default'

node['hadoop']['hdfs-site']['dfs.datanode.name.dir'].each do |dir|
  directory dir do
    owner node['hadoop']['hdfs_user']
    group node['hadoop']['hdfs_group']
    mode 0700
    action :create
    recursive true
  end
end

%w(
  hadoop-hdfs-datanode
  hadoop-0.20-mapreduce-tasktracker
).each do |hadoop_svc|
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
  node['hadoop']['custom_libs'].each do |lib|
    if lib['delete_file']
      file node['hadoop'][dir] + lib['delete_file'] do
        action :delete
      end
    end

    remote_file node['hadoop'][dir] + lib['new_file'] do
      owner 'root'
      group 'root'
      mode 0644
      source 'file://' + Chef::Config['file_cache_path'] + '/hadoop' +
        lib['new_file']
      checksum lib['checksum']
      notifies :restart, 'service[hadoop-hdfs-datanode]'
      notifies :restart, 'service[hadoop-0.20-mapreduce-tasktracker]'
    end
  end
end
