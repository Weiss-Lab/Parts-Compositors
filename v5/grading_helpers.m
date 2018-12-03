function helpers = grading_helpers
    helpers.VariableExists = @VariableExists;
    helpers.CheckPlotValues = @CheckPlotValues;
    helpers.CheckPlotAxisValues = @CheckPlotAxisValues;
    helpers.CheckPlotAxesLabels = @CheckPlotAxesLabels;
    helpers.StringsEqualAsSets = @StringsEqualAsSets;
    helpers.GetNames = @GetNames;
    helpers.CheckBioSystemHasCompositors = @CheckBioSystemHasCompositors;
    helpers.CheckBioSystemInitialConditions = @CheckBioSystemInitialConditions;
    helpers.CheckBioSystemConstants = @CheckBioSystemConstants;
    helpers.CheckBioSystemParts = @CheckBioSystemParts;
end

function [] = VariableExists(var_name, environment)
    % check whether a variable named var_name exists in environment
    % example: VariableExists('A', whos);

    var_exists = any(strcmpi(var_name, {environment.name}));
    assert(var_exists, [sprintf('Expected a variable named %s ', var_name) ...
                        'in the workspace, but didn''t find it.']);
end

%VariableExists = @(var_name, environment) assert(any(...
%    strcmpi(var_name, {environment.name})), ...
%    [sprintf('Expected a variable named %s ', var_name) ...
%             'in the workspace, but didn''t find it.']);

function [] = CheckPlotAxisValues(axes_handle, line_index, axis, ...
                                  correct, tolerance)
    % checks whether the line line_index in the plot given by axes_handle has
    % the correct values on the 'axis' axis (with appropriate relative
    % tolerance)
    % example to check the first line on the last plot for the Y axis:
    %   CheckPlotValues(gca, 1, 'Y', [1 2 3], 0.01)
    % axis is either 'X' or 'Y'
    child_objs = get(axes_handle, 'children');
    plot_objs = child_objs(strcmp(get(child_objs, 'type'), 'line'));

    % the handles in plot_objs are in the reverse order of being added
    plot_line_index = size(plot_objs, 1) - line_index + 1;

    try
        plot_vals = get(plot_objs(plot_line_index), sprintf('%sData', axis));
    catch me
        disp('There was an error in the grader. Did you draw all the lines?');
        rethrow(me);
    end
    assert(length(correct) == length(plot_vals), ...
        ['Can''t match values on graph with the correct answer -- ' ...
         'the number of datapoints is incorrect (check your equations)'])
    % check values for matching the relative and ~absolute tolerance
    have_correct_vals = all(or( ...
        le(abs(correct - plot_vals), tolerance * correct), ...
        le(abs(plot_vals), abs(max(plot_vals)) * 1e-8)));
    assert(have_correct_vals, ...
           sprintf('%s values for line %d not within tolerance.', ...
           axis, line_index));
end

function [] = CheckPlotValues(axes_handle, line_index, ...
                              correct_x, x_tolerance, ...
                              correct_y, y_tolerance)
    % checks whether the line line_index in the plot given by axes_handle has
    % the correct x and y values (with appropriate relative tolerances for each
    % value)
    % example to check the first line on the last plot:
    %   CheckPlotValues(gca, 1, [1 2 3], 0.01, [2, 4, 5], 0.01)
    CheckPlotAxisValues(axes_handle, line_index, 'X', correct_x, x_tolerance);
    CheckPlotAxisValues(axes_handle, line_index, 'Y', correct_y, y_tolerance);
end

function [] = CheckPlotAxesLabels(axes_handle, x_label, y_label)
    % checks whether the X and Y axes have the correct labels
    % example: CheckPlotAxesLabels(gca, 'X label', 'Y label')

    plot_x_label = get(get(axes_handle, 'XLabel'), 'String');
    correct_x_label = strcmp(plot_x_label, x_label);
    assert(correct_x_label, 'Check your xlabel string');

    plot_y_label = get(get(axes_handle, 'YLabel'), 'String');
    correct_y_label = strcmp(plot_y_label, y_label);
    assert(correct_y_label, 'Check your ylabel string');
end

function result = StringsEqualAsSets(a, b)
    % return set(a) == set(b) for a, b cell arrays of strings
    all_equal = 0;
    if size(a) == size(b)
        all_equal = all(strcmp(sort(a), sort(b)));
    end
    result = all_equal;
end

function names = GetNames(things)
    % return a cell array of .name values for items in things
    names = cell(1, length(things));
    for i = 1:length(things)
        names{i} = things(i).name;
    end
end

function [] = CheckBioSystemHasCompositors(sys, compositors)
    % given a BioSystem, 'sys', and a vector of compositor names,
    % 'compositors', make sure that 'sys' has all the compositors it should
    % (i.e. 'compositors')
    assert(StringsEqualAsSets(GetNames(sys.compositors), compositors) == 1, ...
        ['Compositors are not named correctly ' ...
         'or there are extra compositors or some compositors are undefined'])
end

function [] = CheckBioSystemInitialConditions(sys, compositors, concentrations)
    % check that each compositor has the correct concentration in the BioSystem
    % 'sys'
    assert(length(sys.compositors) == length(compositors), ...
        'You don''t have the right number of compositors!')
    for i = 1:length(compositors)
        assert(sys.compositors(sys.map_compositors(compositors{i})).value == ...
            concentrations(i), ...
            sprintf('You have not initialized the compositor %s correctly', ...
            compositors{i}))
    end
end

function [] = CheckBioSystemConstants(sys, constants, values)
    % check that each compositor has the correct concentration in the BioSystem
    % 'sys'
    assert(length(sys.constants) == length(constants), ...
        'You don''t have the right number of constants defined!')
    for i = 1:length(constants)
        assert(sys.constants(sys.map_constants(constants{i})).value == ...
            values(i), ...
            sprintf('You have not set the constant %s correctly', ...
            constants{i}))
    end
end

function [] = CheckBioSystemParts(sys, correct_sys)
    % check that the rates of each part in 'sys' correspond to that of
    % 'correct_sys'
    % TODO idea: use symbolic equivalence
end
