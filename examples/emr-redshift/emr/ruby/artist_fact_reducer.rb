#!/usr/bin/env ruby1.9.1

current_key = nil
current_count = 0

ARGF.each do |line|
  delim_pos = line.rindex("\t")
  key = line.chomp.slice(0, delim_pos)
  count = line.chomp.slice(delim_pos + 1, line.length).to_i

  if current_key != key
    puts "#{current_key}\t#{current_count}" unless current_key == nil
    current_key = key
    current_count = 0
  end

  current_count += count
end

puts "#{current_key}\t#{current_count}" unless current_key == nil
