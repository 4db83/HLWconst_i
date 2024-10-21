clear;clc;
% first read the data used in estimation
% out = readtable('../inputData/US.data.csv')
% usdata_hlw = table2timetable(out);
% save('../inputData/usdata_hlw.mat','usdata_hlw')
load('./inputData/usdata_hlw.mat')
% usdata_hlw
% SET PATH TO TOOLBOX IF NEEDED: WIN (\) AND MAC/UNIX (/)
% addpath(genpath('./utility.Functions'))             % local path to utility.Functions
addpath(genpath('D:/matlab.tools/db.toolbox/db'))     % set path to db functions

%% now read teh different csv output files for the variosu scenarios
% twosided = 'two.sided.'

varnames = {'HLW','HLW-2','HLW-1','HLW0','HLW1','HLW2','HLW3','HLW4','HLW5'};
% read in from teh csv files 
% rstar	g	z	output gap
for ii = 1:length(varnames)
  two_out(:,:,ii) = dlmread(['./output/two.sided.' varnames{ii} '.csv'],',',1,1);
  one_out(:,:,ii) = dlmread(['./output/one.sided.' varnames{ii} '.csv'],',',1,1);
end

% extract the variables of interest
rstar.filtered = array2timetable(squeeze(one_out(:,1,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
rstar.smoothed = array2timetable(squeeze(two_out(:,1,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
% trend growth g
g.filtered     = array2timetable(squeeze(one_out(:,2,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
g.smoothed     = array2timetable(squeeze(two_out(:,2,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
% other factor z
z.filtered     = array2timetable(squeeze(one_out(:,3,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
z.smoothed     = array2timetable(squeeze(two_out(:,3,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
% output gap ytld
ytld.filtered  = array2timetable(squeeze(one_out(:,4,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);
ytld.smoothed  = array2timetable(squeeze(one_out(:,4,:)), 'RowTimes',usdata_hlw.Date(5:end), 'VariableNames',varnames);

%% PLOT THE RSTAR ESTIMATES 
set(groot,'defaultLineLineWidth',2); 
moveup = @(x) (get(gca,'Position') + [-.08 x .13 .02]);
stp = -1.28;
clf
fnt = 17;
Dates = usdata_hlw.Date(5:end);
T0 = find( datenum(Dates) == datenum('2008-01-01'));
TT = length(Dates);
vnames0 = char(varnames);
vnames = cellstr([vnames0(2:end,1:3) repmat(', with $i= ', 8,1) num2str((-2:5)') repmat('$',8,1)]);
vnames = [{'HLW Original'}; vnames];
disp(['Date of fixinig the nominal rate:  ' lstd(Dates(T0))]);
disp('plotting now')
TYPE_ = 'Filtered';

SMOOTHED_ = 0;
if SMOOTHED_ TYPE_ = 'Smoothed'; end

% THIS TRUNCATES WHAT TO PLOT
kk = 2;

% make interest rate seris to be plotted
interest_rates_2_plot = repmat(usdata_hlw.interest(5:end),1,9);
interest_rates_2_plot(T0:end,2:end) = repmat([-2:5],TT-T0+1,1);
interest_rates_2_plot(1:T0-1,:) = nan; % for plotting, remove the other series of the counterfactual series

subplot(5,1,1);
hold on; 
  plot(interest_rates_2_plot(:,kk:end))
  plot(usdata_hlw.interest(5:end),'k--')
  setplot(moveup(.04),0,fnt)
  setdateticks(Dates,20)
hold off; hline(0)
setoutsideTicks
add2yaxislabel
% addlegend(vnames([kk:end 1]),[],13)
addsubtitle('Actual and counterfactual interest rates $i_t$', stp)

subplot(5,1,2);hold on; 
               xplot = rstar.filtered.Variables;
  if SMOOTHED_ xplot = rstar.smoothed.Variables; end
  plot(xplot(:,kk:end))
  plot(xplot(:,1),'k--')
  setplot(moveup(.02),0,fnt)
  setdateticks(Dates,20)
hold off; hline(0)
setoutsideTicks
add2yaxislabel
addlegend(vnames([kk:end 1]), 7,13)
addsubtitle([TYPE_ ' natural rate $r^\ast_t$'], stp)

subplot(5,1,3);hold on; 
               xplot = g.filtered.Variables;
  if SMOOTHED_ xplot = g.smoothed.Variables; end
  plot(xplot(:,kk:end))
  plot(xplot(:,1),'k--')
  setplot(moveup(.00),0,fnt)
  setdateticks(Dates,20)
hold off;
setyticklabels(0:2:6,0)
setoutsideTicks
add2yaxislabel
% addlegend(vnames([kk:end 1]),[],13)
addsubtitle([TYPE_ ' trend growth $g_t$'], stp)

subplot(5,1,4);hold on; 
               xplot = z.filtered.Variables;
  if SMOOTHED_ xplot = z.smoothed.Variables; end
  plot(xplot(:,kk:end))
  plot(xplot(:,1),'k--')
  setplot(moveup(-.02),0,fnt)
  setdateticks(Dates,20)
  hline(0)
hold off;
setyticklabels(-2:1:2,0)
setoutsideTicks
add2yaxislabel
% addlegend(vnames([kk:end 1]),[],13)
addsubtitle([TYPE_ ' other factor $z_t$'], stp)

subplot(5,1,5);hold on; 
               xplot = ytld.filtered.Variables;
  if SMOOTHED_ xplot = ytld.smoothed.Variables; end
  plot(xplot(:,kk:end))
  plot(xplot(:,1),'k--')
  setplot(moveup(-.04),0,fnt)
  setdateticks(Dates,20)
  hline(0)
hold off;
setyticklabels(-8:2:6,0)
setoutsideTicks
add2yaxislabel
% addlegend(vnames([kk:end 1]),[],13)
addsubtitle([TYPE_ ' output gap $\tilde{y}_t$'], stp)

% print2pdf('counter_factual_filtered')

% subplot(5,1,2);
% hold on;
%   xplot = rstar.smoothed.Variables;
%   plot(xplot(:,kk:end))
%   ylim([0 6])
%   plot(xplot(:,1),'k--')
%   setplot(moveup(-.05),0,fnt)
%   setdateticks(Dates,20)
% hold off;
% setoutsideTicks
% add2yaxislabel
% addlegend(vnames([kk:end 1]),[],13)
% addsubtitle('Smoothed natural rate $r^\ast_t$', stp)

% print2pdf('counter_factual_smoohted')

% subplot(5,1,4);
% hold on;
%   xplot = z.filtered.Variables;
% %   plot(xplot(:,1),'k','LineWidth',3)
%   plot(xplot(:,kk:end))
%   ylim([-2 1.5])
%   plot(xplot(:,1),'k--')
%   setplot(moveup(.00),1,15)
%   setdateticks(Dates,20)
% hold off; hline(0)
% setoutsideTicks
% add2yaxislabel
% % addlegend(varnames([4:end 1]))
% addsubtitle('Filtered other factor $z_t$', stp)
% 
% subplot(5,1,5);
% hold on;
%   xplot = z.smoothed.Variables;
% %   plot(xplot(:,1),'k','LineWidth',3)
%   plot(xplot(:,kk:end))
%   ylim([-2 1.5])
%   plot(xplot(:,1),'k--')
%   setplot(moveup(.08),1,15)
%   setdateticks(Dates,20)
% hold off; hline(0)
% setoutsideTicks
% add2yaxislabel
% % addlegend(varnames([4:end 1]))
% addsubtitle('Smoothed other factor $z_t$', stp)


disp('Done')
















