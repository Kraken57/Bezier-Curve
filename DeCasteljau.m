function bezierCurveVisualization()
    % Create a figure for the visualization
    figure('Name', 'Bézier Curve Visualization', ...
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
                t = linspace(0, 1, 200);  % Increase resolution
                curvePoints = deCasteljau(controlPoints, t);  % Use De Casteljau's algorithm
                plot(curvePoints(:, 1), curvePoints(:, 2), 'b-', 'LineWidth', 2);
            end
        else
            disp('Control point must be within the bounds [0, 1]');
        end
    end

    % De Casteljau algorithm for Bézier curve
    function curvePoints = deCasteljau(controlPoints, t)
        n = size(controlPoints, 1) - 1;
        curvePoints = zeros(length(t), 2);

        for k = 1:length(t)
            tempPoints = controlPoints;
            for r = 1:n
                tempPoints = (1 - t(k)) * tempPoints(1:end-1, :) + t(k) * tempPoints(2:end, :);
            end
            curvePoints(k, :) = tempPoints;
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
                    t = linspace(0, 1, 200);  % Higher resolution for smoothness
                    curvePoints = deCasteljau(controlPoints, t);
                    plot(curvePoints(:, 1), curvePoints(:, 2), 'b-', 'LineWidth', 2);
                end
            end
        end
    end
end
