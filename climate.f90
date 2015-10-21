program climate
!I USE LITERALLY EVERY ONE OF THESE VARIABLES
character*5::dailystation, station
character*12::x2,x3,x4,x5,x6
character*4::temp
character*100::line
character*2::state, laststate, thisstate
character*150, allocatable, dimension(:)::lines
character*5, allocatable, dimension(:)::stations
character*2, allocatable, dimension(:)::stateids
character*2, allocatable, dimension(:)::ustates
real, allocatable, dimension(:)::temps, averages
real::temperature, hold
integer, allocatable, dimension(:)::readings
integer::numpts, allocatestatus, counter, i,timesfound, spot, location, put, location1, q, test
logical found
call system("mkdir /tmp/colvin_rc")
call system("mkdir /tmp/colvin_rc/data")
call system("wget -O /tmp/colvin_rc/data/station.txt -q http://theochem.mercer.edu/csc330/data/station.txt")
call system("wget -O /tmp/colvin_rc/data/daily.txt -q http://theochem.mercer.edu/csc330/data/daily.txt")

!READ STATION FILE
open(unit = 15, status = 'old', file = "/tmp/colvin_rc/data/station.txt")

numpts = 0
allocatestatus = 1
counter = 0
!READ EACH LINE FROM STATION FILE BUT DONT DO ANYTHING UNLESS PAST HEADER;INCREASE NUMPTS FOR ALLOCATION WITH EACH LINE PAST HEADER
do while (allocatestatus /= -1)
	read (15,'(a100)',iostat=allocatestatus)line
	if(counter > 0)then
		if(allocatestatus==0) then
			numpts = numpts+1
		else 
			rewind(15)
			
		end if
	end if
	counter = counter+1
end do
!ALLOCATE ARRAYS FOR STATION# AND STATE NAMES BASED ON NUMBER OF LINES AFTER STATION FILE HEADER
allocate(stations(numpts), stat = allocatestatus)
allocate(stateids(numpts), stat = allocatestatus)
!allocate(stateids(numpts-1), stat = allocatestatus)
!allocatestatus = 0 if everythin is good
if (allocatestatus /= 0) stop "error in array location"

numpts = 0
allocatestatus = 1
counter = 0
!GO THRU STATION FILE AGAIN FOR ACTUAL STUFF
do while (allocatestatus /= -1)
	read (15,'(a100)',iostat=allocatestatus)line
	if(counter > 0)then
		if(allocatestatus==0) then
			numpts = numpts +1
			!HOMEMADE, ONLY COPIED FROM JAVA PARSER
			found = .false.
			location2 = 0
			location1 = 0
			location3 = 0
			timesfound = 0
			!GO THRU EACH CHAR ON LINE UNTIL ITS A |, SAVE THE INDEX IN VARIABLE IN CASE OF USE
			do while (line(location1:location1).ne.'|'.and.location1/=100)
				location1 = location1+1
			end do
			!NEXT INDEX LOCATIN PICKS UP NEXT TO WHERE LAST ONE LEFT OFF
			location2 = location1+1
			!COUNT # OF TIMES | HAS BEEN ENCOUNTERED
			timesfound = timesfound+1
			!CONTINUE GOING THROUGH LINE UNTIL WE HIT THE | IN FRONT OF THE STATE, SAVE INDEX IN CASE OF USE
			do while (timesfound.ne.7)
				if (line(location2:location2).eq.'|')then
					timesfound = timesfound+1
				end if
				location2 = location2+1
			end do
			!NEXT INDEX STARTS WHERE LAST ONE LEAVES OFF
			location3 = location2+1
			!GO THRU LINE UNTIL | AFTER STATE IS FOUND AND EXIT LOOP, SAVE INDEX IN CASE OF USE
			do while (timesfound.ne.8)
				if (line(location3:location3).eq.'|')then
					timesfound = timesfound+1
					exit
				end if
				location3 = location3+1
			end do
			!IF INDEX OF START OF STATE IS ACTUALLY VALID...
			if (line(location2:location2).ne.'|'.and.line(location2:location2).ne.'\0')then
				!STORE SUBSTRING FROM LOCATION2 TO LOCATION3 AS STATE AND...
				stateids(numpts) = line(location2:location3-1)
				!STORE SUBSTRING FROM BEGINNING OF LINE TO FIRST | AS STATION
				stations(numpts) = line(1:location1-1)
			end if
		else 
			close(15)
			
		end if
	end if
	counter = counter+1
end do
!SORT STATEIDS ALPHABETICALLY AND STATIONS SIMULTANEOUSLY BECAUSE THEY MUST STAY PARALLEL
do i = 1, size(stateids)-1
	do j = i+1, size(stateids)
		if (stateids(i).ge.stateids(j))then

			state = stateids(j)
			station = stations(j)
			stateids(j) = stateids(i)
			stations(j) = stations(i)
			stateids(i) = state
			stations(i) = station
		end if
	end do
end do
!MORE SPACE WAS ALLOCATED FOR ARRAYS THAN WAS NEEDED SO LOOP ARRAY OF STATES AND FIND INDEX OF FIRST ACTUAL STATE, SAVE IT
test = 1
do i=1, size(stateids)
	if(stateids(i).eq.'AK')then
		test = i
		exit
	end if
end do
!LOOP STATES ARRAY AND IF INDEX HAS PASSED THE FIRST STATE COMPARE STATE AT CURRENT INDEX W/ LAST STATE TO CHECK FOR REPEATS, WHICH ARE NOT NEEDED
put = 0
do i = 1, size(stateids)
	thisstate = stateids(i)
	if (i>test)then
		laststate = stateids(i-1)
		if (laststate.ne.thisstate)then
			!WHEN WE KNOW THAT A STATE IS DIFFERENT FROM THE LAST, ADD SPACE FOR ALLOCATION
			put = put+1
		end if
		if (i==size(stateids))then
			put=put+1
		end if
	end if
end do
!ALLOCATE SPACE FOR ARRAYS NEEDED FOR PROCESSING
allocate(ustates(put), stat = allocatestatus)
allocate(temps(put), stat = allocatestatus)
allocate(readings(put), stat = allocatestatus)
allocate(averages(put), stat = allocatestatus)
if (allocatestatus /=0) stop "error in array ustates location"
!SAME AS LAST LOOP BUT PUTTING STATES INTO NEW ARRAY SO THAT ALL STATES IN IT ARE UNIQUE(NO REPEATS)
put = 1
do i = 1, size(stateids)
	thisstate = stateids(i)
	if (i>test)then
		laststate = stateids(i-1)
		if (laststate.ne.thisstate)then
			ustates(put) = laststate
			put = put+1
		end if
		if (i==size(stateids))then
			ustates(put)=thisstate
		end if
	end if
end do
!POPULATE MATHY ARRAYS WITH ZEROES
do i = 1, size(readings)
	readings(i) = 0
	temps(i) = 0.0
end do
!----------------------------------------------------------------------------------------------
!DAILY WORK
open(unit = 15, status = 'old', file = "/tmp/colvin_rc/data/daily.txt")
!READ DAILY FILE
numpts = 0
allocatestatus = 1
counter = 0
do while (allocatestatus /= -1)
	!READ EACH LINE INTO A VARIABLE
	read (15,'(a100)',iostat=allocatestatus)line
	!ONLY CARE IF WE PASS THE HEADER
	if (counter>0)then
		if(allocatestatus == 0) then
			!SINCE FORTRAN IS SO AGREEABLE ABOUT COMMA DELIMITERS, I CAN JUST ASSIGN EACH FIELD FROM LINE INTO VARIABLES LIKE THIS
			read(line, *)dailystation,x2, x3, x4, x5, x6, temp
			!WE ONLY CARE IS THE TEMPERATURE FIELD IS NOT MISSING SO DO NOTHING UNLESS ITS NOT AN 'M'
			if (temp.ne.'M')then 
				!IF ITS NOT MISSING ITS A NUMBER SO PARSE IT INTO A DOUBLE AND STORE IT IN TEMPERATURE VARIABLE
				read(temp, '(f4.0)')temperature
				!LOOP STATIONS
				do i=1, size(stations)
					!IF THE STATION FOR THIS LINE EXISTS IN THE STATIONS ARRAY
					if (dailystation.eq.stations(i))then
						!GRAB STATE FOR THAT STATION USING INDEX SINCE THEY'RE PARALLEL
						state = stateids(i)
						!LOOP UNIQUE ARRAY OF STATES
						do q=1, size(ustates)
							!FIND WHERE THE STATE FOR THIS STATION IS IN ARRAY OF UNIQUE STATES
							if (ustates(q).eq.state)then
								!USE THAT INDEX TO ADD 1 TO NUMBER OF READINGS FOR THAT STATE SINCE ITS PARALLEL
								readings(q) = readings(q) + 1
								!AND ADD THE TEMP FROM THIS LINE TO THE TEMPERATURE FOR THAT STATE SINCE ITS PARALLEL
								temps(q) = temps(q) +temperature
								!DITCH THIS LOOP, THERE'S NO MORE WORK TO BE DONE FOR THIS LINE
								exit
							end if
						end do
						exit
					end if
				end do
			end if
		else
			close(15)
		end if
	end if
	counter = counter+1
end do
!CALCULATE AVERAGE TEMP FOR EVERY STATE AND STORE IT IN ANOTHER ARRAY PARALLEL TO TE STATES THEMSELVES
do i = 1, size(temps)
	averages(i) = (temps(i)/readings(i))
end do
!SORT STATES, READINGS, AND AVERAGES BY AVG TEMP
do i =1, size(averages)-1
	do j=i+1, size(averages)
		if (averages(i).ge.averages(j))then
			hold = averages(j)
			state = ustates(j)
			test = readings(j)
			averages(j) = averages(i)	
			ustates(j) = ustates(i)
			readings(j) = readings(i)
			averages(i) = hold
			ustates(i) = state
			readings(i) = test
		end if
	end do
end do
!PRINT IT ALL OUT; WE MADE IT, BOYS
do i = 1, size(ustates)
	if (readings(i)>0)then
		print*, ustates(i), ' ' , readings(i), ' ' , averages(i)
	end if
end do
!ANNIHILATE THE FOLDER WE THE STATION AND DAILY INFO IN IT
call system("rm -rf /tmp/colvin_rc")
!RETIRE; BECOME A HERMIT
end program !climate
