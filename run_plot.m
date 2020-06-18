% =================================================================================================
% Make a parallel coordinates plot.
% =================================================================================================
%
% Make the following things:
%     - load the data
%     - make a raster plot of the curves
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
data_tmp = load('data/data_parsed.mat');
data_parsed = data_tmp.data_parsed;

% make the plot
[fig_raster, fig_vector] = get_plot(data_parsed, ctrl);

% save the figure
print(fig_raster, '-dpng', '-r500', 'data/test.png');
print(fig_vector, '-dpdf', 'data/test.pdf');

end

function ctrl = get_ctrl()
% get the rules used to plot the data
%     - ctrl - struct with data used to setup the plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data for the raster plot / require low memory
%     - make_plot - plot (or not) the curves
%     - x - size in x direction (centimeters)
%     - y - size in y direction (centimeters)
%     - dx - window position offset in x direction (centimeters)
%     - dy - window position offset in y direction (centimeters)
ctrl.raster.make_plot = true;
ctrl.raster.x = 8.0;
ctrl.raster.y = 4.0;
ctrl.raster.dx = 6.0;
ctrl.raster.dy = 4.0;

% data for the vector plot / require large memory
%     - title - title of the plot
%     - make_plot - plot (or not) the curves
%     - x - size in x direction (centimeters)
%     - y - size in y direction (centimeters)
%     - dx - window position offset in x direction (centimeters)
%     - dy - window position offset in y direction (centimeters)
ctrl.vector.title = 'Parallel Coordinates';
ctrl.vector.make_plot = true;
ctrl.vector.x = 30.0;
ctrl.vector.y = 20.0;
ctrl.vector.dx = 5.0;
ctrl.vector.dy = 5.0;

end
