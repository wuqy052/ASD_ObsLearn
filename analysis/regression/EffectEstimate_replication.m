% Run regression
clear all
fs = filesep;
data_all = readtable(['..',fs,'..',fs,'data',fs,'Study2',fs,'AllVars_replication.csv']);
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
data_standardized = normalize(data_all(:,[1:39,47:49,54:70]));    
% 1. Predicting F1 using variuos OL
mdl_F1.EM_prop = fitlm(data_standardized,'SRS_F1 ~ EM_prop + Age + IQ + WM + Gender_conv');
mdl_F1.bias = fitlm(data_standardized,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + IQ + WM+ Age  + Gender_conv');
% 2. Predicting various OL using F1
mdl_OL.EM_prop = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
