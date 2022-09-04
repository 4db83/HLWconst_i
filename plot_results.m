clear;clc;
% first read the data used in estimation
% out = readtable('../inputData/US.data.csv')
% usdata_hlw = table2timetable(out);
% save('../inputData/usdata_hlw.mat','usdata_hlw')
load('../inputData/usdata_hlw.mat')
% usdata_hlw

%% now read teh different csv output files for the variosu scenarios
% twosided = 'two.sided.'

varnames = {'HLW','HLW-2','HLW-1','HLW0','HLW1','HLW2','HLW3','HLW4','HLW5'};
% read in from teh csv files 
% rstar	g	z	output gap
for ii = 1:length(varnames)
  two_out(:,:,ii) = dlmread(['two.sided.' varnames{ii} '.csv'],',',1,1);
  one_out(:,:,ii) = dlmread(['one.sided.' varnames{ii} '.csv'],',',1,1);
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

%% PLOT THE RSTAR ESTIMATES 
set(groot,'defaultLineLineWidth',2); 
moveup = @(x) (get(gca,'Position') + [0 x 0 0]);
stp = -1.25;
clf
Dates = usdata_hlw.Date(5:end);
T0 = find( datenum(Dates) == datenum('2008-01-01'));
TT = length(Dates);
vnames0 = char(varnames);
vnames = cellstr([vnames0(2:end,1:3) repmat(', with $i= ', 8,1) num2str((-2:5)') repmat('$',8,1)]);
vnames = [{'HLW Original'}; vnames];
disp(Dates(T0));
kk = 4;

subplot(5,1,1);
hold on; 
  intplot = repmat(usdata_hlw.interest(5:end),1,9);
  intplot(T0:end,2:end) = repmat([-2:5],TT-T0+1,1);
  plot(intplot(:,kk:end))
  plot(usdata_hlw.interest(5:end),'k--')
  setplot(moveup(.04),15,0)
  setdateticks(Dates,20)
hold off;
setoutsideTicks
add2yaxislabel
% addlegend(varnames([4:end 1]))
subtitle('Actual and counterfactual interest rates $i_t$', stp)

subplot(5,1,2);
hold on; 
  xplot = rstar.filtered.Variables;
%   plot(xplot(:,1),'k','LineWidth',3)
  plot(xplot(:,kk:end))
  plot(xplot(:,1),'k--')
  setplot(moveup(.05),15,0)
  setdateticks(Dates,20)
hold off;
setoutsideTicks
add2yaxislabel
addlegend(vnames([kk:end 1]),[],13)
subtitle('Filtered natural rate $r^\ast_t$', stp)

subplot(5,1,3);
hold on;
  xplot = rstar.smoothed.Variables;
  plot(xplot(:,kk:end))
  ylim([0 6])
  plot(xplot(:,1),'k--')
  setplot(moveup(.06),15,0)
  setdateticks(Dates,20)
hold off;
setoutsideTicks
add2yaxislabel
% addlegend(vnames([kk:end 1]),[],13)
subtitle('Smoothed natural rate $r^\ast_t$', stp)

subplot(5,1,4);
hold on;
  xplot = z.filtered.Variables;
%   plot(xplot(:,1),'k','LineWidth',3)
  plot(xplot(:,kk:end))
  ylim([-2 1.5])
  plot(xplot(:,1),'k--')
  setplot(moveup(.07),15,1)
  setdateticks(Dates,20)
hold off; hline(0)
setoutsideTicks
add2yaxislabel
% addlegend(varnames([4:end 1]))
subtitle('Filtered other factor $z_t$', stp)

subplot(5,1,5);
hold on;
  xplot = z.smoothed.Variables;
%   plot(xplot(:,1),'k','LineWidth',3)
  plot(xplot(:,kk:end))
  ylim([-2 1.5])
  plot(xplot(:,1),'k--')
  setplot(moveup(.08),15,1)
  setdateticks(Dates,20)
hold off; hline(0)
setoutsideTicks
add2yaxislabel
% addlegend(varnames([4:end 1]))
subtitle('Smoothed other factor $z_t$', stp)



















