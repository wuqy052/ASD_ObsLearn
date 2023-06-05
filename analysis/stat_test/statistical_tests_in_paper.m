% statistical tests in the paper
%% load data
clear all
close all
fs = filesep;
data_all_rep = readtable(['..',fs','..',fs,'data',fs,'Study2',fs,'AllVars_replication.csv']);

%% Fig 1C & S1 Compare emulation propensity & accuracy under high/low uncertainty conditions
% difference
meandiff_em_rep = mean(data_all_rep.EM_prop_LU-data_all_rep.EM_prop_HU);
meandiff_acc_rep = mean(data_all_rep.ACC_diff);
% ttest
[~,p_em_rep,ci_em_rep,stats_em_rep] = ttest(data_all_rep.EM_prop_LU,data_all_rep.EM_prop_HU);
[~,p_acc_rep,ci_acc_rep,stats_acc_rep] = ttest(data_all_rep.ACC_LU,data_all_rep.ACC_HU);
% effect size
% Cohen's d for paired ttest = mean diff / SD of diff
cohend_em = mean(data_all_rep.EM_prop_diff) / std(data_all_rep.EM_prop_diff);
cohend_acc = mean(data_all_rep.ACC_diff) / std(data_all_rep.ACC_diff);

