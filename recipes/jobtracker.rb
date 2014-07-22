# coding=utf-8

include_recipe 'hadoop::repo'

node.set['hadoop']['hosts']['jobtracker'] = node['fqdn']

package 'hadoop-0.20-mapreduce-jobtracker'

include_recipe 'hadoop::default'

execute 'create_user_dir' do
  command 'hadoop fs -mkdir /user'
  user node['hadoop']['hdfs_user']
  not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /user"
  action :nothing
end

node['etc']['passwd'].select { |u, u_conf| u_conf['uid'] >= 5000 }.each do |user, user_conf|
  execute "create_mapred_user_#{user}" do
    command "hadoop fs -mkdir /user/#{user} && " +
      "hadoop fs -chown #{user} /user/#{user}"
    not_if "sudo -u #{node['hadoop']['hdfs_user']} hadoop fs -ls /user/#{user}"
    user node['hadoop']['hdfs_user']
    subscribes :run, 'execute[create_user_dir]'
    action :nothing
  end
end

service 'hadoop-0.20-mapreduce-jobtracker' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
  notifies :run, 'execute[create_user_dir]'
end

%w(
  lib_dir
  mapred_lib_dir
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
      notifies :restart, 'service[hadoop-0.20-mapreduce-jobtracker]'
    end
  end
end
