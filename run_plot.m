% =================================================================================================
% Make a parallel coordinates plot.
% =================================================================================================
%
% Make the following things:
%     - load the data
%     - make a raster plot of the lines
%     - make a vector plot of the curves
%     - save the plots
%
% =================================================================================================
%
% See also:
%     - run_parse (prepare the data)
%     - get_plot (subfunction called by this function)
%
% =================================================================================================
% Thomas Guillod <guillod@lem.ee.ethz.ch>
% PES ETHZ
% =================================================================================================

function run_plot()
% main function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close('all');
addpath('utils')

% get the control parameters
ctrl = get_ctrl();

% load the data
data_parsed = load('data/data_parsed.mat');

% make the plot
fig = get_plot(data_parsed, ctrl, 'all_vector');
print(fig, '-dpdf', 'data/all_vector.pdf');

% make the plot
fig = get_plot(data_parsed, ctrl, 'big_data_vector');
print(fig, '-dpdf', 'data/big_data_vector.pdf');

fig = get_plot(data_parsed, ctrl, 'big_data_raster');
print(fig, '-dpng', '-r50', 'data/big_data_raster.png');

end

function ctrl = get_ctrl()
% get the rules used to plot the data
%     - ctrl - struct with data used to setup the plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data for the vector plot / require large memory
%     - x - size in x direction (centimeters)
%     - y - size in y direction (centimeters)
%     - dx - window position offset in x direction (centimeters)
%     - dy - window position offset in y direction (centimeters)
ctrl.x = 30.0;
ctrl.y = 20.0;
ctrl.dx = 5.0;
ctrl.dy = 5.0;

end
