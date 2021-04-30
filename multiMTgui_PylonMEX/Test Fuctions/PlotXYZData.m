%Plot xy data
figure(1); clf;
colors = lines(num_tracks);
for n=1:num_tracks
    subplot(3,1,1);hold on;
    plot(Time,XY(:,2*(n-1)+1)-XY(1,2*(n-1)+1),'-','color',colors(n,:)); %x
    xlabel('Time');
    ylabel('X [px]');
    subplot(3,1,2);hold on;
    plot(Time,XY(:,2*(n-1)+2)-XY(1,2*(n-1)+2),'-','color',colors(n,:)); %y
    xlabel('Time');
    ylabel('Y [px]');
    subplot(3,1,3);hold on;
    plot(TimeZ,Z(:,2*(n-1)+1),'-','color',colors(n,:)); %z
    xlabel('Time');
    ylabel('Z [µm]');
end
legend(sprintfc('Trk: %d',(1:num_tracks)'));