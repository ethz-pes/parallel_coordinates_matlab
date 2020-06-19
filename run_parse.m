function run_parse()
% Prepare the data for parallel coordinates plot.
%
%    In this example, the design space diversity of a medium-frequency transformer is considered.
%
%    This example is composed of two files:
%        - run_parse.m - extract and parse the dataset
%        - run_plot.m - make the parallel coordinate plot
%
%    Filter and sort the provided dataset.
%    Find the color of the lines.
%    Select the lines to highlight.
%    Find the variables name, scaling, ranges
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

close('all');
addpath('utils')

%% param

% return the indices of the considered designs (kick the other ones)
%    - filter: function handle returning the valid design indices
%    - res: struct with the designs (struct of arrays)
%    - n_sol: integer with the number of designs
%    - example: select randomly 1% of the designs
ctrl.filter = @(res, n_sol) rand(1, n_sol)>0.99;

% return a permutation vector for sorting the designs
%    - sort: function handle returning the permutation vector
%    - res: struct with the designs (struct of arrays)
%    - n_sol: integer with the number of designs
%    - example: random permutation
ctrl.sort = @(res, n_sol) randperm(n_sol);

% description, extraction, and range of the variable
%    - var: cell array with the variable
%    - name: name of the variable
%    - fct: function handle returning the variable data (vector)
%    - range: range of the variable (axis limits)
%    - color: background color for this variable
ctrl.var = {};
ctrl.var{end+1} = struct('name', 'f [kHz]', 'fct', @(res, n_sol) 1e-3.*res.f, 'range', [0 350], 'color', 'g');
ctrl.var{end+1} = struct('name', 'n [#]', 'fct', @(res, n_sol) res.n, 'range', [0 16], 'color', 'g');
ctrl.var{end+1} = struct('name', 'f_cw [#]', 'fct', @(res, n_sol) res.fact_core_window, 'range', [0 8], 'color', 'g');
ctrl.var{end+1} = struct('name', 'f_c [#]', 'fct', @(res, n_sol) res.fact_core, 'range', [0 8], 'color', 'g');
ctrl.var{end+1} = struct('name', 'f_w [#]', 'fct', @(res, n_sol) res.fact_window, 'range', [0 11], 'color', 'g');
ctrl.var{end+1} = struct('name', 'r_w [#]', 'fct', @(res, n_sol) res.fact_freq_winding, 'range', [0 5], 'color', 'y');
ctrl.var{end+1} = struct('name', 'r_cw [#]', 'fct', @(res, n_sol) res.fact_core_winding, 'range', [0 3], 'color', 'y');
ctrl.var{end+1} = struct('name', 'J [A/mm2]', 'fct', @(res, n_sol) 1e-6.*res.J_rms_winding, 'range', [0 7], 'color', 'y');
ctrl.var{end+1} = struct('name', 'B [mT]', 'fct', @(res, n_sol) 1e3.*res.B_peak_core, 'range', [0 180], 'color', 'y');
ctrl.var{end+1} = struct('name', 'dT [degC]', 'fct', @(res, n_sol) res.delta_T, 'range', [0 100], 'color', 'y');
ctrl.var{end+1} = struct('name', 'eta [%]', 'fct', @(res, n_sol) 1e2.*res.eta, 'range', [99.5 100.0], 'color', 'r');

% describe the color scale 
%    - color: struct with the color scale data
%    - name: name of the color axis
%    - fct: function handle returning the color value (vector)
%    - range: range of the color scale (axis limits and ticks)
ctrl.color = struct('name', 'f [kHz]', 'fct', @(res, n_sol) 1e-3.*res.f, 'range', 0:50:350);

% describe the highlighted designs 
%    - var: cell array with the highlighted designs
%    - name: name of the design
%    - fct: function handle returning the index of the selected design
%    - color: color of the curve for the design
ctrl.highlight = {};
ctrl.highlight{end+1} = struct('name', 'best', 'fct', @(res, n_sol) get_idx_max(res.eta), 'color', 'r');
ctrl.highlight{end+1} = struct('name', 'min', 'fct', @(res, n_sol) get_idx_min(res.f), 'color', 'r');
ctrl.highlight{end+1} = struct('name', 'max', 'fct', @(res, n_sol) get_idx_max(res.f), 'color', 'r');

%% run

% load the data
data_raw = load('data/data_raw.mat');

% parse the struct
data_parsed = get_parse(data_raw, ctrl);

% save the data
save('data/data_parsed.mat', '-struct', 'data_parsed');

end

function idx = get_idx_max(v)
% Get the index of the maximum element.
%
%    Parameters:
%        v (vector): vector to be considered
%
%    Returns:
%        idx (integer): index of the maximum

[v, idx] = max(v);

end

function idx = get_idx_min(v)
% Get the index of the minimum element.
%
%    Parameters:
%        v (vector): vector to be considered
%
%    Returns:
%        idx (integer): index of the minimum

[v, idx] = min(v);

end
