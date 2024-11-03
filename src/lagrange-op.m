function bezierCurveVisualizationLagrange()
    % Create a figure for the visualization
    figure('Name', 'Bézier Curve Visualization using Lagrange Interpolation', ...
           'WindowButtonDownFcn', @addControlPoint, ...
           'KeyPressFcn', @removeControlPoint);
    hold on;
    grid on;
    axis([0 1 0 1]);
    title('Click to add control points (Press Backspace to remove last point)');

    % Initialize control points
    controlPoints = [];
    % Store control points in the figure's UserData
    set(gcf, 'UserData', controlPoints);

    % Callback function to add control points
    function addControlPoint(~, ~)
        pt = get(gca, 'CurrentPoint');
        newPoint = pt(1, 1:2);
        
        % Ensure the point is within bounds
        if all(newPoint >= 0) && all(newPoint <= 1)
            controlPoints = [get(gcf, 'UserData'); newPoint];  % Append new point
            set(gcf, 'UserData', controlPoints);  % Update UserData
            
            % Clear previous plots
            cla;
            grid on; % Retain grid
            axis([0 1 0 1]);
            title('Click to add control points (Press Backspace to remove last point)');
            
            % Plot all control points
            plot(controlPoints(:, 1), controlPoints(:, 2), 'ro-', 'MarkerSize', 10);
            
            % Draw Bézier curve if there are enough points
            if size(controlPoints, 1) > 1
                t = linspace(0, 1, 500);  % Increase resolution for smoothness
                curvePoints = lagrangeInterpolation(controlPoints, t);
                plot(curvePoints(:, 1), curvePoints(:, 2), 'b-', 'LineWidth', 2);
            end
        else
            disp('Control point must be within the bounds [0, 1]');
        end
    end

    % Lagrange interpolation to calculate curve points
    function curvePoints = lagrangeInterpolation(controlPoints, t)
        n = size(controlPoints, 1);
        curvePoints = zeros(length(t), 2);
        
        % Compute the Lagrange basis polynomial for each control point
        for k = 1:length(t)
            curvePoints(k, :) = computeLagrangePoint(controlPoints, t(k), n);
        end
    end

    % Calculate Lagrange polynomial for a given t
    function point = computeLagrangePoint(controlPoints, t, n)
        point = [0, 0];
        
        for i = 1:n
            % Calculate the ith Lagrange basis polynomial L_i(t)
            L = 1;
            for j = 1:n
                if i ~= j
                    L = L * (t - (j-1)/(n-1)) / ((i-1)/(n-1) - (j-1)/(n-1));
                end
            end
            point = point + L * controlPoints(i, :);
        end
    end

    % Callback function to remove the last control point
    function removeControlPoint(~, event)
        if strcmp(event.Key, 'backspace')
            controlPoints = get(gcf, 'UserData');
            if ~isempty(controlPoints)
                controlPoints(end, :) = []; % Remove last point
                set(gcf, 'UserData', controlPoints); % Update UserData
                
                % Clear previous curve
                cla;
                grid on; % Retain grid
                axis([0 1 0 1]);
                title('Click to add control points (Press Backspace to remove last point)');
                
                % Re-plot control points
                plot(controlPoints(:, 1), controlPoints(:, 2), 'ro-', 'MarkerSize', 10);
                
                % Draw Bézier curve if there are enough points
                if size(controlPoints, 1) > 1
                    t = linspace(0, 1, 500);  % Higher resolution for smoothness
                    curvePoints = lagrangeInterpolation(controlPoints, t);
                    plot(curvePoints(:, 1), curvePoints(:, 2), 'b-', 'LineWidth', 2);
                end
            end
        end
    end
end
