#!/usr/bin/perl
use LWP;
#use strict;
print "This is libwww-perl-$LWP::VERSION\n";
use LWP::Simple;
#use List::MoreUtils qw(first_index);
#importing and storing data from URL
my $stationfile = get 'http://theochem.mercer.edu/csc330/data/station.txt';
my @stationfile = split( /\n/, $stationfile);

my %stations;
my %states;
my %readings;
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
		$stations{@fields[0]} = @fields[7];
	}
	#SET COUNTER TO 1 AFTER FIRST LINE CONTAINING HEADER IS PASSED
	$counter = 1;
}

my @stations = values %stations;
for (my $i = 0; $i<scalar @stations;$i++)
{
	if (!exists $states{@stations[$i]})
	{
		$states{@stations[$i]} = 0.0;
		$readings{@stations[$i]} = 0.0;
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
			
			if (exists $stations{$thisStation})
			{
				$states{$stations{$thisStation}} += $thisTemp;
				$readings{$stations{$thisStation}} += 1;
			}
		}
	}
	#SET COUNTER TO 1 AFTER HEADER LINE IS PASSED
	$counter = 1;
}

foreach (keys %readings)
{
	if ($readings{$_} == 0)
	{
		delete $readings{$_};
		delete $states{$_};
	}
}

my @states_f = keys %states;
my @temps_f = values %states;
my @readings_f = values %readings;

for (my $i = 0; $i<scalar @readings_f-1; $i++)
{
	for (my $j = $i+1; $j<scalar @readings_f; $j++)
	{
		if (@temps_f[$i]/@readings_f[$i]>= @temps_f[$j]/@readings_f[$j])
		{
			my $hold1 = @readings_f[$j];
			my $hold2 = @states_f[$j];
			my $hold3 = @temps_f[$j];
			@readings_f[$j] = @readings_f[$i];
			@states_f[$j] = @states_f[$i];
			@temps_f[$j] = @temps_f[$i];
			@readings_f[$i] = $hold1;
			@states_f[$i] = $hold2;
			@temps_f[$i] = $hold3;
		}
	}
}
printf("%5s %8s %8s\n", "STATE", "READINGS", "AVG TEMP");
for (my $i = 0; $i<scalar @readings_f;$i++)
{
	printf("%3s %8d %8.1f\n", @states_f[$i], @readings_f[$i], @temps_f[$i]/@readings_f[$i]);
}

















