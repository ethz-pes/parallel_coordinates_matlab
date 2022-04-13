function fig = get_plot(data_parsed, ctrl, type)
% Make a parallel coordinates plot.
%
%    Plot the axis and background color.
%    Plot the colored lines.
%    Plot the highlighted lines.
%    Plot the variable ranges.
%
%    If many lines exist, the generated plot is potentially huge.
%    Therefore, for large datasets, the axis and the lines are split in two plots.
%
%    Three different types of plots are possible
%        - 'all_vector' - vector plot - plot everything (potentially huge)
%        - 'big_data_vector' - vector plot - plot only the axis and the highlighted lines
%        - 'big_data_raster' - raster plot - plot only the colored lines
%
%    Parameters:
%        data_parsed(struct): struct with the data to be plotted
%        ctrl (struct): struct with the plot parameters
%        type (str): type of the plot to be made
%
%    Returns:
%        fig (figure): figure handle to the generated plot
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% extract data
var = data_parsed.var;
color = data_parsed.color;
highlight = data_parsed.highlight;

% make the plot
fig = plot_figure(var, color, highlight, ctrl, type);

end

function fig = plot_figure(var, color, highlight, ctrl, type)
% Make the vector plot.
%
%    Parameters:
%        var (struct): struct with the variables
%        color (struct): struct with the colormap data
%        highlight (struct): struct with the lines to highlight
%        ctrl (struct): struct with the plot parameters
%        type (str): type of the plot to be made
%
%    Returns:
%        fig (figure): figure handle to the generated plot

% get type
switch type
    case 'all_vector'
        renderer = 'painters';
        plot_axis = true;
        plot_big_data = true;
        plot_small_data = true;
    case 'big_data_vector'
        renderer = 'painters';
        plot_axis = true;
        plot_big_data = false;
        plot_small_data = true;
    case 'big_data_raster'
        renderer = 'zbuffer';
        plot_axis = false;
        plot_big_data = true;
        plot_small_data = false;
    otherwise
        error('invalid type')
end

% relative space in y direction for the axis
delta_bottom = 0.25;
delta_top = 0.05;

% relative space in x direction for the axis and the colorbar
delta_x = 0.05;

% relative space for the title, ranges, labels, and colorbar
delta_range = 0.02;
delta_text = 0.02+0.04;

% relative space for the colorbar
delta_colorbar_span = 0.04;
delta_colorbar_start = 0.10;

% create the figure
fig = figure();
set(gcf, 'Render', renderer)
set(gcf, 'Units', 'centimeters', 'Position', [ctrl.dx ctrl.dy ctrl.x ctrl.y]);
set(gcf,'PaperPositionMode', 'Auto', 'PaperUnits', 'centimeters', 'PaperSize',[ctrl.x ctrl.y])

% create the axes and colorbar
axes('Position', [delta_x delta_bottom 1.0-delta_x-delta_x 1.0-delta_bottom-delta_top])
hold('on')

% plot the data
if plot_big_data==true
    plot_fill(var)
    plot_line(var, color)
end
if plot_small_data==true
    plot_range(var)
    plot_highlight(var, highlight)
end

% setup the y axis limits
ylim([0 1])
yticks([0 1])
yticklabels({})

% setup the x axis limits
xlim([1 var.n_var])
xticks(1:var.n_var)
xticklabels({})

% setup the color axis limits
caxis([0 1]);

if plot_axis==true
    % set up colorbar
    colorbar('Location', 'southoutside', 'TickLength', 0, 'Position', [delta_x delta_colorbar_start 1.0-delta_x-delta_x delta_colorbar_span], 'TickLabels', {});
    
    % get the position of the ticks, labels, and title
    y_tick_bottom = get_axis_from_fig(delta_bottom-delta_range, delta_bottom, delta_top);
    y_tick_top = get_axis_from_fig(1.0-delta_top+delta_range, delta_bottom, delta_top);
    y_label = get_axis_from_fig(delta_bottom-delta_text, delta_bottom, delta_top);
    
    % add the ticks and labels
    for i=1:var.n_var
        range_min = var.range_min_vec(i);
        range_max = var.range_max_vec(i);
        
        plot_text(i, y_tick_bottom, num2str(range_min))
        plot_text(i, y_tick_top, num2str(range_max))
        plot_text(i, y_label, var.name_vec{i})
    end
    
    % get the position of the colorbar ticks and label
    y_tick = get_axis_from_fig(delta_colorbar_start-delta_range, delta_bottom, delta_top);
    y_label = get_axis_from_fig(delta_colorbar_start-delta_text, delta_bottom, delta_top);
            
    % add the colorbar ticks
    for i=1:length(color.range)
        pos = color.tick(i).*(var.n_var-1)+1;
        plot_text(pos, y_tick, num2str(color.range(i)))
    end
    
    % add the colorbar label
    plot_text((var.n_var+1)./2, y_label, color.name)
    
    % setup the grid
    grid('on')
    set(gca,'Box', 'on')
    set(gca,'TickLength',[0 0])
    set(gca,'XColor','k')
    set(gca,'YColor','k')
    set(gca,'LineWidth', 0.33)
    set(gca,'GridLineStyle','-')
    set(gca,'MinorGridLineStyle','-')
    set(gca,'GridColor',[0.0 0.0 0.0])
    set(gca,'MinorGridColor',[0.0 0.0 0.0])
    set(gca,'GridAlpha',1.0)
    set(gca,'MinorGridAlpha',1.0)
    set(gca,'FontName', 'Times New Roman')
    set(gca,'FontSize', 12)
else
    axis('off')
end

end

function plot_range(var)
% Plot the range (min/max) of the different variables.
%
%    Parameters:
%        var (struct): struct with the variables

% extract the min/max
v_max = max(var.scale_mat, [], 2);
v_min = min(var.scale_mat, [], 2);

% plot the lines
for i=1:var.n_var
    plot([i i], [v_min(i) v_max(i)], 'k', 'LineWidth', 3.0)
end

end

function plot_highlight(var, highlight)
% Plot the highlighted designs.
%
%    Parameters:
%        var (struct): struct with the variables
%        highlight (struct): struct with the lines to highlight

for i=1:highlight.n_highlight
    vec = var.scale_mat(:,highlight.idx_vec(i));
    plot(1:var.n_var, vec, highlight.color_vec{i}, 'LineWidth', 1.5)
end

end

function plot_fill(var)
% Plot the background color of the variables.
%
%    Parameters:
%        var (struct): struct with the variables

for i=1:var.n_var
    plot_fill_sub([i-0.5 i+0.5], [0 1], var.color_vec{i})
end

end

function plot_line(var, color)
% Plot all the designs with the colormap.
%
%    Parameters:
%        var (struct): struct with the variables
%        color (struct): struct with the colormap data

% pad the the data for avoiding the line connecting the lines together
var_mat = [NaN(1, var.n_sol) ; var.scale_mat ; NaN(1, var.n_sol)];

% replicate the colormap for all the variables
color_mat = repmat(color.vec, [var.n_var+2, 1]);

% create the x vector (add a dummy 0 and n_var+1)
x_vec = 0:var.n_var+1;
x_mat = repmat(x_vec.', [1, var.n_sol]);

% plot the line
plot_line_sub(x_mat(:).', var_mat(:).', color_mat(:).')

end

function plot_text(x, y, str)
% Add a text at a given position (with respect to axis coordinates).
%
%    Parameters:
%        x (float): x position
%        y (float): y position
%        str (str): text string

text(...
    x, y, str,...
    'Interpreter', 'none',...
    'FontName',...
    'Times New Roman',...
    'FontSize', 12,...
    'HorizontalAlignment', 'center'...
    )

end

function plot_line_sub(x, y, c)
% Plot colored line (trick with surface fct).
%
%    Parameters:
%        x (vector): x data to be plotted
%        y (vector): y data to be plotted
%        c (vector) - color vector for the segments

% get the coordinates
x = [x.' x.'];
y = [y.' y.'];
z = zeros(length(c), 2);
c = [c.' c.'];

% plot the line
surface(...
    'XData', x,...
    'YData', y,...
    'ZData', z,...
    'CData', c, ...
    'FaceColor', 'none',...
    'EdgeColor', 'flat',...
    'LineStyle', '-',...
    'MarkerFaceColor', 'auto',...
    'MarkerEdgeColor', 'auto'...
    );

end

function plot_fill_sub(x, y, c)
% Plot colored rectangle in the background.
%
%    Parameters:
%        x (vector): x span (two elements)
%        y (vector): y span (two elements)
%        c (str) - color identifier

% get the coordinates
x_fill = [min(x) max(x) max(x) min(x)];
y_fill = [min(y) min(y) max(y) max(y)];

% fill the area
fill(...
    x_fill, y_fill, 'k',...
    'LineStyle', 'none',...
    'FaceAlpha', 0.15,...
    'FaceColor', c...
    );

end

function y_axis = get_axis_from_fig(y_fig, delta_bottom, delta_top)
% Get the position with respect to the y axis.
%
%    Parameters:
%        y_fig (float): relative y position with respect to the figure
%        delta_bottom (float): relative bottom margin for the axis
%        delta_top (float): relative top margin for the axis
%
%    Returns:
%        y_axis (float): calculated relative y position with respect to the axis

y_axis = (y_fig-delta_bottom)./(1.0-delta_bottom-delta_top);

end
