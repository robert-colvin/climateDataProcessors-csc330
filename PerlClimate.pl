#!/usr/bin/perl
use LWP;
#use strict;
use State;
use Station;
print "This is libwww-perl-$LWP::VERSION\n";
use LWP::Simple;
#use List::MoreUtils qw(first_index);
#importing and storing data from URL
my $stationfile = get 'http://theochem.mercer.edu/csc330/data/station.txt';
my @stationfile = split( /\n/, $stationfile);

my @stations;
my @states;
my @stateNames;
#CREATE COUNTER TO CONTROL WHEN STUFF IS PUSHED TO NEW ARRAYS
$counter = 0;
foreach (@stationfile) 
{
#ONLY ADD TO ARRAY WHEN LOOP IS PAST FIRST LINE TO AVOID INCLUDING HEADER IN ARRAY
	if ($counter)
	{
		#USE | AS DELIMITER TO SEPARATE INTO "SUBSTRINGS"
		@fields = split( /\|/, $_);
		#PUSH DELIMITED DATA INTO ARRAYS  /*[7] is state [0] is id*/
		my $aStation = new Station(@fields[7], @fields[0]);
		push ( @stations, $aStation);
		push (@stateNames, $aStation->getState());

		@stateNames = sort @stateNames;
	}
	#SET COUNTER TO 1 AFTER FIRST LINE CONTAINING HEADER IS PASSED
	$counter = 1;
}
for (my $i = 0; $i<scalar @stateNames; $i++)
{
	my $thisState = @stateNames[$i];
	
	if ($i > 0)
	{
		my $lastState = @stateNames[$i-1];
		
		if ($thisState ne $lastState)
		{
			my $aState = new State($lastState, 0 , 0.0);
			push (@states, $aState);
		}
	}
}

#--------------------------------------------------------------------------------------------------------------------------
#IMPORT AND STORE DATA FROM DAILY FILE
my $dailyfile = get 'http://theochem.mercer.edu/csc330/data/daily.txt';
my @dailyfile = split( /\n/, $dailyfile);

#RESET COUNTER TO 0
$counter = 0;

foreach (@dailyfile) 
{
	if ($counter)
	{
		#USE , AS DELIMITER TO SEPARATE INTO "SUBSTRINGS"
		@fields = split( /\,/, $_);
		#PUSH DELIMITED DATA INTO ARRAYS
		if (@fields[6] ne "M")
		{
			my $thisStation = @fields[0];
			my $thisTemp = @fields[6];
	
			push (@dailyStations, $thisStation);
			push (@temps, $thisTemp);
		}
	}
	#SET COUNTER TO 1 AFTER HEADER LINE IS PASSED
	$counter = 1;
}
for (my $i = 0; $i<scalar @dailyStations;$i++)
{
	my $readings = 1;
	if ($i>0)
	{

		if (scalar @dailyStations - $i == 1)
		{
			push (@finalStations, @dailyStations[$i]);
			push (@finalTemps, @temps[$i]);
			push (@readings, $readings);
		}

		if (@dailyStations[$i] eq @dailyStations[$i-1])
		{
			@temps[$i]+=@temps[$i-1];
			$readings++;
		}
		elsif (@dailyStations[$i] ne @dailyStations[$i-1])
		{
			push (@finalStations, @dailyStations[$i-1]);
			push (@finalTemps, @temps[$i-1]);
			push (@readings, $readings);
			$readings = 1;
			
		}
	}
}
for (my $i - 0; $i<scalar @finalStations; $i++)
{
	foreach $sObj (@stations)
	{
		if (@finalStations[$i] eq $sObj->getStation())
		{
			my $sObjState = $sObj->getState();
		
			foreach $stObj (@states)
			{
				if ($sObjState eq $stObj->getState())
				{
					$stObj->addTemp(@finalTemps[$i], @readings[$i]);
				}
			}
		}
	}
}

foreach (@states)
{
	print $_->getState(). ' ' . $_->getReadings() . ' ' .($_->getTemp()) . "\n";#/($_->getReadings());
}
=o
			foreach $this (@stations)
			{
				if ($this->getStation() eq $thisStation)
				{
					my $thisState = $this->getState();
					
					foreach $that (@states)
					{
						if ($that->getState() eq $thisState)
						{
							$that->addTemp($thisTemp);
						}
					}
				}
			}



sub makeUnique
{
	my %seen;
	return grep {!$seen{$_}++} @_;	
}

















