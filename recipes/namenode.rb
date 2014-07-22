# coding=utf-8

include_recipe 'hadoop::repo'

package 'hadoop-hdfs-namenode'

node.set['hadoop']['data_dir'] =
  node['hadoop']['data_root'].map { |d| "#{d}/dfs" }
node.set['hadoop']['hdfs-site']['dfs.namenode.name.dir'] =
  node['hadoop']['data_dir'].map { |dir| dir + '/nn' }

node.set['hadoop']['hdfs-site']['dfs.namenode.http-address'] = '0.0.0.0:50070'
node.set['hadoop']['core-site']['fs.defaultFS'] = 'hdfs://0.0.0.0/'

r = search(
  :node,
  "chef_environment:#{node.chef_environment} AND " \
    "hadoop_cluster-name:#{node['hadoop']['cluster-name']} AND " \
    '(recipes:hadoop\\:\\:jobtracker OR ' \
    'roles:jobtracker)'
)

if r.empty?
  fail 'Could not find the jobtracker'
elsif r.count > 1
  fail "Found #{r.count} servers with role jobtracker: " \
    "#{r.map { |s| s['fqdn'] }.join(', ')}"
else
  node.set['hadoop']['hosts']['jobtracker'] = r.first['fqdn']
end

Chef::Log.info 'Hadoop: Set jobtracker to ' \
  "<#{node['hadoop']['hosts']['jobtracker']}>"

# Must come after package install because it depends on a directory
# structure having been created.
include_recipe 'hadoop::default'

node['hadoop']['hdfs-site']['dfs.namenode.name.dir'].each do |dir|
  directory dir do
    owner node['hadoop']['hdfs_user']
    group node['hadoop']['hdfs_group']
    mode 0700
    action :create
    recursive true
  end
end

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
  command 'hadoop fs -mkdir -p /tmp/mapred/system && ' \
    "hadoop fs -chown -R #{node['hadoop']['mapred_user']}:#{node['hadoop']['group']} " \
    '/tmp/mapred'
  user node['hadoop']['hdfs_user']
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /tmp/mapred/system"
  action :nothing
end

execute 'format_namenode' do
  command 'hdfs namenode -format'
  user node['hadoop']['hdfs_user']
  creates "#{node['hadoop']['hdfs-site']['dfs.namenode.name.dir'].last}/current"
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /"
end

service 'hadoop-hdfs-namenode' do
  supports status: :true, restart: :true
  action [:enable, :start]
  notifies :run, 'execute[mkdir_hdfs_tmp]'
  notifies :run, 'execute[create_mr_var_dirs]'
  notifies :run, 'execute[mapred_system_dirs]'
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
      owner 'root'
      group 'root'
      mode 0644
      source 'file://' + Chef::Config['file_cache_path'] + '/hadoop' +
        lib['new_file']
      checksum lib['checksum']
      notifies :restart, 'service[hadoop-hdfs-namenode]'
    end
  end
end
