30 Year Average Program

I. PURPOSE

This program is used to compute hourly-average values from 30 year records of hourly data. 
The program outputs two data files with the hourly-averages, one for a non-leap year and one for a leap year. 
The program was written for Argonne National Laboratory meteorological weather data, but can be modified
and applied to other data types. 

II. DESCRIPTION

This program will read in the input files (specified below), extracting the data (starting at the specified start date,
which can be changed within the subroutine getAverages) and storing it in key/value (array) hashes with the date/hour 
being the key to the hash (in a mm/dd/hh format). The value in each of these hashes is an array containing data and a counter. 
When each file has been read in, it will then average out the data value in each hash key based on the counter value.  

It then cycles through each hash and writes the values into new files (this was necessary to create and keep a sorted order). 
These files, dewFile, hourlyTempFile, hourlyWindFile, and solarFile, now contain the averages for all corresponding data. 

Finally, the program will cycle through each of these newly-created files and create a final output.txt file showing 
the hourly averages for every date and hour combination (broken down into 15 minute increments). In addition to the final output file, 
it will also create an outputWithKeys.txt file that can serve as a quick reference to each parameter’s daily/hourly averages.

III. Input Files
These .exp (Export Files) are column-based with the date (YYYY/MM/DD), Hour, and data. 
	
Argonne_hourly_dewpoint.exp
Argonne_hourly_solar.exp
Argonne_hourly_temperature.exp
Argonne_hourly_unadjusted_wind.exp

*These will all need to be within a folder entitled “Argonne_Hourly_Data.” 
This folder will need to be in the same directory as the 30YearAvg.pl Perl script. This structure is intact within the zip file.*

**Currently these *.exp files go through December 31, 2010.**

IV. Output Files

dewFile.txt – An average of daily and hourly dewpoint values, used for the final output file. 
hourlyTempFile.txt - An average of daily and hourly temperature values, used for the final output file
hourlyWindFile.txt - An average of daily and hourly wind values, used for the final output file
solarFile.txt - An average of daily and hourly solar radiation values, used for the final output file
outputWithKeys – A column-based file listing the averages for each set of data (dewpoint, hourly temp, hourly wind, and solar radiation)
                for each day and hour. 
output.txt – This is the final output file. This output format follows the Argonne National Laboratory format 
	     for their real-time meteorological data as shown at: http://gonzalo.er.anl.gov/ANLMET/anltower.not_qc
             More information on this format can be found here: http://gonzalo.er.anl.gov/ANLMET/format.txt
	     This format is column-based and for columns for which we had no data a placeholder amount of -999 was used.
	     This format is based on increments of 15 minutes. To achieve this, our hourly data is converted in the following ways: 

		Dewpoint: Data from the hourly dewpoint text file is first converted to Celsius and then this figure is repeated 4 times for each 15 minute block.
		Temperature: Data from the hourly temperature text file is first converted to Celsius and then this figure is repeated 4 times for each 15 minute block.
		Wind: Data from the hourly wind text file is converted from miles in-one-hour to m/s and then this figure is divided by 4. 
		Solar Radiation: Data from the solar text file is converted from langleys to Watts/m^2 and then this figure is divided by 4.

outputNoLeap.txt – same as output.txt but for a non-leap year.
