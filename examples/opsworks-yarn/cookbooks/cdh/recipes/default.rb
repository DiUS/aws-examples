
include_recipe "apt"

apt_repository "cloudera-cdh#{node[:cdh][:hadoop][:version]}" do
  uri "[arch=amd64] http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh"
  key "http://archive.cloudera.com/cdh4/ubuntu/lucid/amd64/cdh/archive.key"
  distribution "precise-cdh#{node[:cdh][:hadoop][:version]}"
  components [ "contrib" ]
  deb_src true
  action :add
end

package "hadoop-client"

hadoop_conf_dir = "/etc/hadoop/conf.chef"
directory hadoop_conf_dir do
  mode 0755
  owner "root"
  group "root"
  action :create
  recursive true
end

node.default[:cdh][:hadoop][:namenode][:host] = node[:opsworks][:layers]['hdfs-primary'][:instances].first[:private_dns_name]

template "#{hadoop_conf_dir}/core-site.xml" do
  source "core-site.xml.erb"
  owner "hdfs"
  group "hdfs"
  action :create
  variables({ :options => node[:hadoop][:core_site] })
end

execute "update hadoop alternatives" do
  command "update-alternatives --install /etc/hadoop/conf hadoop-conf #{hadoop_conf_dir} 50"
end
