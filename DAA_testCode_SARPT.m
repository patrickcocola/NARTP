%% WellClear Visual
%  Author: Patrick Cocola, Diego Delgado & John Bebel
%  Created: August 1, 2018
%  Modified: August 20, 2018
clc, clearvars, close all;
%------------------------------------------------------------------------
dataTable=readtable('DAAClean_edited_sorted_test.csv');
dataPoints=table2cell(dataTable);
dataPoints=[dataTable.Properties.VariableNames;dataPoints];
[CraftRow,CraftCol]=find(string(dataPoints)=='Aircraft_Count');
[IDRow,IDCol]=find(string(dataPoints)=='Aircraft_Identifier');
% sourceLong=-122.1;
% sourceLat=37.5;
sourceLat=input('LATITUDE LOCATION for Relative:  ');
sourceLong=input('LONGITUDE LOCATION for Relative:  ');

sourceEl=0;%Source elevation
AircraftCount=cell2mat(dataPoints(CraftRow+1,CraftCol));%finds out how many aircrafts there are
CurrentCount=1;
Aircrafts=[];% matrix to store all ID's of Aircrafts
spot=1;
latlong=(10000/90)*3280.4;%latlong to feet.
ybot=25;%bottom latitude of united states
ytop=50;% top latitude of united states
xtop=-67;% top longitude of united states
xbot=-123;% bottom lonitude of united states
ylimits=[ybot ytop];
xlimits=[xbot xtop];
Aircrafts=[Aircrafts,dataPoints(IDRow+1,IDCol)];% populates matrix with the Aircraft ID's

while(CurrentCount<AircraftCount) % loop the ID's
    for (i=1:size(Aircrafts))
        if ~(string(Aircrafts(i))==string(dataPoints(spot+IDRow,IDCol)))
            Aircrafts=[Aircrafts,dataPoints(spot+IDRow,IDCol)];
            CurrentCount=CurrentCount+1;
        end
    end
    spot=spot+1;  
end

storage=[];% stores all the aircraft data
alt=0;
for i=1:AircraftCount
    temp=[];
    [row,col]=find(string(dataPoints)==Aircrafts(i));
    for j=1:size(row)
        temp=[temp;dataPoints(row(j),:)];
    end
    absoluteLocation=[];
    
    [rangeRow,colRange]=find(string(dataPoints)=='Slant_Range');
    [rangeAz,colAz]=find(string(dataPoints)=='Azimuth_Angle');
    [rangeMSL,colMSL]=find(string(dataPoints)=='Aircraft_Altitude_MSL');
    [rangeElavationAngle,colElavationAngle]=find(string(dataPoints)=='Elevation_Angle');
    [rangeLatitude,colLatitude]=find(string(dataPoints)=='Aircraft_Latitude');
    [rangeLongitude,colLongitude]=find(string(dataPoints)=='Aircraft_Longitude');
    for (j=1:size(temp,1))
        if ~(abs(cell2mat(temp(j,colLatitude)))>0)
            lat=sourceLat*latlong+cell2mat(temp(j,colRange))*cos(cell2mat(temp(j,colElavationAngle)))*sin(cell2mat(temp(j,colAz)));
            long=sourceLong*latlong+cell2mat(temp(j,colRange))*cos(cell2mat(temp(j,colElavationAngle)))*cos(cell2mat(temp(j,colAz)));
            alt=cell2mat(temp(j,colMSL));
            absoluteLocation=[absoluteLocation;long,lat,alt];

        else
            absoluteLocation=[absoluteLocation;cell2mat(temp(j,colLongitude))*latlong,cell2mat(temp(j,colLatitude))*latlong,cell2mat(temp(j,colMSL))];
        end
    end
    storage(:,:,i)=absoluteLocation;


end
dangercount=0;% store the amount of well clear violations
for currentAircraft=1:AircraftCount-1 % checks each row of first aircraft with rows of the next ones
    for rowSpot=1:size(storage,1)% spot in the row
        for nextAircraft=1:AircraftCount-currentAircraft % the next aircraft in list but not the previously checked ones
            diffx=(storage(rowSpot,1,currentAircraft)-storage(rowSpot,1,currentAircraft+nextAircraft))^2;% finds the difference squared of x values 
            diffy=(storage(rowSpot,2,currentAircraft)-storage(rowSpot,2,currentAircraft+nextAircraft))^2;% finds the difference squared of y values
            if sqrt(diffx+diffy)<2000 % if its within 2000 ft its a violation unless alitude is great enough
               if  abs(storage(rowSpot,3,currentAircraft)-storage(rowSpot,3,currentAircraft+nextAircraft))<250 % sees if it is within 250 ft up or down
                   dangercount=dangercount+1;% stores how many well clear violations
                   hold on
                   grid on
                   
                   plot(storage(:,1,currentAircraft+nextAircraft)/latlong,storage(:,2,currentAircraft+nextAircraft)/latlong)% plots the compared aircraft
                   plot(storage(:,1,currentAircraft)/latlong,storage(:,2,currentAircraft)/latlong)% plots the current Aircraft

                   plot(storage(:,1,currentAircraft+nextAircraft)/latlong,storage(:,2,currentAircraft+nextAircraft)/latlong,'+','MarkerSize',3);% makes each waypoint a +
                   plot(storage(:,1,currentAircraft)/latlong,storage(:,2,currentAircraft)/latlong,'+','MarkerSize',3);% makes each waypoint a +
                   
                   
                   plot(storage(rowSpot,1,currentAircraft)/latlong,storage(rowSpot,2,currentAircraft)/latlong,'k*')% marks the wellclear violation point 

                   %creates a matrix of points that looks like a circle
                   %with radius of 2000 ft 
                   theta=0:0.01:2*pi;
                   radius=2000;
                   x=radius*cos(theta)+storage(rowSpot,1,currentAircraft);
                   y=radius*sin(theta)+storage(rowSpot,2,currentAircraft);
                   plot(x/latlong,y/latlong,'r');
                   % end of circle code
                   
                   xlabel('LONGITUDE')
                   ylabel('LATITUDE')
                   disp("WELL CLEAR Violation: "+dangercount+" @ position "+storage(rowSpot,2,currentAircraft+nextAircraft)/latlong+" | "+storage(rowSpot,1,currentAircraft)/latlong)
               end
           end
        end
      	
    end
end
if dangercount==0
    disp("ALL CLEAR")
end
% A1=string(Aircrafts(1));
% A2=string(Aircrafts(2));
% A3=string(Aircrafts(3));
% A4=string(Aircrafts(4));
% 
% [row,col]=find(string(dataPoints)==A1);
% Aircraft1=[dataPoints(1,:)];
% for(i=1:size(row)-1)
%     Aircraft1=[Aircraft1;dataPoints(row(i),:)];
% end
% 
% [row,col]=find(string(dataPoints)==A2);
% Aircraft2=[dataPoints(1,:)];
% for(i=1:size(row))
%     Aircraft2=[Aircraft2;dataPoints(row(i),:)];
% end
%     
% [row,col]=find(string(dataPoints)==A3);
% Aircraft3=[dataPoints(1,:)];
% for(i=1:size(row))
%     Aircraft3=[Aircraft3;dataPoints(row(i),:)];
% end
%       
% [row,col]=find(string(dataPoints)==A4);
% Aircraft4=[dataPoints(1,:)];
% for(i=1:size(row))
%     Aircraft4=[Aircraft4;dataPoints(row(i),:)];
% end
% A1Location=[];
% for (i=2:size(Aircraft1,1))
%     if ~(abs(cell2mat(Aircraft1(i,7)))>0)
%         lat=sourceLat+cell2mat(Aircraft1(i,13))*cos(cell2mat(Aircraft1(i,17)))*sin(cell2mat(Aircraft1(i,19)));
%         long=sourceLong+cell2mat(Aircraft1(i,13))*cos(cell2mat(Aircraft1(i,17)))*cos(cell2mat(Aircraft1(i,19)));
%         A1Location=[A1Location;lat,long];
%         
%     else
%         A1Location=[A1Location;cell2mat(Aircraft1(i,7)),cell2mat(Aircraft1(i,8))];
%     end
% end
% 
% A2Location=[];
% for (i=2:size(Aircraft2,1))
%     if ~(abs(cell2mat(Aircraft2(i,7)))>0)
%         lat=sourceLat+cell2mat(Aircraft2(i,13))*cos(cell2mat(Aircraft2(i,17)))*sin(cell2mat(Aircraft2(i,19)));
%         long=sourceLong+cell2mat(Aircraft2(i,13))*cos(cell2mat(Aircraft2(i,17)))*cos(cell2mat(Aircraft2(i,19)));
%         A2Location=[A2Location;lat,long];
%         
%     else
%         A2Location=[A2Location;cell2mat(Aircraft2(i,7)),cell2mat(Aircraft2(i,8))];
%     end
% end
% 
% A3Location=[];
% for (i=2:size(Aircraft3,1))
%     if ~(abs(cell2mat(Aircraft3(i,7)))>0)
%         lat=sourceLat+cell2mat(Aircraft3(i,13))*cos(cell2mat(Aircraft3(i,17)))*sin(cell2mat(Aircraft3(i,19)));
%         long=sourceLong+cell2mat(Aircraft3(i,13))*cos(cell2mat(Aircraft3(i,17)))*cos(cell2mat(Aircraft3(i,19)));
%         A3Location=[A3Location;lat,long];
%         
%     else
%         A3Location=[A3Location;cell2mat(Aircraft3(i,7)),cell2mat(Aircraft3(i,8))];
%     end
% end
% 
% A4Location=[];
% for (i=2:size(Aircraft4,1))
%     if ~(abs(cell2mat(Aircraft4(i,7)))>0)
%         lat=sourceLat+cell2mat(Aircraft4(i,13))*cos(cell2mat(Aircraft4(i,17)))*sin(cell2mat(Aircraft4(i,19)));
%         long=sourceLong+cell2mat(Aircraft4(i,13))*cos(cell2mat(Aircraft4(i,17)))*cos(cell2mat(Aircraft4(i,19)));
%         A4Location=[A4Location;lat,long];
%         
%     else
%         A4Location=[A4Location;cell2mat(Aircraft4(i,7)),cell2mat(Aircraft4(i,8))];
%     end
% end
% 
% plot(A1Location(:,1),A1Location(:,2))
% hold on
% plot(A2Location(:,1),A2Location(:,2))
% plot(A3Location(:,1),A3Location(:,2))
% plot(A4Location(:,1),A4Location(:,2))