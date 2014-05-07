# coding=utf-8

case node['platform_family']
when 'debian'
  include_recipe 'apt'
end

case node['kernel']['machine']
when 'x86_64'
  arch_name = 'amd64'
else
  arch_name = node['kernel']['machine']
end

apt_repository 'cloudera' do
  uri "http://archive.cloudera.com/#{node['hadoop']['version']}" \
    "/#{node['platform']}" \
    "/#{node['lsb']['codename']}" \
    "/#{arch_name}" \
    '/cdh'
  distribution "#{node['lsb']['codename']}-#{node['hadoop']['version']}"
  arch arch_name
  components ['contrib']
  key "http://archive.cloudera.com/#{node['hadoop']['version']}" \
    "/#{node['platform']}" \
    "/#{node['lsb']['codename']}" \
    "/#{arch_name}" \
    '/cdh' \
    '/archive.key'
end
