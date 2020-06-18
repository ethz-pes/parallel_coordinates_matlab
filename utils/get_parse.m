% =================================================================================================
% Prepare the data for parallel coordinates plot (internal function).
% =================================================================================================
%
% See also:
%     - run_parse (function calling by this function)
%
% =================================================================================================
% Thomas Guillod <guillod@lem.ee.ethz.ch>
% PES ETHZ
% =================================================================================================

function data_parsed = get_parse(name, data_raw, ctrl)
% main function
%     - name - name of the dataset
%     - data_raw - raw data
%     - ctrl - struct with data used to parse the provided data
%     - data_parsed - parsed data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('============================== %s ==============================\n', name)

% load the data
res = data_raw.res;
n_sol = data_raw.n_sol;

% filter and sort
[res, n_sol] = filter_sort(res, n_sol, ctrl.filter, ctrl.sort);

% color scale
color = get_color(res, n_sol, ctrl.color);

% highlight
highlight = get_highlight(res, n_sol, ctrl.highlight);

% parsed the variable
var = get_var(res, n_sol, ctrl.var);

% disp the parsed data
disp_data_parsed(color, highlight, var)

% assign the data
data_parsed.color = color;
data_parsed.highlight = highlight;
data_parsed.var = var;

fprintf('============================== %s ==============================\n', name)

end

function [res_sort, n_sol_sort] = filter_sort(res_raw, n_sol_raw, filter, sort)
% filter and sort the data
%     - res_raw - input designs
%     - n_sol_raw - number of input designs
%     - filter - filtering rule
%     - sort - sorting rule
%     - res_sort - sorted and filtered designs
%     - n_sol_sort - number of sorted and filtered designs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filter
idx = filter(res_raw, n_sol_raw);
n_sol_filter = nnz(idx);
res_filter = get_filter(res_raw, idx);

% sort
idx = sort(res_filter, n_sol_filter);
n_sol_sort = nnz(idx);
res_sort = get_filter(res_filter, idx);

% display the number of designs
fprintf('n_sol\n')
fprintf('    n_sol_raw = %d\n', n_sol_raw)
fprintf('    n_sol_filter = %d\n', n_sol_filter)
fprintf('    n_sol_sort = %d\n', n_sol_sort)

end

function color_parsed = get_color(res, n_sol, color)
% get the color scale data
%     - res - designs
%     - n_sol - number of designs
%     - color - coloring rule
%     - color_parsed - color scale data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the color vector
color_vec = color.fct(res, n_sol);

% assign the data
color_parsed = struct(...
    'vec', color_vec, ...
    'name', color.name,...
    'range', color.range...
    );

end

function highlight_parsed = get_highlight(res, n_sol, highlight)
% get the highlighted designs
%     - res - designs
%     - n_sol - number of designs
%     - highlight - highlighting rule
%     - highlight_parsed - highlighted designs data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the indices of the designs
for i=1:length(highlight)
    highlight_tmp = highlight{i};
    idx = highlight_tmp.fct(res, n_sol);
    
    idx_vec(i) = idx;
    color_vec{i} = highlight_tmp.color;
    name_vec{i} = highlight_tmp.name;
end

% assign the data
highlight_parsed = struct(...
    'n_highlight', length(highlight),...
    'idx_vec', {idx_vec},...
    'color_vec', {color_vec},...
    'name_vec', {name_vec}...
    );

end

function var_parsed = get_var(res, n_sol, var)
% parse and scale the variables
%     - res - designs
%     - n_sol - number of designs
%     - var - var scaling and naming rules
%     - var_parsed - parsed variables data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the scaling of the variables
for i=1:length(var)
    var_tmp = var{i};
    vec = var_tmp.fct(res, n_sol);
    vec_scale = get_scale(vec, var_tmp.range);

    scale_mat(i,:) = vec_scale;
    raw_mat(i,:) = vec;
    name_vec{i} = var_tmp.name;
    color_vec{i} = var_tmp.color;
    range_min_vec(i) = min(var_tmp.range);
    range_max_vec(i) = max(var_tmp.range);
end

% assign the data
var_parsed = struct(...
    'n_var', length(var),...
    'n_sol', n_sol,...
    'scale_mat', {scale_mat},...
    'raw_mat', {raw_mat},...
    'name_vec', {name_vec},...
    'range_min_vec', {range_min_vec},...
    'range_max_vec', {range_max_vec},...
    'color_vec', {color_vec}...
);

end

function disp_data_parsed(color, highlight, var)
% display the parsed data
%     - color - color scale data
%     - highlight - highlighted designs data
%     - var_parsed - parsed variables data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% color scale
fprintf('color\n')
fprintf('    %s\n', color.name)
fprintf('    range = [%f, %f]\n', min(color.range), max(color.range))

% highlighted designs
fprintf('highlight\n')
fprintf('    n_highlight = %d\n', highlight.n_highlight)
fprintf('    highlight\n')
for i=1:highlight.n_highlight
    fprintf('        %s = %s\n', highlight.name_vec{i}, highlight.color_vec{i})
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
    fprintf('            range = [%f, %f]\n', range_min, range_max)
    fprintf('            min_max = [%f, %f]\n', min(vec), max(vec))
    
    % highlighted designs values
    fprintf('            highlight\n')
    for j=1:highlight.n_highlight
        fprintf('                %s = %f\n', highlight.name_vec{j}, vec(highlight.idx_vec(j)))
    end
end

end

function res_filter = get_filter(res, idx)
% filter and reorder the designs
%     - res - input designs
%     - idx - filter or permutation vector
%     - res_filter - output designs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

field = fieldnames(res);
for i=1:length(field)
    res_filter.(field{i}) = res.(field{i})(idx);
end

end

function vec_scale = get_scale(vec_original, range)
% normalize a vector with respect to bounds
%     - vec_original - input vector
%     - range - vector with the bounds
%     - vec_scale - scaled vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vec_scale = (vec_original-min(range))./(max(range)-min(range));

end