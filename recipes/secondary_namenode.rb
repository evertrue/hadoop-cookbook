# coding=utf-8

include_recipe 'hadoop::default'

package 'hadoop-hdfs-secondarynamenode' do
  version node['hadoop']['package_version']
end
