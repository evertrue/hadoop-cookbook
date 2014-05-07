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
