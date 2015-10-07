#!/usr/bin/ruby
require 'open-uri'

stationfile = open ('http://theochem.mercer.edu/csc204/data/station.txt')
stationdata = stationfile.read

stationlines = stationdata.split(/\n/)

stationid = []
for line in stationlines
	stationid << (line.split(/\|/))[0]
end

puts stationid
