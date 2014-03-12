# coding: utf-8
#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2013 EverTrue, Inc.
#
# All rights reserved - Do Not Redistribute
#

case node['platform_family']
when 'debian'
  include_recipe 'apt'
end

include_recipe 'java'

directory node['hadoop']['conf_dir'] do
  owner 'root'
  group node['hadoop']['group']
  mode '0755'
  action :create
end

case node['platform_family']
when 'redhat'
  alternatives_cmd = 'alternatives'
when 'debian'
  alternatives_cmd = 'update-alternatives'
end

execute 'update_hadoop_alternatives' do
  command "#{alternatives_cmd} " +
    "--install #{node['hadoop']['conf_root']}/conf " +
    'hadoop-conf ' +
    "#{node['hadoop']['conf_dir']} " +
    '50 && ' +
    "#{alternatives_cmd} " +
    "--set hadoop-conf #{node['hadoop']['conf_dir']}"
  creates '/tmp/something'
  action :run
end

# Old version
# $ sum guava-11.0.2.jar
# 38428  1610

remote_file Chef::Config['file_cache_path'] +
  "/guava-#{node['hadoop']['guava']['version']}.jar" do
  owner 'root'
  group 'root'
  mode 0644
  source 'http://search.maven.org/remotecontent?' \
    'filepath=com/google/guava/guava/' +
      node['hadoop']['guava']['version'] +
      "/guava-#{node['hadoop']['guava']['version']}.jar"
  checksum 'd69df3331840605ef0e5fe4add60f2d28e870e3820937ea29f713d2035d9ab97'
end

%w{
  namenode
  jobtracker
}.each do |nodetype|
  if node['hadoop'][nodetype]
  elsif node['hadoop']['hosts']["#{nodetype}_default"]
    node.set['hadoop']['hosts'][nodetype] =
      node['hadoop']['hosts']["#{nodetype}_default"]
  elsif node.roles.include?(nodetype)
    node.set['hadoop']['hosts'][nodetype] = node['fqdn']
  else
    r = search(
      :node,
      "chef_environment:#{node.chef_environment} AND " +
      "hadoop_cluster-name:#{node['hadoop']['cluster-name']} AND " +
      "roles:#{nodetype}"
    )
    if r.empty?
      fail "Could not find the #{nodetype}"
    elsif r.count > 1
      fail "Found #{r.count} servers with role #{nodetype}: " \
        "#{r.map { |s| s['fqdn'] }.join(', ')}"
    else
      node.set['hadoop']['hosts'][nodetype] = r.first['fqdn']
    end
  end
  if !node['hadoop']['hosts'][nodetype] ||
    node['hadoop']['hosts'][nodetype].empty?
    fail "#{nodetype} is not set"
  end
end

node.set['hadoop']['core-site']['fs.defaultFS'] = "hdfs://" \
  "#{node['hadoop']['hosts']['namenode']}/"
node.set['hadoop']['mapred-site'] = {
  'mapred.job.tracker' => "#{node['hadoop']['hosts']['jobtracker']}:8021",
  'mapred.local.dir' => "#{node['hadoop']['data_root']}/mapred/local"
}

directory node['hadoop']['mapred-site']['mapred.local.dir'] do
  owner node['hadoop']['mapred_user']
  group node['hadoop']['group']
  mode '0755'
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
    source 'conf.live/generic-xml.erb'
    owner 'root'
    group node['hadoop']['group']
    mode 0644
    variables(conf_file: conf_file)
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
