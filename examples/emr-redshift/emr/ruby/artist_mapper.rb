#!/usr/bin/env ruby1.9.1

require 'nokogiri'

current_record = ''

ARGF.each do |line|
  if line =~ /^(.*<\/artist>)(.*)$/
    current_record += $1
    xml_record = Nokogiri::XML(current_record)

    id = xml_record.xpath("/artist/id").text
    name = xml_record.xpath("/artist/name").text
    numb_aliases = xml_record.xpath("/artist/aliases/name").count

    puts [id, name, numb_aliases].join("\t")
    $stderr.puts("reporter:counter:artists,count,1")

    current_record = "#{$2}"
  else
    current_record += line
  end
end
