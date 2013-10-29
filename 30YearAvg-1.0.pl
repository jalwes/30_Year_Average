#!c:/perl/bin/perl.exe -w
#written by Jon Alwes & Terry Ortel
#June 6th, 2013

use strict;
use diagnostics;

										########################################################
										######********************************************######
										#**********   GLOBAL VARIABLE DECLARATIONS   **********#
										#**********      EDIT THESE AS NEEDED        **********#       
										######********************************************######
										########################################################
								#		
# ***** Hashes *****#									
my %dewpointHash = ();
my %hourlySolarHash = ();
my %hourlyTempHash = ();
my %hourlyWindHash = ();

# ***** Files ******# 
my $dewpointFile = 'Argonne_Hourly_Data\Argonne_hourly_dewpoint.exp';
my $hourlySolarFile = 'Argonne_Hourly_Data\Argonne_hourly_solar.exp';
my $hourlyTempFile = 'Argonne_Hourly_Data\Argonne_hourly_temperature.exp';
my $hourlyWindFile = 'Argonne_Hourly_Data\Argonne_hourly_unadjusted_wind.exp';


										#######################################################
										######*************************************############
										###******      BEGINNING OF CODE   ********############
										#######################################################
print "Retrieving data...\n";										
								
# **** Populate hashes *****#
print "Averaging dewpoint...\n";
%dewpointHash = getAverages( $dewpointFile );
print "Averaging hourly solar radiation...\n";
%hourlySolarHash = getAverages( $hourlySolarFile );
print "Averaging hourly temperature...\n";
%hourlyTempHash = getAverages( $hourlyTempFile );
print "Averaging hourly wind...\n";
%hourlyWindHash = getAverages( $hourlyWindFile );

#######################################################################################
###   Write averages to individual files. This is necessary to order the data  ########
###   We can't permanently sort key/value pairs so in the following loops we   ########
###   are sorting the hashes and printing the results into individual files to ########
###   maintain order                                                           ########
#######################################################################################

open (DEWFILE, ">dewFile.txt"); 
my $entry = "";
foreach $entry (sort numerically keys %dewpointHash) {
	print DEWFILE "$entry: @{ $dewpointHash{$entry} }\n";
}
close (DEWFILE);

open (SOLARFILE, ">solarFile.txt");
$entry = "";
foreach $entry ( sort numerically keys %hourlySolarHash ) {
	print SOLARFILE "$entry: @{ $hourlySolarHash{$entry} }\n";
}
close (SOLARFILE);

open (HOURLYTEMPFILE, ">hourlyTemp.txt");
$entry = "";
foreach $entry ( sort numerically keys %hourlyTempHash ) {
	print HOURLYTEMPFILE "$entry: @{ $hourlyTempHash{$entry} }\n";
}
close (HOURLYTEMPFILE);

open (HOURLYWINDFILE, ">hourlyWind.txt");
$entry = "";
foreach $entry ( sort numerically keys %hourlyWindHash ) {
	print HOURLYWINDFILE "$entry: @{ $hourlyWindHash{$entry} }\n";
}
close (HOURLYWINDFILE);

#######################################
#######################################
### **** Create Output File ***** #####
#######################################

print "Writing output file...\n";

open (OUTPUTFILE, ">output.txt");

#Print header columns to file
print OUTPUTFILE "JDA T_LST TaC_60m spd_60m spdV60m dirV60m sdir60m  e__10m   rh_10m Tdp_10m TaC_10m spd_10m spdV10m dirV10m sdir10m baroKPa radW/m2 netW/m2 Ta_diff asp_60m asp_10m battVDC precpmm T_LST JDA\n";

open (DEWFILE, "<dewFile.txt");
open (SOLARFILE, "<solarFile.txt");
open (HOURLYTEMPFILE, "<hourlyTemp.txt");
open (HOURLYWINDFILE, "<hourlyWind.txt");

#create an array of filehandles
my @fh = ("DEWFILE", "HOURLYTEMPFILE", "HOURLYWINDFILE", "SOLARFILE");
  
#Julian day variable
my $JDA = 001;
my $hour = 00;
my $minute = 00;
my $counter = 1;

#while all files have lines left, assign next lines of each file into array @lines
until (grep !defined, my @lines  = map scalar <$_>, @fh) {

	#dewpoint data
	my @dewLine = split (/ /, $lines[0]);
	#get and convert to Celsius
	my $dewData = sprintf("%.2f", ($dewLine[1]-32)/1.8);
	#format
	$dewData = sprintf("%6s", $dewData);
				
	#Hourly temp data
	my @tempLine = split (/ /, $lines[1]);
	#get and convert to celsius
	my $tempData = sprintf("%.2f",($tempLine[1]-32)/1.8);
	#format	
	$tempData = sprintf("%5s", $tempData);
		
	#Hourly wind data
	my @windLine = split (/ /, $lines[2]);
	#get and convert to meters per second
	my $windData = $windLine[1]/39.37 * 12 * 5280 / 900;
	#format
	$windData = sprintf("%.2f",$windData/4);
		
	#solar data
	my @solarLine = split (/ /, $lines[3]);
	#get and convert 
	my $solarData = $solarLine[1]/15/14.3308 * 10000;
	#format	
	$solarData = sprintf("%.2f", $solarData/4);
	$solarData = sprintf("%6s", $solarData);
	
	$JDA = sprintf("%03d", $JDA);
	$hour = sprintf("%02d", $hour);
	$minute = sprintf("%02d", $minute);
	
	#If it's the first time through this loop, we want the first line
	# to be the data from the last day (Julian day 366 at midnight)
	if ($counter == 1) {
		my $dew = sprintf("%.2f", ($dewpointHash{123124}[0]-32)/1.8);
		my $temp = sprintf("%.2f",($hourlyTempHash{123124}[0]-32)/1.8);
		my $wind = sprintf("%.2f", (($hourlyWindHash{123124}[0]) * (1609.344/3600))/4);
		my $solar = sprintf("%6s", sprintf("%.2f", $hourlySolarHash{123124}[0]/4));
		print OUTPUTFILE "$JDA $hour:$minute    -999    -999    -999    -999    -999    -999     -999   $dew   $temp    $wind    -999    -999    -999    -999  $solar    -999    -999    -999    -999    -999    -999 $hour:$minute $JDA\n";
		$counter++;
		$minute += 15;
	}
	
	for (my $count = 0; $count < 4; $count++) {
		if ($minute == 60) {
			$minute = sprintf("%02d", 00);
			$hour++;
			$hour = sprintf("%02d",$hour);
		}
		if ($hour == 24) { 
			$hour = sprintf("%02d", 00);
			$JDA++;
			$JDA = sprintf("%03d", $JDA);
		}
		
		#If it's the last entry in the file, we want to change the time to 00:00 and the Julian day to 001
		if ($JDA < 367) {
			print OUTPUTFILE "$JDA $hour:$minute    -999    -999    -999    -999    -999    -999     -999  $dewData   $tempData    $windData    -999    -999    -999    -999  $solarData    -999    -999    -999    -999    -999    -999 $hour:$minute $JDA\n";
		} else {
			print OUTPUTFILE "001 00:00    -999    -999    -999    -999    -999    -999     -999  $dewData   $tempData    $windData    -999    -999    -999    -999  $solarData    -999    -999    -999    -999    -999    -999 $hour:$minute $JDA\n";
		}
		$minute += 15;
	}
}
   
close (DEWFILE);
close (SOLARFILE);
close (HOURLYTEMPFILE);
close (HOURLYWINDFILE);
close (OUTPUTFILE);

###############################################
#######******************************##########
### 		Output file with no Leap Year    ######
###############################################
###############################################

open (OUTPUTFILEWOUTLEAP, ">outputNoLeap.txt");
#Print header columns to file
print OUTPUTFILEWOUTLEAP "JDA T_LST TaC_60m spd_60m spdV60m dirV60m sdir60m  e__10m   rh_10m Tdp_10m TaC_10m spd_10m spdV10m dirV10m sdir10m baroKPa radW/m2 netW/m2 Ta_diff asp_60m asp_10m battVDC precpmm T_LST JDA\n";

open (DEWFILE, "<dewFile.txt");
open (SOLARFILE, "<solarFile.txt");
open (HOURLYTEMPFILE, "<hourlyTemp.txt");
open (HOURLYWINDFILE, "<hourlyWind.txt");

$JDA = 001;
$counter = 1;
$hour = 00;
$minute = 00;

#while all files have lines left, assign next lines of each file into array @lines
until (grep !defined, my @lines  = map scalar <$_>, @fh) {

	#dewpoint data
	my @dewLine = split (/ /, $lines[0]);
	my $dewData = sprintf("%.2f", ($dewLine[1]-32)/1.8);
	#format
	$dewData = sprintf("%6s", $dewData);
	
	#Hourly temp data
	my @tempLine = split (/ /, $lines[1]);
	my $tempData = sprintf("%.2f", ($tempLine[1]-32)/1.8);
	#format	
	$tempData = sprintf("%5s", $tempData);
	
	#Hourly wind data
	my @windLine = split (/ /, $lines[2]);
	my $windData = $windLine[1]/39.37 * 12 * 5280 / 900;
	$windData = sprintf("%.2f",$windData/4);
		
	#solar data
	my @solarLine = split (/ /, $lines[3]);
	my $solarData = $solarLine[1]/15/14.3308 * 10000;
	#format 
	$solarData = sprintf("%.2f", $solarData/4);
	$solarData = sprintf("%6s", $solarData);
		
	$JDA = sprintf("%03d", $JDA);
	$hour = sprintf("%02d", $hour);
	$minute = sprintf ("%02d", $minute);
	#$minute = sprintf("%02d", $minute);
	
	#If it's the first time through this loop, we want the first line
	# to be the data from the last day (Julian day 366 at midnight)
	if ($counter == 1) {
		my $dew = sprintf("%.2f", ($dewpointHash{123124}[0]-32)/1.8);
		my $temp = sprintf("%.2f",($hourlyTempHash{123124}[0]-32)/1.8);
		my $wind = sprintf("%.2f", (($hourlyWindHash{123124}[0]) * (1609.344/3600))/4);
		my $solar = sprintf("%6s", sprintf("%.2f", $hourlySolarHash{123124}[0]/4));
		print OUTPUTFILEWOUTLEAP "$JDA $hour:$minute    -999    -999    -999    -999    -999    -999     -999   $dew   $temp    $wind    -999    -999    -999    -999  $solar    -999    -999    -999    -999    -999    -999 $hour:$minute $JDA\n";
		$counter++;
		$minute += 15;
	}
	
	my $leapKey = substr $dewLine[0],0,4;
	if ($leapKey != '0229') {
		for (my $count = 0; $count < 4; $count++) {
		if ($minute == 60) {
			$minute = sprintf("%02d", 00);
			$hour++;
			$hour = sprintf("%02d",$hour);
		}
		if ($hour == 24) { 
			$hour = sprintf("%02d", 00);
			$JDA++;
			$JDA = sprintf("%03d", $JDA);
		}
		
		#If it's the last entry in the file, we want to change the time to 00:00 and the Julian day to 001
		if ($JDA < 366) {
			print OUTPUTFILEWOUTLEAP "$JDA $hour:$minute    -999    -999    -999    -999    -999    -999     -999  $dewData   $tempData    $windData    -999    -999    -999    -999  $solarData    -999    -999    -999    -999    -999    -999 $hour:$minute $JDA\n";
		} else {
			print OUTPUTFILEWOUTLEAP "001 00:00    -999    -999    -999    -999    -999    -999     -999  $dewData   $tempData    $windData    -999    -999    -999    -999  $solarData    -999    -999    -999    -999    -999    -999 $hour:$minute $JDA\n";
		}
		$minute += 15;
	}
			
	}
}

close (DEWFILE);
close (SOLARFILE);
close (HOURLYTEMPFILE);
close (HOURLYWINDFILE);
close (OUTPUTFILEWOUTLEAP);

###############################################
######******************************###########
## ** End output without Leap Year block * ###
###############################################


###############################################
######************************#################
## ** Output file with keys and all values **##
### * 		Comment out if not needed        *###
###############################################

open (DEWFILE, "<dewFile.txt");
open (SOLARFILE, "<solarFile.txt");
open (HOURLYTEMPFILE, "<hourlyTemp.txt");
open (HOURLYWINDFILE, "<hourlyWind.txt");

open (OUTPUTWITHKEYS, ">outputWithKeys.txt");
print OUTPUTWITHKEYS " Key        Dewpoint      Hourly Temp      Hourly Wind     Solar Radiation\n\n";
       

until (grep !defined, my @lines  = map scalar <$_>, @fh) {
	#dewpoint data
	my @dewLine = split (/ /, $lines[0]);
	my $dewData = sprintf("%.2f", $dewLine[1]);
	my $dewKey = substr $dewLine[0],0, 6;
	
	#Hourly temp data
	my @tempLine = split (/ /, $lines[1]);
	my $tempData = sprintf("%.2f",$tempLine[1]);
	my $tempKey = substr $tempLine[0],0, 6;
	
	#Hourly wind data
	my @windLine = split (/ /, $lines[2]);
	my $windData = sprintf("%.2f",($windLine[1]));
	my $windKey = substr $windLine[0], 0, 6;
	
	#solar data
	my @solarLine = split (/ /, $lines[3]);
	my $solarData = sprintf("%.2f",$solarLine[1]);
	my $solarKey = substr $solarLine[0], 0, 6;
	
	#if ($dewKey == $tempKey == $windKey == $solarKey) -- doesn't work
	if (($dewKey == $tempKey) && ($tempKey == $windKey) && ($windKey ==  $solarKey)){
		print OUTPUTWITHKEYS "$dewKey:  ";
	}  else { 
		print OUTPUTWITHKEYS "KEYS DON'T MATCH!  ";
	}
	 
	print OUTPUTWITHKEYS "    $dewData           $tempData            $windData              $solarData\n";           
}
close (DEWFILE);
close (SOLARFILE);
close (HOURLYTEMPFILE);
close (HOURLYWINDFILE);
close (OUTPUTFILE);

close (OUTPUTWITHKEYS);
###############################################
#### 		END output with keys block   ##########
###############################################

print "Done.\n";

												##########################################
												######**************************##########
												###### **** Sub Routines *******##########
												##########################################
												##########################################

#Routine to sort numerically
sub numerically { $a <=> $b; }


#This routine will parse the different Argonne files and create a hash of arrays with key/value pairs. The keys will be 
#the date of the data in a mmddhh format and the values will be the data and a counter (used to average later).  
sub getAverages {
	my $fileName = shift;
	my %hash = ();
	
	#where to start data processing
	my $startYear = 1980;
	my $startMonth = 1; 
	my $startDay = 1;
	
	open (MYFILE, $fileName);
	
		while (<MYFILE>) {
			chomp;
			my $year = substr $_, 0, 4;
			
			if ($year =~ /^[0-9]+$/) { #Only read data lines. (If line starts with numeric data)
				
				my $month = substr $_, 5, 2;
				my $day = substr $_, 8, 2;
				my $hour = substr $_, 11, 2;
				my $data = substr $_, 18, 7;
				
				#only start once we reach the starting date
				if (($year == $startYear && $month >= $startMonth) || ($year > $startYear)) {
					
					#format days to have a leading zero if they're only one digit	
					#The key for hashes will be $month$day$hour			
					$hour = sprintf("%02d", $hour);
					$day = sprintf("%02d", $day);
					$month = sprintf("%02d", $month);
					
					my $key = $month.$day.$hour;
					
					if (exists $hash{$key}) {
						#If this key already exists in the hash, add the data value to it to average out later. Increment counter by 1.
						$hash{$key} = [$hash{$key}[0] + $data, $hash{$key}[1] + 1];
					} else {
						#create new hash key
						my $counter = 1;
						$hash{$key} = [$data, $counter];
					}
					#print FILE "$month$day$hour\n";
				}	
			}
		}
		#average out data values in each hash key by dividing data sum by counter
		my $value = "";
		foreach $value ( keys %hash ) {
			$hash{$value} = [$hash{$value}[0]/$hash{$value}[1], $hash{$value}[1]];
		}
	
	return %hash;
	
	close (MYFILE);
}

	
	
	
	
