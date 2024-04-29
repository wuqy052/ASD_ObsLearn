% Run regression
clear all
fs = filesep;
data_all = readtable(['..',fs,'..',fs,'data',fs,'Study1',fs,'AllVars_discovery.csv']);
% calculate correlation
[r.EM_prop,p.EM_prop]=corr(data_all.SRS_F1,data_all.EM_prop);% F1 ~ EM_prop
[r.EM_bias,p.EM_bias]=corr(data_all.SRS_F1,data_all.IntDyn_hbi_bias);% F1 ~ bias
[r.R2Emu,p.R2Emu]=corr(data_all.SRS_F1,data_all.nonhbi_R2_Emu,'Type','Spearman');% F1 ~ R2 of emulation
[r.R2Imi,p.R2Imi]=corr(data_all.SRS_F1,data_all.nonhbi_R2_Imi,'Type','Spearman');% F1 ~ R2 of imitation
[r.arbprop,p.arbprop]=corr(data_all.SRS_F1,data_all.EM_prop_diff);% F1 ~ arbitration propensity
[r.eta,p.eta]=corr(data_all.SRS_F1,data_all.IntDyn_hbi_wUnc);% F1 ~ weight of uncertainty (eta)

% ANOVA among 4 cluster groups
[p.cluster,t,stats] = anova1(data_all.SRS_F1,data_all.cluster_group);
[c,m,h,gnames] = multcompare(stats);
tbl = array2table(c,"VariableNames", ...
    ["Group","Control Group","Lower Limit","Difference","Upper Limit","P-value"]);
tbl.("Group") = gnames(tbl.("Group"));
tbl.("Control Group") = gnames(tbl.("Control Group"))

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
% Standardize the variables
data_standardized = normalize(data_all(:,[1:30,37,39,41:50]));
data_standardized.Gender_conv = gender_conv;

% 1. Predicting F1 using OL
mdl_F1.EM_prop = fitlm(data_standardized,'SRS_F1 ~ EM_prop + Age + MBMF_score + Gender_conv');
mdl_F1.bias = fitlm(data_standardized,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvsblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + MBMF_score + Age  + Gender_conv');
% 2. Predicting OL using F1
mdl_OL.EM_prop = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');

% print the F stats for a single regressor
anova(mdl_OL.bias)
% print the CI
ci = coefCI(mdl_OL.bias,0.05);
ciTable = array2table(ci,...
    'RowNames',mdl_OL.bias.Coefficients.Properties.RowNames, ...
    'VariableNames',["LowerLimit","UpperLimit"])

