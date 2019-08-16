%% Engine Performance
%  Author: INTERNS!
%  Created: June 11, 2018
%  Modified: June 13, 2018
clc, clearvars, close all;
%------------------------------------------------------------------------
% Reading in the test data
csvfilename='UAP_sorted.csv';% inputs the test file name
csvTestData=fopen(csvfilename); % opens the file so that its readable
dataPoints=[]; % sets up an empty matrix
nextLine = fgetl(csvTestData); % reads the next line in and sets the first line to a temp variable
while ischar(nextLine) % ensures there is a next line
    if ~strcmp(nextLine(1),',') % checks to make sure it is not a line of ','s
        dataPoints=[dataPoints;strsplit(nextLine,',')]; % begins to make a matrix splitting at the ','
    end
    nextLine = fgetl(csvTestData); % reads the next line in and sets the first line to a temp variable 
end
[RPMrow,RPMcolumns]=find(dataPoints=="Engine_RPM");% gets the row and column value for RPM
[FBLrow,FBLcolumns]=find(dataPoints=="Fuel_or_Bat_Level");% gets the row and column value for FBL
[Trow,Tcolumns]=find(dataPoints=="Time");% gets the row and column value for Time
%------------------------------------------------------------------------
%Time
numTicks=10;
tempTime=(dataPoints(:,Tcolumns)); % gets the raw cell data for Time
Amount=round(length(tempTime)/numTicks);
Time=[]; % empty matrix
for i=2:Amount:length(tempTime')
   Time=[Time;(cell2mat(tempTime(i)))]; % converts cell data to char
end
%------------------------------------------------------------------------
fig=figure('units','inch','position',[9,4,8,5]);% sizes the figure window
%------------------------------------------------------------------------
%RPM
format long % ensures accurate data
tempRPM=(dataPoints(:,RPMcolumns)); % gets the raw cell data for RPM
RPM=[]; % empty matrix
for i=2:length(tempRPM')
   RPM=[RPM;str2double(cell2mat(tempRPM(i)))]; % converts cell data to double
end
subplot(2,1,1);
yyaxis left
hold on
ylabel('RPM')% labesl the y left axis
xlabel('Time')% labels the x axis

plot(1:length(RPM),RPM)%plot is change in seconds vs RPM
%------------------------------------------------------------------------
%FBL
tempFBL=(dataPoints(:,FBLcolumns)); % gets the raw cell data for RPM
FBL=[]; % empty matrix
for i=2:length(tempFBL')
   FBL=[FBL;str2double(cell2mat(tempFBL(i)))]; % converts cell data to double
end

title('RPM & Fuel/Battery Level VS Time (UTC)')
yyaxis right
ylabel('Fuel or Battery Level')
plot(FBL)
set(gca, 'XTickLabel',Time);
grid
%------------------------------------------------------------------------
%Change in RPM
diffRPM=[];
for i=1:length(RPM)-1
    diffRPM=[diffRPM;RPM(i)-RPM(i+1)];
end

subplot(2,1,2);
yyaxis left
hold on
ylabel('RPM Change')
xlabel('Time')
plot(1:length(diffRPM),diffRPM)
set(gca, 'XTickLabel',Time);% displays the UTC time
title('Change in RPM & Fuel/Battery Level VS Time (UTC)')
grid
%------------------------------------------------------------------------
%Change in FBL
diffFBL=[];
for i=1:length(RPM)-1
    diffFBL=[diffFBL;FBL(i)-FBL(i+1)];% finds the change in FBL
end
yyaxis right
ylabel('Fuel or Battery Level Change')
plot(1:length(diffFBL),diffFBL)
fclose(csvTestData);



