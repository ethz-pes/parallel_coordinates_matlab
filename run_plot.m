function run_plot()
% Make a parallel coordinates plot.
%
%    In this example, the design space diversity of a medium-frequency transformer is considered.
%
%    This example is composed of two files:
%        - run_parse.m - extract and parse the dataset
%        - run_plot.m - make the parallel coordinate plot
%
%    Plot the axis and background color.
%    Plot the colored lines.
%    Plot the highlighted lines.
%    Plot the variable ranges.
%
%    If many lines exist, the generated plot is potentially huge.
%    Therefore, for large datasets, the axis and the lines are split in two plots.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

close('all');
addpath('utils')

%% param

% data for the plot size
%    - x: size in x direction (centimeters)
%    - y: size in y direction (centimeters)
%    - dx: window position offset in x direction (centimeters)
%    - dy: window position offset in y direction (centimeters)
ctrl.x = 30.0;
ctrl.y = 20.0;
ctrl.dx = 5.0;
ctrl.dy = 5.0;

%% run

% load the data
data_parsed = load('data/data_parsed.mat');

% make the vector plot with the axis and the lines
fig = get_plot(data_parsed, ctrl, 'all_vector');
print(fig, '-dpdf', 'data/all_vector.pdf');

% make the vector plot with only the axis (for handling large dataset)
fig = get_plot(data_parsed, ctrl, 'big_data_vector');
print(fig, '-dpdf', 'data/big_data_vector.pdf');

% make the raster plot with only the lines (for handling large dataset)
fig = get_plot(data_parsed, ctrl, 'big_data_raster');
print(fig, '-dpng', '-r50', 'data/big_data_raster.png');

end