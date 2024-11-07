% The goal of this code is to make a comparison between the daily sea ice
% velocity between the ECCO and the NSIDC polar pathfinder satellite
% products.

clear all; close all; clc;

%% Load and set ECCO geometry
HOME = '/Users/aahmed78/Desktop/ECCO/';
cd(strcat(HOME, 'ECCO Sea Ice Velocity/data/'));
fname = 'GRID_GEOMETRY_ECCO_V4r4_native_llc0090.nc';
readncfile;

cd(strcat(HOME, 'ArcticMappingTools'));
CS = CS(:,:,7); SN = SN(:,:,7);

%% Load ECCO data
cd(strcat(HOME, 'ECCO Sea Ice Velocity/data/'));
year = 2000; 
fname = sprintf("ecco_sea_ice_velocity_%d.nc", year);
readncfile;
clearvars -except HOME CS SN XC YC tile year SIuice SIvice time

SIuice = squeeze(SIuice(:,:,3,:)); 
SIvice = squeeze(SIvice(:,:,3,:));

datetime = datetime(year, 1, 1, 12, 0, 0) + hours(time(:));
datetime.Format = 'yyyy-MM-dd';

% Transform U and V
U = zeros(size(SIuice));
V = zeros(size(SIvice));

for t = 1:length(SIuice)
    U(:, :, t) = CS .* SIuice(:, :, t) - SN .* SIvice(:, :, t);
    V(:, :, t) = SN .* SIuice(:, :, t) + CS .* SIvice(:, :, t);
end

SIuice = V; % Zonal
SIvice = U; % Meridioanl

clear U V t time

%% ECCO plot
close all;
u_x = nanmean(SIuice(:,:,1:365),3);
figure(1),

pcolor(u_x); colorbar; caxis([-0.2 0.2]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('RdBu'))); 
    title('V_{NSIDC}-V_{ECCO}','FontSize',15);

%% Quiver plot
scaleFactor = 2; % Adjust the arrow length scaling factor
for i = 1:100
    figure(1);
    % Plot the quiver with customized appearance
    
    q = quiver(SIuice(1:3:end,1:3:end,i), SIvice(1:3:end,1:3:end,i), 'AutoScale', 'on', ...
        'AutoScaleFactor', scaleFactor, 'Color', 'k'); % Set arrows to black with 'k'
    q.ShowArrowHead = 'on';
    q.LineWidth = 1.5; % Set the line width for the arrows
    q.MaxHeadSize = 0.5; % Increase this value for larger arrowheads
    
    shading flat; % Ensure the shading is flat
    colorbar; % Add colorbar for reference
    caxis([-0.4 0.4]); % Set color axis limits
    
    % Add a title with the datetime
     title(sprintf(''),datetime(i))
    
    drawnow;
end


%% Load and regrid NISDC data
cd(strcat(HOME, 'NSIDC Daily Sea Ice Motion/data/'));
fname = sprintf("icemotion_daily_nh_25km_%d0101_%d1231_v4.1.nc", year, year);
readncfile;
error_nsidc = icemotion_error_estimate;

clear A crs fname icemotion_error_estimate time ll
% 
% % Transform U and V for NSIDC
% U2 = zeros(size(u));
% V2 = zeros(size(v));
% 
% for t = 1:length(SIuice)
%     U2(:, :, t) = cos(latitude) .* u(:, :, t) + sin(longitude) .* v(:, :, t);
%     V2(:, :, t) = -sin(latitude) .* u(:, :, t) + cos(longitude) .* v(:, :, t);
% end
% 
% u = U2;
% v = V2;


%% NSIDC plot quiver
% Define a scale factor for the arrow length
scaleFactor = 2; % Adjust this value to increase or decrease arrow length
cd(strcat(HOME, 'ArcticMappingTools'))
[X, Y] = meshgrid(x, y);
for i = 1
    figure(1);
    % Downsample the u and v arrays by every 3 steps
    pcolor(Y,X,u,v); shading flat;
    q = quiver(Y(1:3:end, 1:3:end), X(1:3:end, 1:3:end), ...
        u(1:3:end, 1:3:end, i), v(1:3:end, 1:3:end, i), 'AutoScale', 'on', ...
        'AutoScaleFactor', scaleFactor); % Apply scaling factor to arrows
    q.ShowArrowHead = 'on';
    q.Marker = '.';
    q.LineWidth = 2;
    PLOT()
end

% Add a legend indicating the scaling factor
%legend(sprintf('%.1f m/s', scaleFactor), 'Location', 'best');

%% Regrid NSIDC
cd(strcat(HOME, 'ArcticMappingTools'))
u_interp = zeros(90, 90, length(datetime));
v_interp = zeros(90, 90, length(datetime));
[n_lat, n_lon] = meshgrid(x,y);
[X,Y] = ll2psn(YC, XC);

Lat = linspace(min(min(n_lat)), max(max(n_lat)), 361);
Lon = linspace(min(min(n_lon)), max(max(n_lon)), 361);
[newLon, newLat] = meshgrid(Lon, Lat);

for day = 1:length(datetime)
    u_interp(:,:,day) = interp2(newLon, newLat, u(:,:,day)./100, Y, X,'linear');
    v_interp(:,:,day) = interp2(newLon, newLat, v(:,:,day)./100, Y, X,'linear');
end


clear lat latitude lon longitude day mewLat newLon n_lat n_lon


%% Mask ECCO sea ice velocity with sea ice concentration


%% Plot 
F = 15;

for day = 1
    figure(1), clf; clc;
   
    % NSIDC
    subplot(2,3,1)
    pcolor(X,Y,u_interp(:,:,day)); colorbar; caxis([-0.4 0.4]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('seismic'))); 
    title('U_{NSIDC}','FontSize',F);
    PLOT();
    
    subplot(2,3,4)
    pcolor(X,Y,v_interp(:,:,day)); colorbar; caxis([-0.4 0.4]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('seismic'))); 
    title('V_{NSIDC}','FontSize',F);
    PLOT();
    
    % difference
    subplot(2,3,3)
    pcolor(X,Y,u_interp(:,:,day)-SIuice(:,:,day)); colorbar; caxis([-0.4 0.4]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('holly'))); 
    title('U_{NSIDC}-U_{ECCO}','FontSize',F);
    PLOT();

    % ECCO
    subplot(2,3,2)
    pcolor(X,Y,SIuice(:,:,day)); colorbar; caxis([-0.4 0.4]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('seismic'))); 
    title('U_{ECCO}','FontSize',F);
    PLOT()
    
    subplot(2,3,5)
    pcolor(X,Y,SIvice(:,:,day)); colorbar; caxis([-0.4 0.4]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('seismic'))); 
    title('V_{ECCO}','FontSize',F);
    PLOT()
    
    % difference
    subplot(2,3,6)
    pcolor(X,Y,v_interp(:,:,day)-SIvice(:,:,day)); colorbar; caxis([-0.4 0.4]);
    shading interp; hold on;
    colormap(gca, flip(slanCM('holly'))); 
    title('V_{NSIDC}-V_{ECCO}','FontSize',F);
    PLOT();
    
    sgtitle([datestr(datetime(day), 'yyyy-mm-dd')],'FontSize',F+5);
    PLOT();
end

%% Function to plot
function PLOT()
    set(gca,'color',[0.75 0.75 0.75]);
    arcticborders('facecolor',[0.82 0.7 0.44],'edgecolor','k'); hold on;
    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);
    xlim([-2e6 2e6]); ylim([-2e6 2e6]);
    hold on;
    set(gca, 'Layer', 'top');
    box on;
    set(gca, 'GridLineStyle', '-','LineWidth', 3);
    set(gcf, 'Position', [315,604,1408,663]);
    cb = colorbar;
    cb.FontSize = 12;
    cb.FontWeight = 'bold';
end