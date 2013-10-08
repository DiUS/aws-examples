#!/usr/bin/env ruby1.9.1

require 'nokogiri'

current_record = ''

ARGF.each do |line|
  if line =~ /^(.*<\/release>)(.*)$/
    current_record += $1
    xml_record = Nokogiri::XML(current_record)

    id = xml_record.xpath("/release/@id")
    title = xml_record.xpath("/release/title").text
    released = xml_record.xpath("/release/released").text
    if released =~ /^(\d{4}).*$/
      release_year = $1
    else
      release_year = "NULL"
    end

    unless id.empty? or title.empty?
      puts [id, title, release_year].join("\t")
      $stderr.puts("reporter:counter:releases,count,1")
    end

    current_record = "#{$2}"
  else
    current_record += line
  end
end
