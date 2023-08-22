function MakeGraphs(Colist,Exlist,Variable,p,i)
% Creates histogram plots based on the control and experimental groups in
% BBIDs
%   Detailed explanation goes here
subplot(2,4,i);
h1 = hist(Colist);
h2 = hist(Exlist);
bar(h1,'facecolor','b','facealpha',.6,'EdgeAlpha', 0);
box off;
hold on;
bar(h2,'facealpha',0,'edgecolor','r','LineWidth',2);
hold off;
legend('Control Data', 'Experimental Data');
title([Variable ' Comparison']);
if p <= 0.05
    text(.6 * max([Colist; Exlist]), .8 * max([h1 h2]), ['* p = ' num2str(p)])
else
    text(.6 * max([Colist; Exlist]), .8 * max([h1 h2]), ['p = ' num2str(p)])
end
xlabel('Hourly Nose Pokes');
ylabel('Frequency');
end
