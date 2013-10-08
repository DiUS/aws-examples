#!/usr/bin/env ruby1.9.1

require 'nokogiri'

current_record = ''

ARGF.each do |line|
  if line =~ /^(.*<\/release>)(.*)$/
    current_record += $1
    xml_record = Nokogiri::XML(current_record)

    time_id = 0
    if xml_record.xpath("/release/released").text =~ /^(\d{4}).*$/
      time_id = $1.to_i
    end

    if time_id != 0
      xml_record.xpath("/release/artists/artist").each do |artist|
        puts [artist.xpath("id").text, time_id, 1].join("\t")
        $stderr.puts("reporter:counter:artist_facts,count,1")
      end
    end

    current_record = "#{$2}"
  else
    current_record += line
  end
end
