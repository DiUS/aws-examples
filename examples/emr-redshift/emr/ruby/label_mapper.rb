#!/usr/bin/env ruby1.9.1

require 'nokogiri'

current_record = ''

ARGF.each do |line|
  if line =~ /^(.*<\/label>)(.*)$/
    current_record += $1
    xml_record = Nokogiri::XML(current_record)

    id = xml_record.xpath("/label/id").text
    name = xml_record.xpath("/label/name").text
    numb_sublabels = xml_record.xpath("/labels/sublabel/label").count
    numb_urls = xml_record.xpath("/label/urls/url").count

    unless id.empty? || name.empty?
      puts [id, name, numb_sublabels, numb_urls].join("\t")
      $stderr.puts("reporter:counter:labels,count,1")
    end

    current_record = "#{$2}"
  else
    current_record += line
  end
end
