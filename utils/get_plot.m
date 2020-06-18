function [fig_raster, fig_vector] = get_plot(data_parsed, ctrl)
% Make a parallel coordinates plot.
%
%    The following features and limitations exist: 
%        - the losses are computed in the frequency domain with Bessel functions
%        - the litz wire can feature an arbitrary shapes
%        - the litz wire is composed of round strands
%        - the litz wire is ideal (insulated and perfectly twisted strands)
%        - the litz wire is defined with a fill factor, the exact strand position is not considered
%
%    The field pattern (current density and magnetic field) are given:
%        - can be obtained from analytical approximations
%        - can be obtained from simulations (FEM, mirroring, etc.)
%
%    The fill factor is defined as: A_copper/A_winding.
%    RMS values are used for the field patterns.
%    Current density integral is defined as: int_winding(J_rms^2 dV).
%    Magnetic field integral is defined as: int_winding(H_rms^2 dV).
%
%    References for the litz wire losses:
%        - Guillod, T. / Litz Wire Losses: Effects of Twisting Imperfections / COMPEL / 2017
%        - Muehlethaler, J. / Modeling and Multi-Objective Optimization of Inductive Power Components / ETHZ / 2012
%        - Ferreira, J.A. / Electromagnetic Modelling of Power Electronic Converters /Kluwer Academics Publishers / 1989.
%
%    Parameters:
%        data_parsed(struct) - struct with data used to setup the plots
%        J_square_int (vector): integral of the square of the RMS current density over the winding
%        H_square_int (vector): integral of the square of the RMS magnetic field over the winding
%        sigma (float): conductivity of the conductor material
%        d_litz (float): strand diameter of the litz wire
%        fill (float): fill factor of the winding
%
%    Returns:
%        P (vector): vector with the spectral loss components
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% main function
%     - 
%     - ctrl - struct with data used to plot the provided data
%     - fig_raster - fig handle for the raster plot
%     - fig_vector - fig handle for the vector plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raster plot
fig_raster = plot_raster(data_parsed.var, data_parsed.color, ctrl.raster);

% vector plot
fig_vector = plot_vector(data_parsed.var, data_parsed.color, data_parsed.highlight, ctrl.vector);

end

function fig = plot_raster(var, color, raster)
% make the raster plot
%     - var - struct with the variables
%     - color - struct with the color scale
%     - raster - setup data for the plot
%     - fig - fig handle for the plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create the figure
fig = figure();
set(gcf, 'renderer', 'zbuffer');
set(gcf,'Units','centimeters')
set(gcf, 'Position', [raster.dx raster.dy raster.x raster.y]);
set(gcf,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[raster.x raster.y])
axes('Units','centimeters','Position',[0 0 raster.x raster.y])
hold('on')

% plot the data
if raster.make_plot==true
    plot_fill(var)
    plot_line(var, color)
end

% setup the axis limits
axis('off')
ylim([0 1])
xlim([1 var.n_var])

end

function fig = plot_vector(var, color, highlight, vector)
% make the raster plot
%     - var - struct with the variables
%     - color - struct with the color scale
%     - highlight - struct with the highlighted designs
%     - vector - setup data for the plot
%     - fig - fig handle for the plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% relative space in y direction for the axis
delta_bottom = 0.25;
delta_top = 0.1;

% relative space in x direction for the axis and the colorbar
delta_x = 0.05;

% relative space for the title, ranges, labels, and colorbar
delta_range = 0.02;
delta_text = 0.02+0.04;

% realtive space for the colorbar
delta_colorbar_span = 0.04;
delta_colorbar_start = 0.10;

% create the figure
fig = figure();
set(gcf, 'Render', 'painters')
set(gcf, 'Units','centimeters', 'Position', [vector.dx vector.dy vector.x vector.y]);
set(gcf,'PaperPositionMode','Auto','PaperUnits','centimeters', 'PaperSize',[vector.x vector.y])

% create the axes and colorbar
axes('Position',[delta_x delta_bottom 1.0-delta_x-delta_x 1.0-delta_bottom-delta_top])
colorbar('Location', 'southoutside', 'TickLength', 0, 'Position', [delta_x delta_colorbar_start 1.0-delta_x-delta_x delta_colorbar_span], 'TickLabels', {});
hold('on')

% plot the data
if vector.make_plot==true
    plot_fill(var)
    plot_line(var, color)
end
plot_range(var)
plot_highlight(var, highlight)

% setup the y axis limits
ylim([0 1])
yticks([0 1])
yticklabels({})

% setup the x axis limits
xlim([1 var.n_var])
xticks(1:var.n_var)
xticklabels({})

% setup the color axis limits
caxis([min(color.range) max(color.range)]);

% get the position of the ticks, labels, and title
y_tick_bottom = get_axis_from_fig(delta_bottom-delta_range, delta_bottom, delta_top);
y_tick_top = get_axis_from_fig(1.0-delta_top+delta_range, delta_bottom, delta_top);
y_title = get_axis_from_fig(1.0-delta_top+delta_text, delta_bottom, delta_top);
y_label = get_axis_from_fig(delta_bottom-delta_text, delta_bottom, delta_top);

% add the ticks and labels
for i=1:var.n_var
    range_min = var.range_min_vec(i);
    range_max = var.range_max_vec(i);
    
    plot_text(i, y_tick_bottom, num2str(range_min))
    plot_text(i, y_tick_top, num2str(range_max))
    plot_text(i, y_label, var.name_vec{i})
end

% add the title
plot_title((var.n_var+1)./2, y_title, vector.title)

% get the position of the colorbar ticks and label
y_tick = get_axis_from_fig(delta_colorbar_start-delta_range, delta_bottom, delta_top);
y_label = get_axis_from_fig(delta_colorbar_start-delta_text, delta_bottom, delta_top);

% scale the colorbar range
color_scale = (color.range-min(color.range))./(max(color.range)-min(color.range));

% add the colorbar ticks
for i=1:length(color.range)
    pos = color_scale(i).*(var.n_var-1)+1;
    text(pos, y_tick, num2str(color.range(i)), 'Interpreter', 'none','FontName', 'Times New Roman', 'FontSize', 12, 'HorizontalAlignment', 'center')
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

end

function plot_range(var)
% plot the range (min/max) of the different variables
%     - var - struct with the variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the min/max
v_max = max(var.scale_mat, [], 2);
v_min = min(var.scale_mat, [], 2);

% plot the lines
for i=1:var.n_var
    plot([i i], [v_min(i) v_max(i)], 'k', 'LineWidth', 3.0)
end

end

function plot_highlight(var, highlight)
% plot the highlighted designs
%     - var - struct with the variables
%     - highlight - struct with the highlighted designs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:highlight.n_highlight
    vec = var.scale_mat(:,highlight.idx_vec(i));
    plot(1:var.n_var, vec, highlight.color_vec{i}, 'LineWidth', 1.5)
end

end

function plot_fill(var)
% plot the background color of the variables
%     - var - struct with the variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:var.n_var
    plot_fill_sub([i-0.5 i+0.5], [0 1], var.color_vec{i})
end

end

function plot_line(var, color)
% plot all the designs with the colormap
%     - var - struct with the variables
%     - color - struct with the color scale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
% add a text at a given position (with respect to axis coordinates)
%     - x - x position
%     - y - y position
%     - str - text string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text(...
    x, y, str,...
    'Interpreter', 'none',...
    'FontName',...
    'Times New Roman',...
    'FontSize', 12,...
    'HorizontalAlignment', 'center'...
    )

end

function plot_title(x, y, str)
% add a title at a given position (with respect to axis coordinates)
%     - x - x position
%     - y - y position
%     - str - text string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text(...
    x, y, str,...
    'Interpreter', 'none',...
    'FontName', 'Times New Roman',...
    'FontSize', 14,...
    'HorizontalAlignment', 'center',...
    'FontWeight', 'bold'...
    )

end

function y_axis = get_axis_from_fig(y_fig, delta_bottom, delta_top)
% add a text at a given position (with respect to axis coordinates)
%     - x - x position
%     - y - y position
%     - str - text string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y_axis = (y_fig-delta_bottom)./(1.0-delta_bottom-delta_top);

end

function plot_line_sub(x, y, c)
% plot colored line (trick with surface fct)
%     - x - x vector
%     - y - y vector
%     - c - color vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the coordinates
x = [x.' x.'];
y = [y.' y.'];
z = zeros(length(c),2);
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

function plot_fill_sub(x, y, color)
% plot colored rectangle in the background
%     - x - x span (two elements)
%     - y - y span (two elements)
%     - c - color identifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the coordinates
x_fill = [min(x) max(x) max(x) min(x)];
y_fill = [min(y) min(y) max(y) max(y)];

% fill the area
fill(...
    x_fill, y_fill, 'k',...
    'LineStyle', 'none',...
    'FaceAlpha', 0.15,...
    'FaceColor', color...
    );

end