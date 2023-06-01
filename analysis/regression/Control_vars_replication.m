% organize the data for the control variables
% Age, Gender, IQ, WM 
%% load subject list
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/Sublist_final_replication.mat');

%% Cognitive tasks
cog_data = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/cognitive_tasks_summary_2022_12_19.csv');
[~,~,cogid] = intersect(sublist_rep,cog_data.subID);
cog_final = table2array(cog_data(cogid,[3,8])); % IQ = rpm_adjusted, working memory = ds_max_recall

%% Demographics
demo_data = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/demographics_data_final.csv');
[~,~,demoid] = intersect(sublist_rep,demo_data.ParticipantId);
demo_combine = [demo_data.sex_demQ,num2cell(demo_data.age_demQ), demo_data.HighestEducationLevelCompleted, ...
    demo_data.AutismSpectrumDisorder, demo_data.Handedness];
demo_final = demo_combine(demoid,:);
% calculate number of males and females, and mean and std of age
num_male = sum(strcmp(demo_final(:,1),'Male'));
num_female = sum(strcmp(demo_final(:,1),'Female'));
age_mean = nanmean(cell2mat(demo_final(:,2))); % SRS total, hbi:
age_std = nanstd(cell2mat(demo_final(:,2)));

% all enrollment
num_male = sum(strcmp(demo_combine(:,1),'Male'));
num_female = sum(strcmp(demo_combine(:,1),'Female'));
num_nonspec = sum(strcmp(demo_combine(:,1),'Non-specific'));
age_mean = nanmean(cell2mat(demo_combine(:,2))); % SRS total, hbi:
age_std = nanstd(cell2mat(demo_combine(:,2)));


%% Questionnaires
ques_data = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data_replication_prolific/questionnaires/summary_scores_2022_12_19.csv');
[~,~,quesid] = intersect(sublist_rep,ques_data.subID);
ques_final = ques_data(quesid,:);

% all the above data is then saved as 'regression/AllVars_replication.csv'

%% Run regression
clear all
data_all = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/regression/AllVars_replication.csv');
% SRS_F1 ~ ACC/EM_prop/IntDyn_hbi_bias/IntFix_hbi_weight/nonhbi_R2_Emu/glme_tokenInf
% all-time control variables: IQ, WM, Age, Gender
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
data_standardized = normalize(data_all(:,[2:46,48:50,55:71]));    
% 1. Predicting F1 using variuos OL
mdl_F1.ACC = fitlm(data_standardized,'SRS_F1 ~ ACC + IQ + WM + Age + Gender_conv');
mdl_F1.EM_prop = fitlm(data_standardized,'SRS_F1 ~ EM_prop + Age + IQ + WM + Gender_conv');
mdl_F1.bias = fitlm(data_standardized,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_green + IntDyn_hbi_redvblue + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol + IQ + WM+ Age  + Gender_conv');
mdl_F1.weight = fitlm(data_standardized,'SRS_F1 ~ IntFix_hbi_weight + IntFix_hbi_rawbeta + IntFix_hbi_hand + IntFix_hbi_green + IntFix_hbi_redvsblue + IntFix_hbi_stickyact + IntFix_hbi_stickycol + IQ + WM + Age + Gender_conv');
mdl_F1.R2_emu = fitlm(data_standardized,'SRS_F1 ~ nonhbi_R2_Emu + nonhbi_R2_Baseline + nonhbi_R2_Imi + nonhbi_R2_FixSingle + nonhbi_R2_DynFix + IQ + WM + Age + Gender_conv');
mdl_F1.glme_emu = fitlm(data_standardized,'SRS_F1 ~ glme_tokenInf + glme_partnerAct + IQ + WM + Age + Gender_conv');
% 2. Predicting various OL using F1
mdl_OL.ACC_F28 = fitlm(data_standardized,'ACC ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + IQ + WM + Age + Gender_conv');
mdl_OL.ACC_Ques = fitlm(data_standardized,'ACC ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Schizo + SNI_tot + SocCuriosity + Compliance + IQ + WM + Age + Gender_conv');
mdl_OL.EM_prop_F28 = fitlm(data_standardized,'EM_prop ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + IQ + WM + Age + Gender_conv');
mdl_OL.EM_prop_Ques = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Schizo + SNI_tot + SocCuriosity + Compliance + IQ + WM + Age + Gender_conv');
mdl_OL.bias_F28 = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + IQ + WM + Age + Gender_conv');
mdl_OL.bias_Ques = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Schizo + SNI_tot + SocCuriosity + Compliance + IQ + WM + Age + Gender_conv');
mdl_OL.weight_F28 = fitlm(data_standardized,'IntFix_hbi_weight ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + IQ + WM + Age + Gender_conv');
mdl_OL.weight_Ques = fitlm(data_standardized,'IntFix_hbi_weight ~ SRS_F1 + STAI_T +BDI + Barratt_Impulsiveness + LSAS + OCI_R + Schizo + SNI_tot + SocCuriosity + Compliance + IQ + WM + Age + Gender_conv');
mdl_OL.R2_emu_F28 = fitlm(data_standardized,'nonhbi_R2_Emu ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + IQ + WM + Age + Gender_conv');
mdl_OL.R2_emu_Ques = fitlm(data_standardized,'nonhbi_R2_Emu ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Schizo + SNI_tot + SocCuriosity + Compliance + IQ + WM + Age + Gender_conv');
mdl_OL.glme_emu_F28 = fitlm(data_standardized,'glme_tokenInf ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + IQ + WM + Age + Gender_conv');
mdl_OL.glme_emu_Ques = fitlm(data_standardized,'glme_tokenInf ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Schizo + SNI_tot + SocCuriosity + Compliance + IQ + WM + Age + Gender_conv');
% original and replication common questionnaires
mdl_OL.ACC_Qcommon = fitlm(data_standardized,'ACC ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.EM_prop_Qcommon = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias_Qcommon = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.R2_emu_Qcommon = fitlm(data_standardized,'nonhbi_R2_Emu ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.glme_emu_Qcommon = fitlm(data_standardized,'glme_tokenInf ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');

% correlation among control regressors
data_forcorr = data_all(:,[2:10,14,18:35,42:46,48:50,56:66,68:70]);
[corr_allvars,p_allvars] = corr(table2array(data_forcorr),'rows','complete');
varnames = {'F1','F2','F3','F4','F5','F6','F7','F8',...
    'ACC','EMprop','RT','glmeImi','glmeEmu',...
    'Dynbeta','Dyneta','Dynbias','Dynhand','Dyngreen','DynRB','DynSA','DynSC',...
    'Fixbeta','Fixweight','Fixhand','Fixgreen','FixRB','FixSA','FixSC',...
    'R2Base','R2Imi','R2Emu','R2FixSing','R2DynFix',...
    'IQ','WM','Age','STAI_T','STAI_S','BDI','Barratt','Attrib',...
    'LSAS','OCI_R','Schizo','SNI_tot','SNI_size','SocCur','Compliance','IUS','PSS'};
heatmap(corr_allvars,'XData',varnames,'YData',varnames,'ColorLimits',[-1 1],'Colormap',redbluecmap);

% check F and P of model
[p,f]=coefTest(mdl_F1.bias)
ci = coefCI(mdl_F1.EM_prop)

%% plot figures
% F1 ~ emulation prop
figure;
h1= plotEffects(mdl_F1.EM_prop);
h1(1).Marker = 's';
h1(1).MarkerSize = 10;
h1(1).MarkerEdgeColor = [214/255,121/255,81/255]; % change the marker color
h1(1).MarkerFaceColor = [214/255,121/255,81/255]; % change the marker color
for k=2:6
    h1(k).Color = [81/255,168/255,214/255]; % change the line color
    h1(k).LineWidth = 1.5;
end
varnames = {'Emulation Propensity','Reasoning','Working memory','Age','Sex'};
yticklabels(varnames);
set(gca,'FontSize',15)
xlim([-1.5,0.7]);
% extract parameters
data_table = struct();
data_table.F1_EMprop = {'Var','Main','Lower','Upper'};
for k=2:6
    data_table.F1_EMprop{k,1}=varnames{k-1};
    data_table.F1_EMprop{k,2}=h1(1).XData(k-1);
    data_table.F1_EMprop{k,3}=h1(k).XData(1);
    data_table.F1_EMprop{k,4}=h1(k).XData(2);
end
% F1 ~ bias
figure;
h3= plotEffects(mdl_F1.bias);
h3(1).Marker = 's';
h3(1).MarkerSize = 10;
h3(1).MarkerEdgeColor = [214/255,121/255,81/255]; % change the marker color
h3(1).MarkerFaceColor = [214/255,121/255,81/255]; % change the marker color
for k=2:13
    h3(k).Color = [81/255,168/255,214/255]; % change the line color
    h3(k).LineWidth = 1.5;
end
xlim([-2,1.5]);
varnames = {'Beta','Uncertainty weight','Emulation bias','Action bias','Color bias 1','Color bias 2','Sticky Action','Sticky Color','Reasoning','Working memory','Age','Sex'};
yticklabels(varnames);
set(gca,'FontSize',15)
% extract parameters
data_table.F1_EMbias = {'Var','Main','Lower','Upper'};
for k=2:13
    data_table.F1_EMbias{k,1}=varnames{k-1};
    data_table.F1_EMbias{k,2}=h3(1).XData(k-1);
    data_table.F1_EMbias{k,3}=h3(k).XData(1);
    data_table.F1_EMbias{k,4}=h3(k).XData(2);
end

% Emulation prop ~ F1
figure;
h2= plotEffects(mdl_OL.EM_prop_Qcommon);
h2(1).Marker = 's';
h2(1).MarkerSize = 10;
h2(1).MarkerEdgeColor = [81/255,168/255,214/255]; % change the marker color
h2(1).MarkerFaceColor = [81/255,168/255,214/255]; % change the marker color
for k=2:9
    h2(k).Color = [214/255,121/255,81/255]; % change the line color
    h2(k).LineWidth = 1.5;
end
xlim([-2,2.3]);
varnames = {'Factor 1','Age','State anxiety','Depression','Impulsiveness','OCD','Social anxiety','Sex'};
yticklabels(varnames);
set(gca,'FontSize',15)
% extract parameters
data_table.EMprop_F1 = {'Var','Main','Lower','Upper'};
for k=2:9
    data_table.EMprop_F1{k,1}=varnames{k-1};
    data_table.EMprop_F1{k,2}=h2(1).XData(k-1);
    data_table.EMprop_F1{k,3}=h2(k).XData(1);
    data_table.EMprop_F1{k,4}=h2(k).XData(2);
end

% Emulation bias ~ F1
figure;
h4= plotEffects(mdl_OL.bias_Qcommon);
h4(1).Marker = 's';
h4(1).MarkerSize = 10;
h4(1).MarkerEdgeColor = [81/255,168/255,214/255]; % change the marker color
h4(1).MarkerFaceColor = [81/255,168/255,214/255]; % change the marker color
for k=2:9
    h4(k).Color = [214/255,121/255,81/255]; % change the line color
    h4(k).LineWidth = 1.5;
end
xlim([-1.7,1.7]);
varnames = {'Factor 1','Age','Trait anxiety','Depression','Impulsiveness','OCD','Social anxiety','Sex'};
yticklabels(varnames);
set(gca,'FontSize',15)
% extract parameters
data_table.bias_F1 = {'Var','Main','Lower','Upper'};
for k=2:9
    data_table.bias_F1{k,1}=varnames{k-1};
    data_table.bias_F1{k,2}=h4(1).XData(k-1);
    data_table.bias_F1{k,3}=h4(k).XData(1);
    data_table.bias_F1{k,4}=h4(k).XData(2);
end

%% plot f1 difference between male & female
[gender,gender_count,f1_mean,f1_std] = grpstats(data_all.SRS_F1,data_all.Gender,["gname","numel","mean","sem"]); % SRS total, hbi
% 0 = female, 1 = male
figure;
hold on
b1 = bar([1:2],f1_mean);
errorbar([1:2],f1_mean, f1_std);
xticks([1:2]);
xticklabels({'Female','Male'});
ylabel('F1');

%% check the IQ, Age, Gender across 4 clustering groups
[ol_grp,grp_count,iq_mean,iq_std] = grpstats(data_all.IQ,data_all.cluster_group,["gname","numel","mean","sem"]); % SRS total, hbi
[ol_grp,grp_count,age_mean,age_std] = grpstats(data_all.Age,data_all.cluster_group,["gname","numel","mean","sem"]); % SRS total, hbi
[ol_grp,grp_count,sex_mean,sex_std] = grpstats(gender_conv,data_all.cluster_group,["gname","numel","mean","sem"]); % SRS total, hbi

% Plot MBMF score
figure;
hold on
b1 = bar([1:4],iq_mean);
errorbar([1:4],iq_mean, iq_std);
xticks([1:4]);
xticklabels(ol_grp);
ylabel('IQ');
% Plot Age
figure;
hold on
b1 = bar([1:4],age_mean);
errorbar([1:4],age_mean, age_std);
xticks([1:4]);
xticklabels(ol_grp);
ylabel('Age');
% Plot Sex
figure;
hold on
b1 = bar([1:4],sex_mean);
errorbar([1:4],sex_mean, sex_std);
xticks([1:4]);
xticklabels(ol_grp);
yline(0.5);
ylabel('Sex (1=Male)');



