# coding: utf-8
#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2013 EverTrue, Inc.
#
# All rights reserved - Do Not Redistribute
#

if Gem::Version.new(Chef::VERSION) < Gem::Version.new('11.10.0')
  # We require this version because otherwise node.recipes does not include
  # recipes included via include_recipe, which we use to figure out who's
  # who in our cluster.
  fail 'Chef version 11.10.0 or higher is required to run this recipe ' \
    "(Found: #{Chef::VERSION})."
end

node.set['hadoop']['core-site']['hadoop.tmp.dir'] =
  node['hadoop']['tmp_root'].map { |d| "#{d}/hadoop-${user.name}" }

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

node['hadoop']['tmp_root'].each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode 0777
    action :create
    recursive true
  end
end

case node['platform_family']
when 'redhat'
  alternatives_cmd = 'alternatives'
when 'debian'
  alternatives_cmd = 'update-alternatives'
end

execute 'update_hadoop_alternatives' do
  command "#{alternatives_cmd} " \
    "--install #{node['hadoop']['conf_root']}/conf " +
    'hadoop-conf ' +
    "#{node['hadoop']['conf_dir']} " +
    '50 && ' +
    "#{alternatives_cmd} " +
    "--set hadoop-conf #{node['hadoop']['conf_dir']}"
  creates '/tmp/something'
  action :run
end

include_recipe 'hadoop::customlibs'

node.set['hadoop']['mapred-site']['mapred.local.dir'] =
  node['hadoop']['data_root'].map { |dir| dir + '/mapred/local' }
node.set['hadoop']['mapred-site']['mapred.job.tracker'] =
  "#{node['hadoop']['hosts']['jobtracker']}:8021"

node['hadoop']['mapred-site']['mapred.local.dir'].each do |dir|
  directory dir do
    owner node['hadoop']['mapred_user']
    group node['hadoop']['group']
    mode '0755'
    action :create
    recursive true
  end
end

%w(
  core-site
  hdfs-site
  hadoop-policy
  mapred-site
).each do |conf_file|
  template "#{node['hadoop']['conf_dir']}/#{conf_file}.xml" do
    source 'conf.live/generic-xml.erb'
    owner 'root'
    group node['hadoop']['group']
    mode 0644
    variables(conf_file: conf_file)
  end
end

file "#{node['hadoop']['conf_dir']}/hadoop-site.xml" do
  action :delete
end

node['hadoop']['env_default'].each do |conf_file, conf_data|
  template "/etc/default/#{conf_file}" do
    source "#{conf_file}-default.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables(conf_data: conf_data)
  end
end

# Config files to deal with:
#
%w(
  configuration.xsl
  hadoop-metrics2.properties
  hadoop-metrics.properties
  log4j.properties
  slaves
).each do |conf_file|
  remote_file "#{node['hadoop']['conf_dir']}/#{conf_file}" do
    source "file://#{node['hadoop']['conf_root']}/conf.empty/#{conf_file}"
    owner 'root'
    group node['hadoop']['group']
    mode '0644'
  end
end
