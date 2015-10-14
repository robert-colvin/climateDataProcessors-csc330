#!/usr/bin/ruby
require 'open-uri'
#take URL and store its data
stationfile = open('http://theochem.mercer.edu/csc204/data/station.txt')
dailyfile = open('http://theochem.mercer.edu/csc204/data/daily.txt')
stationdata = stationfile.read
dailydata = dailyfile.read
#delimit URL file by line and store in arrays
stationlines = stationdata.split(/\n/)
dailylines = dailydata.split(/\n/)
#create empty hashes and array for data
state_hash = Hash.new(0.0)
station_hash = Hash.new
readings_hash = Hash.new(0.0)
averages = Array.new
#create couner to skip header line
counter = 0
#read every line after header from array of URL and store data in hash w/ key = station and value = state
for line in stationlines
	if (counter>0)
		station_hash[(line.split(/\|/))[0]] = (line.split(/\|/))[7]
	end
	counter+=1
end
#create array of states from station_hash
boxofstates = station_hash.keys
#populate state and reading hashes with state keys and values of 0 for addition later
for stateg in boxofstates
	if not state_hash.has_key?(stateg)
		state_hash[stateg] = 0.0
		readings_hash[stateg] = 0.0
	end
end
#reset counter to 0
counter = 0
#read every line after header from array of URL
for line in dailylines
	if (counter>0)
		if (line.split(/\,/)[6] != "M")
			thistemp = Float(line.split(/\,/)[6])
			thisstation = line.split(/\,/)[0]
			#if the stationid from this line exists in station_hash then...
			if (station_hash.has_key?(thisstation))
				#add temperature to total temperature for the associated state...
				state_hash[station_hash[thisstation]] += thistemp
				#and increment the number of readings for that state
				readings_hash[station_hash[thisstation]] += 1.0
			end
		end
	end
	counter+=1
end
#read thru state keys in readings_hash, if that state has 0 reading remove from readings hash and state/temperature hash
for army in readings_hash.keys
	if (readings_hash[army] == 0)
		readings_hash.delete(army)
		state_hash.delete(army)
	end
end
#create array for state, total temperature, and each state's readings
states = state_hash.keys
temps = state_hash.values
readings = readings_hash.values
#reset counter to 0 to use as index
counter = 0
#calculate average temperature for each state and append to averages array
while counter < temps.length
	averages.push(temps[counter]/readings[counter])
	counter+=1	
end
#turn averages array into an array of parallel elements from itself, readings, and states; sort it by the first element of each element (the avg temp)
#then separate each element back into its separate parallel arrays and overwrite original arrays with the now sorted values
averages, readings, states = averages.zip(readings, states).sort.transpose
#print header line
printf "%5s %8s %8s\n", "STATE", "READINGS", "AVG TEMP"
#reset counter to 0 for indexing
counter = 0
#print out sorted data
while counter < states.length
	printf "%3s %8d %8.1f\n", states[counter], readings[counter], averages[counter]
	counter+=1
end


