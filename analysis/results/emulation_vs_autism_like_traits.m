% Main results: association between emulation and ausitm-like traits
% Fig. 1c, 4abc, 5ab, 6ab
% Extended Data Fig. 5
% Supplementary Fig. S7, Result S4
%% load data
% need to change the path to the folder where this file is in
clear all
fs = filesep;
data_discovery = readtable(['..',fs,'..',fs,'data',fs,'Study1',fs,'AllVars_discovery.csv']);
data_replication = readtable(['..',fs,'..',fs,'data',fs,'Study2',fs,'AllVars_replication.csv']);

%% Fig. 1c Emulation propensity differed in low vs. high uncertainty conditions 
% discovery
% paired t test: T(942) = 5.096
disp(['Mean difference = ',num2str(round(mean(data_discovery.EM_prop_LU)-mean(data_discovery.EM_prop_HU),3))]);
disp(['STD difference = ',num2str(round(std(data_discovery.EM_prop_LU - data_discovery.EM_prop_HU),3))]);
[~,p_em_dis,ci_em_dis,stats_em_dis] = ttest(data_discovery.EM_prop_LU,data_discovery.EM_prop_HU)
% replication
% paird t test: T(351) = 2.649
disp(['Mean difference = ',num2str(round(mean(data_replication.EM_prop_LU)-mean(data_replication.EM_prop_HU),3))]);
disp(['STD difference = ',num2str(round(std(data_replication.EM_prop_LU - data_replication.EM_prop_HU),3))]);
[~,p_em_rep,ci_em_rep,stats_em_rep] = ttest(data_replication.EM_prop_LU,data_replication.EM_prop_HU)

%% Fig. 4a Emulation propensity ~ autism-like traits
[r.EM_prop_dis,p.EM_prop_dis]=corr(data_discovery.SRS_F1,data_discovery.EM_prop); % discovery
[r.EM_prop_rep,p.EM_prop_rep]=corr(data_replication.SRS_F1,data_replication.EM_prop);% replication

%% Fig. 4b compare autism-like traits across strategy subgroups
% discovery sample
[p.cluster_dis,t_cluster_dis,stats_dis] = anova1(data_discovery.SRS_F1,data_discovery.cluster_group);
[c,m,~,gnames] = multcompare(stats);
tbl = array2table(c,"VariableNames", ...
    ["Group","Control Group","Lower Limit","Difference","Upper Limit","P-value"]);
tbl.("Group") = gnames(tbl.("Group"));
tbl.("Control Group") = gnames(tbl.("Control Group"))
% replication sample
% confirmatory pair-wise testing
[~,p.EmuVsNonlearn,ci.EmuVsNonlearn,Tstats.EmuVsNonlearn]=ttest2(data_replication.SRS_F1(find(strcmp(data_replication.cluster_group,'Emulation'))),...
    data_replication.SRS_F1(find(strcmp(data_replication.cluster_group,'NonLearn'))))
[~,p.EmuVsImi,ci.EmuVsImi,Tstats.EmuVsImi]=ttest2(data_replication.SRS_F1(find(strcmp(data_replication.cluster_group,'Emulation'))),...
    data_replication.SRS_F1(find(strcmp(data_replication.cluster_group,'Imitation'))))

%% Fig. 4c: Emulation bias ~ autism-like traits
% discovery sample
[r.EM_bias_dis,p.EM_bias_dis]=corr(data_discovery.SRS_F1,data_discovery.IntDyn_hbi_bias);
% replication sample
[r.EM_bias_rep,p.EM_bias_rep]=corr(data_replication.SRS_F1,data_replication.IntDyn_hbi_bias);

%% Fig. 5ab, 6ab: specificity analysis
% discovery sample
% convert gender
for i=1:size(data_discovery,1)
    if strcmp(data_discovery.Gender{i},'Male')
        gender_conv(i,1) = 1;
    elseif strcmp(data_discovery.Gender{i},'Female')
        gender_conv(i,1) = 0;
    else
        gender_conv(i,1) = NaN;
    end
end
% Standardize the variables
data_standardized_dis = normalize(data_discovery(:,[1:30,37,39,41:50]));
data_standardized_dis.Gender_conv = gender_conv;

% 1. Predicting F1 using OL
mdl_F1.EM_prop_dis = fitlm(data_standardized_dis,'SRS_F1 ~ EM_prop + Age + MBMF_score + Gender_conv');
mdl_F1.bias_dis = fitlm(data_standardized_dis,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvsblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + MBMF_score + Age  + Gender_conv');
% 2. Predicting OL using F1
mdl_OL.EM_prop_dis = fitlm(data_standardized_dis,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias_dis = fitlm(data_standardized_dis,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
% print the F stats for a single regressor
anova(mdl_OL.EM_prop_dis)
% print the CI
ci = coefCI(mdl_OL.bias,0.05);
ciTable = array2table(ci,...
    'RowNames',mdl_OL.bias.Coefficients.Properties.RowNames, ...
    'VariableNames',["LowerLimit","UpperLimit"])

% Replication sample
% convert gender
for i=1:size(data_replication,1)
    if strcmp(data_replication.Gender{i},'Male')
        gender_conv_rep(i,1) = 1;
    elseif strcmp(data_replication.Gender{i},'Female')
        gender_conv_rep(i,1) = 0;
    else
        gender_conv_rep(i,1) = NaN;
    end
end
data_replication.Gender_conv = gender_conv_rep;
% Standardize the variables
data_standardized_rep = normalize(data_replication(:,[1:39,46:48,53:68,70]));    
% 1. Predicting F1 using variuos OL
mdl_F1.EM_prop_rep = fitlm(data_standardized_rep,'SRS_F1 ~ EM_prop + Age + IQ + WM + Gender_conv');
mdl_F1.bias_rep = fitlm(data_standardized_rep,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + IQ + WM+ Age  + Gender_conv');
% 2. Predicting various OL using F1
mdl_OL.EM_prop_rep = fitlm(data_standardized_rep,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias_rep = fitlm(data_standardized_rep,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');

%% Extended Data Fig 5: arbitration ~ autism-like traits
% discovery sample
[r.arbprop_dis,p.arbprop_dis]=corr(data_discovery.SRS_F1,data_discovery.EM_prop_diff);% F1 ~ arbitration propensity
[r.eta_dis,p.eta_dis]=corr(data_discovery.SRS_F1,data_discovery.IntDyn_hbi_wUnc);% F1 ~ weight of uncertainty (eta)
% replication sample
[r.arbprop_rep,p.arbprop_rep]=corr(data_replication.SRS_F1,data_replication.EM_prop_diff);% F1 ~ arbitration propensity
[r.eta_rep,p.eta_rep]=corr(data_replication.SRS_F1,data_replication.IntDyn_hbi_wUnc);% F1 ~ weight of uncertainty (eta)

%% Supplementary Fig. S7: Accuracy by uncertainties
% discovery sample
[~,p_acc_dis,ci_acc_dis,stats_acc_dis] = ttest(data_discovery.ACC_LU,data_discovery.ACC_HU)
% replication sample
[~,p_acc_rep,ci_acc_rep,stats_acc_rep] = ttest(data_replication.ACC_LU,data_replication.ACC_HU)


%% Supplementary Result S4
% Correlation between raw SRS and emulation propensity after regressing out
% anxiety and social anxiety
% discovery sample
[~,~,res_dis.anx] = regress(data_discovery.SRS,[data_discovery.LSAS,data_discovery.STAI_T]);
[r_prop_dis.anx,p_prop_dis.anx] = corr(res_dis.anx,data_discovery.EM_prop,'rows','complete');
% replication sample
[~,~,res_rep.anx] = regress(data_replication.SRS,[data_replication.LSAS,data_replication.STAI_T]);
[r_prop_rep.anx,p_prop_rep.anx] = corr(res_rep.anx,data_replication.EM_prop,'rows','complete');
% also we have AQ for the replication sample
[~,~,res_AQ.anx] = regress(data_replication.AQ,[data_replication.LSAS,data_replication.STAI_T]);
[r_AQ_prop.anx,p_AQ_prop.anx] = corr(res_AQ.anx,data_replication.EM_prop,'rows','complete');


% Correlation between autism-like traits and the model fitting performance
% of emulation and imitation
% discovery sample
[r.R2Emu_dis,p.R2Emu_dis]=corr(data_discovery.SRS_F1,data_discovery.nonhbi_R2_Emu,'Type','Spearman');% F1 ~ R2 of emulation
[r.R2Imi_dis,p.R2Imi_dis]=corr(data_discovery.SRS_F1,data_discovery.nonhbi_R2_Imi,'Type','Spearman');% F1 ~ R2 of imitation
% replication sample
[r.R2Emu_rep,p.R2Emu_rep]=corr(data_replication.SRS_F1,data_replication.nonhbi_R2_Emu,'Type','Spearman');% F1 ~ R2 of emulation
[r.R2Imi_rep,p.R2Imi_rep]=corr(data_replication.SRS_F1,data_replication.nonhbi_R2_Imi,'Type','Spearman');% F1 ~ R2 of imitation

