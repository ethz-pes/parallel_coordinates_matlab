function data_parsed = get_parse(data_raw, ctrl)
% Prepare the data for parallel coordinates plot.
%
%    Filter and sort the provided dataset.
%    Find the color of the lines.
%    Select the lines to highlight.
%    Find the variables name, scaling, ranges
%
%    If many lines exist, the generated plot is potentially huge.
%
%    Parameters:
%        data_raw (struct): struct with the provided dataset
%        ctrl (struct): struct with plot parameters
%
%    Returns:
%        data_parsed (struct): struct with the data to be plotted
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% load the data
res = data_raw.res;
n_sol = data_raw.n_sol;

% extract
filter = ctrl.filter;
sort = ctrl.sort;
highlight_idx = ctrl.highlight_idx;
var_axis = ctrl.var_axis;
color_axis = ctrl.color_axis;

% filter and sort
[res, n_sol] = filter_sort(res, n_sol, filter, sort);

% get the color scale
color = get_color(res, n_sol, color_axis);

% find the curves to highlight
highlight = get_highlight(res, n_sol, highlight_idx);

% parsed the variable
var = get_var(res, n_sol, var_axis);

% display the parsed data
disp_data_parsed(highlight, var)

% assign the data
data_parsed.color = color;
data_parsed.highlight = highlight;
data_parsed.var = var;

end

function [res_sort, n_sol_sort] = filter_sort(res_raw, n_sol_raw, filter, sort)
% Filter and sort the dataset.
%
%    Parameters:
%        res_raw (struct): input dataset
%        n_sol_raw (integer): number of data in the dataset
%        filter(struct): filtering rule
%        sort(struct): sorting rule
%
%    Returns:
%        res_sort (struct): sorted and filtered dataset
%        n_sol_sort (integer): number of sorted and filtered data in the dataset

% filter
idx = filter(res_raw, n_sol_raw);
n_sol_filter = nnz(idx);
res_filter = get_filter(res_raw, idx);

% sort
idx = sort(res_filter, n_sol_filter);
n_sol_sort = nnz(idx);
res_sort = get_filter(res_filter, idx);

% display the number of data
fprintf('n_sol\n')
fprintf('    n_sol_raw = %d\n', n_sol_raw)
fprintf('    n_sol_filter = %d\n', n_sol_filter)
fprintf('    n_sol_sort = %d\n', n_sol_sort)

end

function color = get_color(res, n_sol, color_axis)
% Get the color scale data.
%
%    Parameters:
%        res (struct): dataset
%        n_sol (integer): number of data in the dataset
%        color (struct): coloring rule
%
%    Returns:
%        color_parsed (struct) - parsed color scale data

% extract
fct  = color_axis.fct;
name  = color_axis.name;
range  = color_axis.range;
scale  = color_axis.scale;

% get the color vector
vec = fct(res, n_sol);

% scale the colormap
vec = get_scale(vec, range, scale);

% position of the ticks
tick = get_scale(range, range, scale);

% assign the data
color = struct(...
    'vec', vec, ...
    'tick', tick,...
    'range', range,...
    'name', name...
    );

end

function highlight = get_highlight(res, n_sol, highlight_idx)
% Get the highlighted lines.
%
%    Parameters:
%        res (struct): dataset
%        n_sol (integer): number of data in the dataset
%        highlight (struct): highlighting rule
%
%    Returns:
%        highlight_parsed (struct): parsed highlighted lines data

% get the indices of the lines to highlight
for i=1:length(highlight_idx)
    highlight_tmp = highlight_idx{i};
    fct = highlight_tmp.fct;
    name = highlight_tmp.name;
    color = highlight_tmp.color;
        
    idx_vec(i) = fct(res, n_sol);
    color_vec{i} = color;
    name_vec{i} = name;
end

% assign the data
highlight = struct(...
    'n_highlight', length(highlight_idx),...
    'idx_vec', {idx_vec},...
    'color_vec', {color_vec},...
    'name_vec', {name_vec}...
    );

end

function var = get_var(res, n_sol, var_axis)
% Parse and scale the variables.
%
%    Parameters:
%        res (struct): dataset
%        n_sol (integer): number of data in the dataset
%        var (struct): var scaling and naming rules
%
%    Returns:
%        var_parsed (struct): parsed variables data

% get the scaling of the variables
for i=1:length(var_axis)
    var_tmp = var_axis{i};
    fct = var_tmp.fct;
    name = var_tmp.name;
    color = var_tmp.color;
    range = var_tmp.range;
    scale = var_tmp.scale;
    
    vec = fct(res, n_sol);
    vec_scale = get_scale(vec, range, scale);
    
    raw_mat(i,:) = vec;
    scale_mat(i,:) = vec_scale;
    name_vec{i} = name;
    color_vec{i} = color;
    range_min_vec(i) = min(range);
    range_max_vec(i) = max(range);
end

% assign the data
var = struct(...
    'n_var', length(var_axis),...
    'n_sol', n_sol,...
    'scale_mat', {scale_mat},...
    'raw_mat', {raw_mat},...
    'name_vec', {name_vec},...
    'range_min_vec', {range_min_vec},...
    'range_max_vec', {range_max_vec},...
    'color_vec', {color_vec}...
    );

end

function disp_data_parsed(highlight, var)
% Display the parsed data.
%
%    Parameters:
%        highlight (struct): parsed highlighted lines data
%        var (struct): parsed variables data

% highlighted lines
fprintf('highlight\n')
fprintf('    n_highlight = %d\n', highlight.n_highlight)
fprintf('    highlight\n')
for i=1:highlight.n_highlight
    fprintf('        %s = %s / %d\n', highlight.name_vec{i}, highlight.color_vec{i}, highlight.idx_vec(i))
end

% variable number
fprintf('var\n')
fprintf('    n_var = %d\n', var.n_var)
fprintf('    n_sol = %d\n', var.n_sol)

% variable content
fprintf('    var\n')
for i=1:var.n_var
    vec = var.raw_mat(i, :);
    color = var.color_vec{i};
    range_min = var.range_min_vec(i);
    range_max = var.range_max_vec(i);
    
    % range and min/max
    fprintf('        %s\n', var.name_vec{i})
    fprintf('            color = %s\n', color)
    fprintf('            range = [%.3f, %.3f]\n', range_min, range_max)
    fprintf('            min_max = [%.3f, %.3f]\n', min(vec), max(vec))
    
    % highlighted line values
    fprintf('            highlight\n')
    for j=1:highlight.n_highlight
        fprintf('                %s = %.3f\n', highlight.name_vec{j}, vec(highlight.idx_vec(j)))
    end
end

end

function res_filter = get_filter(res, idx)
% Filter and reorder a dataset (struct of arrays).
%
%    Parameters:
%        res (struct): input data
%        idx (vector): filter or permutation vector
%
%    Returns:
%        res_filter (struct): output data

field = fieldnames(res);
for i=1:length(field)
    res_filter.(field{i}) = res.(field{i})(idx);
end

end

function vec_scale = get_scale(vec_original, range, scale)
% Normalize a vector with respect to bounds.
%
%    Parameters:
%        vec_original (vector): input vector
%        range (vector): vector with the bounds
%        range (string): scaling type
%
%    Returns:
%        vec_scale (vector): scaled vector

switch scale
    case 'lin'
        vec_scale = (vec_original-min(range))./(max(range)-min(range));
    case 'log'
        vec_scale = (log10(vec_original)-log10(min(range)))./(log10(max(range))-log10(min(range)));
end

end