# coding=utf-8

node.set['hadoop']['hdfs-site']['dfs.namenode.name.dir'] =
  node['hadoop']['data_dir'] + '/nn'

include_recipe 'hadoop::repo'

package 'hadoop-hdfs-namenode'

directory node['hadoop']['hdfs-site']['dfs.namenode.name.dir'] do
  owner node['hadoop']['hdfs_user']
  group node['hadoop']['hdfs_group']
  mode 0700
  action :create
  recursive true
end

node.set['hadoop']['hdfs-site']['dfs.namenode.http-address'] = '0.0.0.0:50070'
node.set['hadoop']['hosts']['namenode'] = node['fqdn']

include_recipe 'hadoop::default'

execute 'mkdir_hdfs_tmp' do
  command 'hadoop fs -mkdir /tmp && ' \
    'hadoop fs -chmod -R 1777 /tmp'
  user node['hadoop']['hdfs_user']
  action :nothing
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /tmp"
end

execute 'create_mr_var_dirs' do
  command 'hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging && ' \
   'hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging && ' \
   "hadoop fs -chown -R #{node['hadoop']['mapred_user']} " \
   '/var/lib/hadoop-hdfs/cache/mapred/mapred'
  user node['hadoop']['hdfs_user']
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls " \
    '/var/lib/hadoop-hdfs/cache/mapred/mapred/staging'
  action :nothing
end

execute 'mapred_system_dirs' do
  command 'hadoop fs -mkdir /tmp/mapred/system && ' \
    "hadoop fs -chown #{node['hadoop']['mapred_user']}:#{node['hadoop']['group']} " \
    '/tmp/mapred/system'
  user node['hadoop']['hdfs_user']
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /tmp/mapred/system"
  action :nothing
end

execute 'format_namenode' do
  command 'hdfs namenode -format'
  user node['hadoop']['hdfs_user']
  creates "#{node['hadoop']['hdfs-site']['dfs.namenode.name.dir']}/current"
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /"
end

%w{
  hadoop-hdfs-namenode
}.each do |hadoop_svc|
  service hadoop_svc do
    supports status: :true, restart: :true
    action [:enable, :start]
    notifies :run, 'execute[mkdir_hdfs_tmp]'
    notifies :run, 'execute[create_mr_var_dirs]'
    notifies :run, 'execute[mapred_system_dirs]'
  end
end

%w(
  lib_dir
  hdfs_lib_dir
).each do |dir|
  node['hadoop']['custom_libs'].each do |lib|
    if lib['delete_file']
      file node['hadoop'][dir] + lib['delete_file'] do
        action :delete
      end
    end

    remote_file node['hadoop'][dir] + lib['new_file'] do
      owner    'root'
      group    'root'
      mode     0644
      source   'file://' + Chef::Config['file_cache_path'] + '/hadoop' +
        lib['new_file']
      checksum lib['checksum']
      notifies :restart, 'service[hadoop-hdfs-namenode]'
    end
  end
end
