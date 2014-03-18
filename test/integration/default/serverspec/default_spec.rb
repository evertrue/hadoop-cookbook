# Encoding: utf-8
require 'spec_helper'

describe 'Hadoop' do
  describe package('hadoop-hdfs-namenode') do
    it { should be_installed }
  end

  %w(
    /usr/lib/hadoop
    /usr/lib/hadoop-hdfs
    /usr/lib/hadoop-0.20-mapreduce
  ).each do |dir|
    %w(
      guava-11.0.2.jar
      jackson-core-asl-1.8.8.jar
      jackson-jaxrs-1.8.8.jar
      jackson-mapper-asl-1.8.8.jar
      jackson-xc-1.8.8.jar
    ).each do |deleted_file|
      describe file("#{dir}/lib/#{deleted_file}") do
        it { should_not be_file }
      end
    end

    %w(
      guava-14.0.1.jar
      jackson-core-asl-1.9.12.jar
      jackson-jaxrs-1.9.12.jar
      jackson-mapper-asl-1.9.12.jar
      jackson-xc-1.9.12.jar
    ).each do |created_file|
      describe file("#{dir}/lib/#{created_file}") do
        it { should be_file }
      end
    end
  end

  [
    8020,
    8021,
    50_030,
    50_070
  ].each do |test_port|
    describe port(test_port) do
      it { should be_listening }
    end
  end
end

describe 'HDFS' do
  describe command('/usr/bin/hdfs dfs ' \
    '-stat /var/lib/hadoop-hdfs/cache/mapred/mapred/staging') do
    # This (the output of hdfs dfs -stat) is actually a date string.
    # it should only show up if the file (which is created by our recipe)
    # actually exists.
    it { should return_stdout(/20\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/) }
  end
end
