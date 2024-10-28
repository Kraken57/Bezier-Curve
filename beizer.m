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
            
            % Plot the new control point
            plot(newPoint(1), newPoint(2), 'ro', 'MarkerSize', 10); % Draw control point

            % Clear previous curve
            cla(gca);
            grid on; % Retain grid
            hold on;
            axis([0 1 0 1]);
            title('Click to add control points (Press Backspace to remove last point)');
            
            % Re-plot control points
            plot(controlPoints(:, 1), controlPoints(:, 2), 'ro', 'MarkerSize', 10);
            
            % Draw Bézier curve if there are enough points
            if size(controlPoints, 1) > 1
                t = linspace(0, 1, 100);
                curvePoints = lagrangeInterpolation(controlPoints, t);
                plot(curvePoints(:, 1), curvePoints(:, 2), 'b-', 'LineWidth', 2);
                
                % Calculate and display error
                error = calculateError(controlPoints, curvePoints);
                displayError(error);
            end
        else
            disp('Control point must be within the bounds [0, 1]');
        end
    end

    % Lagrange interpolation to calculate curve points
    function curvePoints = lagrangeInterpolation(controlPoints, t)
        n = size(controlPoints, 1);
        curvePoints = zeros(length(t), 2);
        
        for k = 1:length(t)
            curvePoints(k, :) = lagrangePolynomial(controlPoints, t(k), n);
        end
    end

    % Calculate Lagrange polynomial for a given t
    function point = lagrangePolynomial(controlPoints, t, n)
        point = [0, 0];
        
        for i = 1:n
            L = 1; % Lagrange basis polynomial
            
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
                cla(gca);
                grid on; % Retain grid
                hold on;
                axis([0 1 0 1]);
                title('Click to add control points (Press Backspace to remove last point)');
                
                % Re-plot control points
                plot(controlPoints(:, 1), controlPoints(:, 2), 'ro', 'MarkerSize', 10);
                
                % Draw Bézier curve if there are enough points
                if size(controlPoints, 1) > 1
                    t = linspace(0, 1, 100);
                    curvePoints = lagrangeInterpolation(controlPoints, t);
                    plot(curvePoints(:, 1), curvePoints(:, 2), 'b-', 'LineWidth', 2);
                    
                    % Calculate and display error
                    error = calculateError(controlPoints, curvePoints);
                    displayError(error);
                end
            end
        end
    end

    % Calculate the maximum error between the Bézier curve and linear interpolation
    function error = calculateError(controlPoints, curvePoints)
        % Linear interpolation between control points
        t_interp = linspace(0, 1, size(curvePoints, 1));
        linearPoints = zeros(size(curvePoints));
        
        for i = 1:size(controlPoints, 1) - 1
            % Interpolate between each pair of control points
            segment_t = linspace(i/(size(controlPoints, 1)-1), (i+1)/(size(controlPoints, 1)-1), 100);
            linearPoints((i-1)*100+1:i*100, :) = ...
                (1 - segment_t') * controlPoints(i, :) + segment_t' * controlPoints(i+1, :);
        end
        
        % Calculate error as the maximum distance from linear points to curve points
        error = max(vecnorm(curvePoints - linearPoints(1:size(curvePoints, 1), :), 2, 2));
    end

    % Display error on the plot
    function displayError(error)
        text(0.5, 0.9, sprintf('Max Error: %.4f', error), 'HorizontalAlignment', 'center', ...
             'FontSize', 10, 'Color', 'k', 'BackgroundColor', 'w');
    end
end
