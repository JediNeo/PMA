%load STATE.mat
%load BATCF.mat
%load sbatNGR.mat

[file_state, location] = uigetfile('*.mat');
full_state = fullfile(location, file_state);
load(full_state);
mission_number_state = mission_number;

[file_bat, location] = uigetfile('*.mat');
full_bat = fullfile(location, file_bat);
if exist("file_bat")
     load(full_bat);
 end

[data,location] = uiputfile('data.txt');
full_file = fullfile(location, data);

time_seconds = mission_time;
time_seconds_all = mission_time;
%time_seconds = mission_msecs/1000;
time_minutes = time_seconds/60;
time_start = time_minutes - time_minutes(1);
%D = datetime(secs_since_1970, 'ConvertFrom', 'posixtime', 'Format','ss');
%date_test = convertTo(D,'juliandate');
depth_all = depth;
depth_below = 0 - depth;
depth_goal_all = depth_goal;
depth_goal_below = 0 - depth_goal;
estimated_velocity_all = estimated_velocity;
speed_knots = estimated_velocity * 1.944;
longitude_all = longitude;
latitude_all = latitude;
thruster_rpm_all = thruster_rpm;
goal_longitude_all = goal_longitude;
goal_latitude_all = goal_latitude;
run = 0;
run_start = 1;
run_end = 1;
y = 1;
y_bat = 1;
plot_count = 1;



%loop to go through all runs
while run <= mission_number_state(end)

%load STATE.mat
mission_time = time_seconds_all;
depth = depth_all;
depth_goal = depth_goal_all;
estimated_velocity = estimated_velocity_all;
longitude = longitude_all;
latitude = latitude_all;
thruster_rpm = thruster_rpm_all;
goal_longitude = goal_longitude_all;
goal_latitude = goal_latitude_all;








in_mission = 0;
while y < length(mission_number_state)
    if mission_number_state(y) == run
        run_end = y;
        in_mission = in_mission + 1;
    end
    if mission_number_state(y) > run
        break;
    end
    y = y + 1;
end
run_start = y - in_mission;

time_seconds = mission_time(run_start:run_end);
%time_seconds = mission_msecs/1000;
time_minutes = time_seconds/60;
time_start = time_minutes - time_minutes(1);
%D = datetime(secs_since_1970, 'ConvertFrom', 'posixtime', 'Format','ss');
%date_test = convertTo(D,'juliandate');
depth_below = 0 - depth(run_start:run_end);
depth_goal_below = 0 - depth_goal(run_start:run_end);
speed_knots = estimated_velocity(run_start:run_end) * 1.944;


% Get's max depth...obviously
max_depth = 0;
x = run_start;
depth_count = 1;
while x < run_end
    if depth_below(depth_count) < max_depth
        max_depth = depth_below(depth_count);
    else
        max_depth = max_depth;
    x = x + 1;
    depth_count = depth_count + 1;
    end
end



% Reduce noise in speed data
speed_hold = run_start:run_end;
[TF,S1,S2] = ischange(speed_hold,'linear','Threshold',10);
speed_noiseless = S1.*(run_start:run_end) + S2;


% Plot Lat/Long of actual and planned
figure(plot_count);
plot_count = plot_count + 1;
geoplot(latitude(run_start:run_end),longitude(run_start:run_end));
hold on;
geoplot(goal_latitude(run_start:run_end),goal_longitude(run_start:run_end));
hold off;
%geobasemap satellite;
geobasemap streets;
legend('Actual Track','Planned Track');

% Plot velocity over time
figure(plot_count);
plot_count = plot_count + 1;
yyaxis left;
plot(time_start,speed_knots);
ylabel('Speed(kts)');
hold on;
yyaxis right;
plot(time_start,thruster_rpm(run_start:run_end));
hold off;
xlabel('Time(m)');
ylabel('Speed(RPM)');
grid('on');
legend('Knots','RPM');

% Plot depth goal and depth over time
figure(plot_count);
plot_count = plot_count + 1;
x = time_start;
plot(x, depth_goal_below);
hold on;
plot(x, depth_below);
hold off;
xlabel('Time(m)');
ylabel('Depth(m)');
grid('on');
legend('Depth Goal','Depth');


% Get total distance
wgs84 = wgs84Ellipsoid;
dist_total = 0;
count = 1;
while count < length(latitude(run_start:run_end)) -1
    dist_total = dist_total + distance(latitude(count),longitude(count),latitude(count + 1),longitude(count + 1),wgs84);
    count = count + 1;
    %disp(count)
end
format shortG;
%end of while loop for state data




% run = run + 1;
% end



%run = 0;
%run_start = 1;
%run_end = 1;
%y = 1;


%loop to go through all runs
%while run <= mission_number(end)

%battery stuff so stuff isn't overwritten
%load BATCF.mat
%load sbatNGR.mat
% if exist("file_bat")
%     load(full_bat);
% end



 in_mission_bat = 0;
 while y_bat < length(mission_number)
     if mission_number(y_bat) == run
         run_end_bat = y_bat;
         in_mission_bat = in_mission_bat + 1;
     end
     if mission_number(y_bat) > run
         break;
     end
     y_bat = y_bat + 1;
 end
 run_start_bat = y_bat - in_mission_bat;



long_time_minutes = secs_since_1970(run_start_bat:run_end_bat)/60;
long_time_start = long_time_minutes - long_time_minutes(1);

hii = [];
whoi = [];
if exist('remain_cap_ma_hrs') > 0
    whoi = remain_cap_ma_hrs(run_start_bat:run_end_bat);
    avg_max_bat = mean(full_chg_cap_ma_hrs(run_start_bat:run_end_bat));
    bat_pct_start = remain_cap_ma_hrs(run_start_bat:run_end_bat)/full_chg_cap_ma_hrs(run_start_bat:run_end_bat)*100;
    bat_pct_end = remain_cap_ma_hrs(1,1) / full_chg_cap_ma_hrs(1,1) * 100;
else
    hii = rem_cap_amp_hrs(run_start_bat:run_end_bat);
    avg_max_bat = mean(full_cap_amp_hrs(run_start_bat:run_end_bat));
    bat_pct_end = 100-rem_cap_amp_hrs(run_start_bat:run_end_bat)/full_cap_amp_hrs(run_start_bat:run_end_bat)*100;
end
bat_time_seconds = secs_since_1970(run_start_bat:run_end_bat) - secs_since_1970(1);
bat_time_minutes = bat_time_seconds/60;
bat_time = bat_time_minutes - bat_time_minutes(1);

% Plot battery info
if exist('remain_cap_ma_hrs') > 0
    med = medfilt1(whoi);   % Why would they have the same variable names...
else
    hii = rem_cap_amp_hrs(run_start_bat:run_end_bat);
    %med = smoothdata(hii);
    med = medfilt1(rem_cap_amp_hrs(run_start_bat:run_end_bat));
end

%plot(bat_time,med);
figure(plot_count)
plot_count = plot_count + 1;
plot(bat_time,remain_cap_ma_hrs(run_start_bat:run_end_bat));
hold on;
plot(bat_time,med);
hold off;
yline(avg_max_bat);
xlabel('Time(m)');
ylabel('Energy Remaining(mAh)');
grid('on');
legend('Remaining Battery');


% Opens file to write results
fileID = fopen(full_file,'a+');
% Prints results with 4 digits before decimal and 2 after
fprintf(fileID,'Run Number: %1.0g \n',run + 1);
fprintf(fileID,'Total Distance Travelled: %4.2f meters \n',dist_total);
fprintf(fileID,"Total Run Time: %4.2f Minutes \n",time_start(end));
fprintf(fileID,"Average Speed: %4.2f knots \n",mean(speed_knots));
fprintf(fileID,"Battery: %4.2f%% Remaining \n",bat_pct_end);
fprintf(fileID,"Max Depth: %4.2f meters \n",abs(max_depth));
fprintf(fileID,"Bat Used: %4.2f%% \n",bat_pct_start - bat_pct_end);
fprintf(fileID,"\n");
% Closes the file
fclose('all');



run = run + 1;
end




% Prints results with 4 digits before decimal and 2 after
fprintf("Total Distance Travelled: %4.2f meters \n",dist_total);
fprintf("Total Run Time: %4.2f Minutes \n",time_start(end));
fprintf("Average Speed: %4.2f knots \n",mean(speed_knots));
%fprintf("Average Speed: %4.2f knots \n",mean(avg_speed));
fprintf("Battery: %4.2f%% Remaining \n",bat_pct_end);
fprintf("Max Depth: %4.2f meters \n",abs(max_depth));
fprintf("Bat Used: %4.2f%% \n",bat_pct_start - bat_pct_end);
