% Run regression
clear all
fs = filesep;
data_all = readtable(['..',fs,'..',fs,'data',fs,'Study2',fs,'AllVars_replication.csv']);
% calculate correlation
[r.EM_prop,p.EM_prop]=corr(data_all.SRS_F1,data_all.EM_prop);% F1 ~ EM_prop
[r.EM_bias,p.EM_bias]=corr(data_all.SRS_F1,data_all.IntDyn_hbi_bias);% F1 ~ bias
[r.R2Emu,p.R2Emu]=corr(data_all.SRS_F1,data_all.nonhbi_R2_Emu,'Type','Spearman');% F1 ~ R2 of emulation
[r.R2Imi,p.R2Imi]=corr(data_all.SRS_F1,data_all.nonhbi_R2_Imi,'Type','Spearman');% F1 ~ R2 of imitation
[r.arbprop,p.arbprop]=corr(data_all.SRS_F1,data_all.EM_prop_diff);% F1 ~ arbitration propensity
[r.eta,p.eta]=corr(data_all.SRS_F1,data_all.IntDyn_hbi_wUnc);% F1 ~ weight of uncertainty (eta)

% confirmatory pair-wise testing
[~,p.EmuVsNonlearn,ci.EmuVsNonlearn,Tstats.EmuVsNonlearn]=ttest2(data_all.SRS_F1(find(strcmp(data_all.cluster_group,'Emulation'))),...
    data_all.SRS_F1(find(strcmp(data_all.cluster_group,'NonLearn'))))
[~,p.EmuVsImi,ci.EmuVsImi,Tstats.EmuVsImi]=ttest2(data_all.SRS_F1(find(strcmp(data_all.cluster_group,'Emulation'))),...
    data_all.SRS_F1(find(strcmp(data_all.cluster_group,'Imitation'))))

% convert gender
for i=1:size(data_all,1)
    if strcmp(data_all.Gender{i},'Male')
        gender_conv(i,1) = 1;
    elseif strcmp(data_all.Gender{i},'Female')
        gender_conv(i,1) = 0;
    else
        gender_conv(i,1) = NaN;
    end
end
data_all.Gender_conv = gender_conv;
% Standardize the variables
data_standardized = normalize(data_all(:,[1:39,46:48,53:69]));    
% 1. Predicting F1 using variuos OL
mdl_F1.EM_prop = fitlm(data_standardized,'SRS_F1 ~ EM_prop + Age + IQ + WM + Gender_conv');
mdl_F1.bias = fitlm(data_standardized,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + IQ + WM+ Age  + Gender_conv');
% 2. Predicting various OL using F1
mdl_OL.EM_prop = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');

% print the F stats for a single regressor
anova(mdl_OL.bias)
% print the CI
ci = coefCI(mdl_OL.bias,0.05);
ciTable = array2table(ci,...
    'RowNames',mdl_OL.bias.Coefficients.Properties.RowNames, ...
    'VariableNames',["LowerLimit","UpperLimit"])

