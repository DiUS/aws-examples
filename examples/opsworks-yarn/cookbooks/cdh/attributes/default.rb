default[:cdh][:version] = '4.4.0'
default[:cdh][:hadoop][:version] = '2.0.0'

default[:cdh][:hadoop][:namenode][:host] = "localhost"
default[:cdh][:hadoop][:namenode][:port] = 8020

default[:cdh][:hadoop][:core_site]['hadoop.tmp.dir'] = "/var/lib/hadoop/tmp"
default[:cdh][:hadoop][:core_site]['fs.default.name'] = "hdfs://#{node[:cdh][:hadoop][:namenode][:host]}:#{node[:cdh][:hadoop][:namenode][:port]}"
