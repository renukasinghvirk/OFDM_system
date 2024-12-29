function plot_constellations(symbols, plot_title)
%   PLOT_CONSTELLATIONS Plots the constellation diagram of transmitted/received symbols.
%   This function visualizes the complex symbols in the I-Q plane, highlighting
%   the first, intermediate, and last symbols with different colors and markers.
%   It also overlays a unit circle to help analyze phase and magnitude distortions.
%
%   INPUTS:
%   - symbols: A vector of complex values representing the transmitted or received symbols.
%   - plot_title: A string specifying the title for the plot.
%
%   OUTPUTS:
%   - None. The function generates and displays the constellation plot.
%
%   Features:
%   1. Plots intermediate symbols as blue crosses.
%   2. Highlights the first symbol in red and the last symbol in green.
%   3. Draws a dashed unit circle for reference.
%   4. Adds grid, axis labels, and a customizable title.

    % Convert to pixels
    figure('Units', 'pixels', 'Position', [100, 100, 500, 500]);
    
    fontsize = 30;
    symbol_size = 20;
    plot(real(symbols(2:end-1)), imag(symbols(2:end-1)), 'bx', 'MarkerSize', symbol_size, 'LineWidth', 3.5); % Default constellation points
    hold on;
    
    % Plot the first symbol in red
    plot(real(symbols(1)), imag(symbols(1)), 'ro', 'MarkerSize', symbol_size, 'LineWidth', 4); % First symbol    
    % Plot the last symbol in green
    plot(real(symbols(end)), imag(symbols(end)), 'gs', 'MarkerSize', symbol_size, 'LineWidth', 4); % Last symbol    
    % Add unit circle
    theta = linspace(0, 2*pi, 100); % Generate angle values for the circle
    unit_circle_x = cos(theta); % X-coordinates of the circle
    unit_circle_y = sin(theta); % Y-coordinates of the circle
    plot(unit_circle_x, unit_circle_y, 'k--', 'LineWidth', 2); % Dashed black line for the unit circle
    
    % Add grid and labels
    grid on;
    xlabel('In-Phase Component', 'FontSize', fontsize);
    ylabel('Quadrature Component', 'FontSize', fontsize);
    title(plot_title, 'FontSize', fontsize);
    legend('Intermediate Symbols', 'First Symbol', 'Last Symbol', 'FontSize', 25, 'Location', 'west');
    ax = gca; % Get current axes
    ax.FontSize = 20; % Set font size for axis tick labels

    hold off;
end