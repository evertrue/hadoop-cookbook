node.set['hadoop']['hdfs-site']['dfs.namenode.name.dir'] = node['hadoop']['data_dir'] + "/nn"

directory node['hadoop']['hdfs-site']['dfs.namenode.name.dir'] do
  owner node['hadoop']['hdfs_user']
  group node['hadoop']['hdfs_group']
  mode "0700"
  action :create
  recursive true
end

node.set['hadoop']['hdfs-site']['dfs.namenode.http-address'] = '0.0.0.0:50070'
node.set['hadoop']['hosts']['namenode'] = node['fqdn']

package "hadoop-hdfs-namenode"

include_recipe "hadoop::default"

execute "mkdir_hdfs_tmp" do
  command "hadoop fs -mkdir /tmp && " +
    "hadoop fs -chmod -R 1777 /tmp"
  user node['hadoop']['hdfs_user']
  action :nothing
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /tmp"
end

execute "create_mr_var_dirs" do
  command "hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging && " +
   "hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging && " +
   "hadoop fs -chown -R #{node['hadoop']['mapred_user']} /var/lib/hadoop-hdfs/cache/mapred/mapred"
  user node['hadoop']['hdfs_user']
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /var/lib/hadoop-hdfs/cache/mapred/mapred/staging"
  action :nothing
end

execute 'mapred_system_dirs' do
  command 'hadoop fs -mkdir /tmp/mapred/system && ' +
    "hadoop fs -chown #{node['hadoop']['mapred_user']}:#{node['hadoop']['group']} /tmp/mapred/system"
  user node['hadoop']['hdfs_user']
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /tmp/mapred/system"
  action :nothing
end

execute "format_namenode" do
  command "hadoop namenode -format"
  user node['hadoop']['hdfs_user']
  creates "#{node['hadoop']['hdfs-site']['dfs.namenode.name.dir']}/current"
  action :nothing
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /"
  notifies :run, 'execute[mkdir_hdfs_tmp]'
  notifies :run, 'execute[create_mr_var_dirs]'
  notifies :run, 'execute[mapred_system_dirs]'
end

%w{
  hadoop-hdfs-namenode
}.each do |hadoop_svc|
  service hadoop_svc do
    supports :status => :true, :restart => :true
    action :enable
    notifies :run, "execute[format_namenode]"
  end
end
