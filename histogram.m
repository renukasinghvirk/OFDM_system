% Define the conditions and BER values
conditions = {'Ideal', '4000Hz noise', 'Obstacles', 'Low volume'};
BER_values = [0.42, 8.4, 8.72, 4.26]; % Values in percentages

% Sort BER values and corresponding conditions in ascending order
[BER_values_sorted, sortIdx] = sort(BER_values); % Sort BER values
conditions_sorted = conditions(sortIdx);         % Reorder conditions accordingly

% Convert conditions to categorical for plotting
conditions_sorted = categorical(conditions_sorted);
conditions_sorted = reordercats(conditions_sorted, string(conditions_sorted)); % Preserve sorted order

% Plot the histogram
figure;
bar(conditions_sorted, BER_values_sorted, 'FaceColor', [0.8, 0, 0]); % Use bar plot for histogram
xlabel('Conditions', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('BER (%)', 'FontSize', 16, 'FontWeight', 'bold');
title('BER per Condition (Sorted in Ascending Order)', 'FontSize', 20, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 14, 'LineWidth', 1.5);

% Save the plot as an image
saveas(gcf, 'BER_histogram_sorted.png');
