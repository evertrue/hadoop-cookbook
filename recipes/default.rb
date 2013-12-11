#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2013 EverTrue, Inc.
#
# All rights reserved - Do Not Redistribute
#

case node['platform_family']
  when "debian"
   include_recipe 'apt'
end

include_recipe 'java'

case node['kernel']['machine']
when "x86_64"
  arch_name = "amd64"
else
  arch_name = node['kernel']['machine']
end

apt_repository "cloudera" do
  uri "http://archive.cloudera.com/cdh4" +
    "/#{node['platform']}" +
    "/#{node['lsb']['codename']}" +
    "/#{arch_name}" +
    "/cdh"
  distribution "#{node['lsb']['codename']}-cdh4"
  arch arch_name
  components [ "contrib" ]
  key "http://archive.cloudera.com/cdh4" +
    "/#{node['platform']}" +
    "/#{node['lsb']['codename']}" +
    "/#{arch_name}" +
    "/cdh" +
    "/archive.key"
end

directory node['hadoop']['conf_dir'] do
  owner "root"
  group node['hadoop']['group']
  mode "0755"
  action :create
end

case node['platform_family']
when "redhat"
  alternatives_cmd = "alternatives"
when "debian"
  alternatives_cmd = "update-alternatives"
end

execute "update_hadoop_alternatives" do
  command "#{alternatives_cmd} " +
    "--install #{node['hadoop']['conf_root']}/conf " +
    "hadoop-conf " +
    "#{node['hadoop']['conf_dir']} " +
    "50 && " +
    "#{alternatives_cmd} " +
    "--set hadoop-conf #{node['hadoop']['conf_dir']}"
  creates "/tmp/something"
  action :run
end

%w{
  namenode
  jobtracker
}.each do |nodetype|
  if ! node.set['hadoop']['hosts'][nodetype]
    if Chef::Config[:solo]
      raise "This recipe require search and will not work on chef_solo"
    else
      node.set['hadoop']['hosts'][nodetype] = search(
          :node,
          "chef_environment:#{node.chef_environment} AND " +
          "hadoop_cluster-name:#{node['hadoop']['cluster-name']} AND " +
          "recipes:hadoop\\:\\:#{nodetype}"
        ).first
    end
    raise "Could not find the #{nodetype}!" if node['hadoop']['hosts'][nodetype].nil?
  end
end

node.set['hadoop']['core-site']['fs.defaultFS'] = "hdfs://#{node['hadoop']['hosts']['namenode']}/"
node.set['hadoop']['mapred-site'] = {
  'mapred.job.tracker' => "#{node['hadoop']['hosts']['jobtracker']}:8021",
  'mapred.local.dir' => "#{node['data_root']}/mapred/local"
}

directory node['hadoop']['mapred-site']['mapred.local.dir'] do
  owner node['hadoop']['mapred_user']
  group node['hadoop']['group']
  mode "0755"
  action :create
  recursive true
end

%w{
  core-site
  hdfs-site
  hadoop-policy
  mapred-site
}.each do |conf_file|
  template "#{node['hadoop']['conf_dir']}/#{conf_file}.xml" do
    source "conf.live/generic-xml.erb"
    owner "root"
    group node['hadoop']['group']
    mode "0644"
    variables(:conf_file => conf_file)
  end
end


# Config files to deal with:
#
%w{
  configuration.xsl
  hadoop-metrics2.properties
  hadoop-metrics.properties
  log4j.properties
  slaves
}.each do |conf_file|
  remote_file "#{node['hadoop']['conf_dir']}/#{conf_file}" do
    source "file://#{node['hadoop']['conf_root']}/conf.empty/#{conf_file}"
    owner 'root'
    group node['hadoop']['group']
    mode '0644'
  end
end
