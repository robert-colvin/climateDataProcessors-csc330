#!/usr/bin/python
import urllib
import string

# define lests
lines = []
stationid = []
state = []

stationfile = urllib.urlopen("http://theochem.mercer.edu/csc330/data/daily.txt")
data = stationfile.read()

lines = data.split('\n')

for line in lines:
	stationid.append(line.split(',')[0])
	#state.append(line.split('|')[7])

for i in range(0,len(stationid)):
	print stationid[i] #+ " " + state[i]
