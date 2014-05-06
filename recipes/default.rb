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

node.set['hadoop']['data_dir'] =
  node['hadoop']['data_root'].map { |d| "#{d}/dfs" }

node.set['hadoop']['hdfs-site']['dfs.datanode.name.dir'] =
  node['hadoop']['data_dir'].map { |dir| dir + '/dn' }
node.set['hadoop']['hdfs-site']['dfs.namenode.name.dir'] =
  node['hadoop']['data_dir'].map { |dir| dir + '/nn' }
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

node['hadoop']['custom_libs'].each do |lib|
  directory File.dirname(Chef::Config['file_cache_path'] + '/hadoop' +
    lib['new_file']) do
    recursive true
  end

  remote_file Chef::Config['file_cache_path'] + '/hadoop' + lib['new_file'] do
    owner 'root'
    group 'root'
    mode 0644
    source lib['source']
    checksum lib['checksum']
  end
end

%w(
  namenode
  jobtracker
).each do |nodetype|
  if node.roles.include?(nodetype) ||
    node.recipes.include?("hadoop::#{nodetype}")
    node.set['hadoop']['hosts'][nodetype] = node['hadoop']['local_fqdn']
    Chef::Log.info "Set #{nodetype} to self because it is in one of my" \
      'roles/recipes'
  else
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

    Chef::Log.debug "Set #{nodetype} from search results: #{r.inspect}"
  end

  Chef::Log.info "Hadoop: Set #{nodetype} to " \
    "<#{node['hadoop']['hosts'][nodetype]}>"
end

node.set['hadoop']['core-site']['fs.defaultFS'] = 'hdfs://' \
  "#{node['hadoop']['hosts']['namenode']}/"
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
