#!/usr/bin/env ruby1.9.1

# This is required because StreamXmlRecordReader emits duplicate records in Hadoop 1.0.3
# See also https://issues.apache.org/jira/browse/MAPREDUCE-577

require 'nokogiri'

last_key = nil

ARGF.each do |line|
  if last_key != nil && last_key != line
    puts last_key
  end
  last_key = line
end
