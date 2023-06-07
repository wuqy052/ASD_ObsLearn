% Run regression
clear all
fs = filesep;
data_all = readtable(['..',fs,'..',fs,'data',fs,'Study1',fs,'AllVars_discovery.csv']);
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
data_standardized = normalize(data_all(:,[1:30,38,40,42:51]));
data_standardized.Gender_conv = gender_conv;

% 1. Predicting F1 using OL
mdl_F1.EM_prop = fitlm(data_standardized,'SRS_F1 ~ EM_prop + Age + MBMF_score + Gender_conv');
mdl_F1.bias = fitlm(data_standardized,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvsblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + MBMF_score + Age  + Gender_conv');
% 2. Predicting OL using F1
mdl_OL.EM_prop = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');


