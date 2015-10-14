#!/usr/bin/python
import urllib
import string

# define lests
dlines = []
slines = []
#initialize empty hashes for data
stationdict = {}
statedict = {}
readingdict={}
#reading in URL
stationfile = urllib.urlopen("http://theochem.mercer.edu/csc330/data/station.txt")
dailyfile = urllib.urlopen("http://theochem.mercer.edu/csc330/data/daily.txt")
#store URL data in object
sdata = stationfile.read()
ddata = dailyfile.read()
#take entirety of URL and split it up at every new line, use pop() to get rid of blank line at end
slines = sdata.split('\n')
slines.pop()
dlines = ddata.split('\n')
dlines.pop()
#store relevant data in hash with key = stationid and value = the associated state, create counter and increment so that header line is not read
counter = 0
for line in slines:
	if counter > 0:
		stationdict[line.split('|')[0]] = line.split('|')[7]
	counter+=1
#create array of states from stationdict and add to statedict and readingdict if they are not present already so that keys are unique, values are set to 0 for later addition
t = stationdict.values()
for state in t:
	if not statedict.has_key(state):
		statedict[state] = 0
		readingdict[state]=0.0
#reset counter to 0 for next loop doing the same thing
counter = 0
#store relevant data from daily txt in statedict w/ key = state and value = totaltemperature, and in readingdict w/ key=state and value=#ofreadings, skips header line w/ counter
for line in dlines:
	if counter > 0:
		if line.split(',')[6] != "M":
			thistemp=float(line.split(',')[6])
			thisstation = line.split(',')[0]
			if stationdict.has_key(thisstation):
				statedict[stationdict[thisstation]] += thistemp	
				readingdict[stationdict[thisstation]] += 1.0
	counter+=1	
#removes states that have no readings from hashes
for state in readingdict.keys():
	if readingdict[state] == 0:
		del readingdict[state]
		del statedict[state]
#create an array for states, total temperatures, and #of readings
states = statedict.keys()
temps = statedict.values()
readings = readingdict.values()
#sort arrays by average temperature, keep them all parallel
for i in range(0, len(temps)-1):
	for j in range (i+1, len(temps)):
		if temps[j]/readings[j] <= temps[i]/readings[i]:
			shold = states[j]
			thold = temps[j]
			rhold = readings[j]
			states[j] = states[i]
			temps[j] = temps[i]
			readings[j] = readings[i]
			states[i] = shold
			temps[i] = thold
			readings[i] = rhold
#print formatted output header
print("%5s %8s %8s" % ("STATE" , "READINGS", "AVG TEMP"))
#print formatted data output
for i in range(0,len(states)):
	print("%3s %8d %8.1f" % (states[i] , int(readings[i]), temps[i]/readings[i]))
