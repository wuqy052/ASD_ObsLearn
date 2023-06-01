% organize the data for the control variables
% Age, Gender, IQ, WM 
%% load subject list
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.mat');

%% Cognitive tasks
cog_data = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/MBMF_performance_April6.csv');
[~,~,cogid] = intersect(sublist,cog_data.workerId);
cog_final = table2array(cog_data(cogid,[3])); % isPostWin: MF; isPostWin_isPostRare: MB; score:performance

%% Demographics and questionnaires
demo_data = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/age_gender_noexcl_mturk_prolific_all.csv');
[C,subid,demoid] = intersect(sublist,demo_data.subID);
demo_combine = [demo_data.gender,num2cell(demo_data.age), demo_data.education];
demo_final = demo_combine(demoid,:);
% copy paste 1:486 as 1:486; then 487-end as 488-end

% demographic data of all enrolled subjects
ques_exc_r21 = readtable('/Users/wuqy0214/Documents/psy/OLab/SRS/R21_excl_crit.csv');
[~,~,demoid2] = intersect(ques_exc_r21.Var1,demo_data.subID);
demo_enrolled = demo_combine(demoid2,:);
num_male = sum(strcmp(demo_enrolled(:,1),'Male'));
num_female = sum(strcmp(demo_enrolled(:,1),'Female'));
num_nonspec = sum(strcmp(demo_enrolled(:,1),'Non-specific'));
age_mean = nanmean(cell2mat(demo_enrolled(:,2))); % SRS total, hbi:
age_std = nanstd(cell2mat(demo_enrolled(:,2)));


%% Questionnaires
ques_data = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/SRS vs OL/R21_questionnaire_scores_noexcl.csv');
[~,~,quesid] = intersect(sublist,ques_data.subID);
LSAS_tot = ques_data.LSAS_performanceanxiety + ques_data.LSAS_performanceavoidance + ques_data.LSAS_socialanxiety + ques_data.LSAS_socialavoidance;
ques_combine = [ques_data.STAI_T, ques_data.BDI, ques_data.Barratt, ques_data.EDEQ, ques_data.OCI_R,ques_data.PDSS, ques_data.PSWQ,  ques_data.AES,LSAS_tot];
ques_final = ques_combine(quesid,:);

% all the above data is then saved as 'regression/AllVars_replication.csv'

%% Run regression
clear all
data_all = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/regression/AllVars_original.xlsx');
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
% convert level of education
for i=1:size(data_all,1)
    if strcmp(data_all.Education{i},'Middle School')
        edu_conv(i,1) = 1;
    elseif strcmp(data_all.Education{i},'Some High School')
        edu_conv(i,1) = 2;
    elseif strcmp(data_all.Education{i},'High School (Graduate or Equivalent)')
        edu_conv(i,1) = 3;
     elseif strcmp(data_all.Education{i},'Some College')
        edu_conv(i,1) = 4;
    elseif strcmp(data_all.Education{i},'Associates Degree')
        edu_conv(i,1) = 5;
    elseif strcmp(data_all.Education{i},'Bachelors Degree')
        edu_conv(i,1) = 6;
    elseif strcmp(data_all.Education{i},'Masters Degree')
        edu_conv(i,1) = 7;
    elseif strcmp(data_all.Education{i},'Graduate Degree')
        edu_conv(i,1) = 8;
    else
        edu_conv(i,1) = NaN;
    end
end
data_all.Edu_conv = edu_conv;
% Standardize the variables
data_standardized = normalize(data_all(:,[2:39,41,43,45:54]));
data_standardized.Gender_conv = gender_conv;
data_standardized.Edu_conv = edu_conv;

% 1. Predicting F1 using variuos OL
% mdl_F1.ACC = fitlm(data_standardized,'SRS_F1 ~ ACC + MBMF_score + Age + Gender_conv');
mdl_F1.EM_prop = fitlm(data_standardized,'SRS_F1 ~ EM_prop + MBMF_score + Age + Gender_conv');
mdl_F1.bias = fitlm(data_standardized,'SRS_F1 ~ IntDyn_hbi_bias + IntDyn_hbi_rawBeta + IntDyn_hbi_wUnc + IntDyn_hbi_hand + IntDyn_hbi_redvsblue + IntDyn_hbi_green  + IntDyn_hbi_stickyAct + IntDyn_hbi_stickyCol  + MBMF_score + Age + Gender_conv');
%mdl_F1.weight = fitlm(data_standardized,'SRS_F1 ~ IntFix_hbi_weight + IntFix_hbi_rawbeta + IntFix_hbi_hand + IntFix_hbi_green + IntFix_hbi_redvsblue + IntFix_hbi_stickyact + IntFix_hbi_stickycol + MBMF_MF + MBMF_MB + MBMF_score + Age + Gender_conv');
%mdl_F1.R2_emu = fitlm(data_standardized,'SRS_F1 ~ nonhbi_R2_Emu + nonhbi_R2_Baseline + nonhbi_R2_Imi + nonhbi_R2_FixSingle + nonhbi_R2_DynFix + MBMF_score + Age + Gender_conv');
%mdl_F1.glme_emu = fitlm(data_standardized,'SRS_F1 ~ glme_tokenInf + glme_partnerAct + MBMF_score + Age + Gender_conv');
% 2. Predicting various OL using F1
% mdl_OL.ACC_F28 = fitlm(data_standardized,'ACC ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + MBMF_score + Age + Gender_conv');
% mdl_OL.ACC_Ques = fitlm(data_standardized,'ACC ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + EDEQ + OCI_R + PDSS + PSWQ + MBMF_score  + Age + Gender_conv');
% mdl_OL.EM_prop_F28 = fitlm(data_standardized,'EM_prop ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + MBMF_score + Age + Gender_conv');
% mdl_OL.EM_prop_Ques = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + EDEQ + OCI_R + PDSS + PSWQ + MBMF_score + Age + Gender_conv');
% mdl_OL.bias_F28 = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + MBMF_score + Age + Gender_conv');
% mdl_OL.bias_Ques = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + EDEQ + OCI_R + PDSS + PSWQ + MBMF_score + Age + Gender_conv');
% mdl_OL.weight_F28 = fitlm(data_standardized,'IntFix_hbi_weight ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + MBMF_score + Age + Gender_conv');
% mdl_OL.weight_Ques = fitlm(data_standardized,'IntFix_hbi_weight ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + EDEQ + OCI_R + PDSS + PSWQ + MBMF_score + Age + Gender_conv');
% mdl_OL.R2_emu_F28 = fitlm(data_standardized,'nonhbi_R2_Emu ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + MBMF_score + Age + Gender_conv');
% mdl_OL.R2_emu_Ques = fitlm(data_standardized,'nonhbi_R2_Emu ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + EDEQ + OCI_R + PDSS + PSWQ + MBMF_score + Age + Gender_conv');
% mdl_OL.glme_emu_F28 = fitlm(data_standardized,'glme_tokenInf ~ SRS_F1 + SRS_F2 + SRS_F3 + SRS_F4 + SRS_F5 + SRS_F6 + SRS_F7 + SRS_F8 + MBMF_score + Age + Gender_conv');
% mdl_OL.glme_emu_Ques = fitlm(data_standardized,'glme_tokenInf ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + EDEQ + OCI_R + PDSS + PSWQ + MBMF_score + Age + Gender_conv');
% original and replication common questionnaires
mdl_OL.ACC_Qcommon = fitlm(data_standardized,'ACC ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.EM_prop_Qcommon = fitlm(data_standardized,'EM_prop ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.bias_Qcommon = fitlm(data_standardized,'IntDyn_hbi_bias ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.R2_emu_Qcommon = fitlm(data_standardized,'nonhbi_R2_Emu ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');
mdl_OL.glme_emu_Qcommon = fitlm(data_standardized,'glme_tokenInf ~ SRS_F1 + STAI_T + BDI + Barratt_Impulsiveness + LSAS + OCI_R + Age + Gender_conv');

% correlation among control regressors
data_forcorr = data_all(:,[2:10,14,18:35,42:46,48:51,54:62]);
[corr_allvars,p_allvars] = corr(table2array(data_forcorr),'rows','complete');
varnames = {'F1','F2','F3','F4','F5','F6','F7','F8',...
    'ACC','EMprop','RT','glmeImi','glmeEmu',...
    'Dynbeta','Dyneta','Dynbias','Dynhand','Dyngreen','DynRB','DynSA','DynSC',...
    'Fixbeta','Fixweight','Fixhand','Fixgreen','FixRB','FixSA','FixSC',...
    'R2Base','R2Imi','R2Emu','R2FixSing','R2DynFix',...
    'MBMF_MF','MBMF_MB','MBMF_score','Age','STAI_T','BDI','Barratt','EDEQ',...
    'OCI_R','PDSS','PSWQ','AES','Education'};
heatmap(corr_allvars,'XData',varnames,'YData',varnames,'ColorLimits',[-1 1],'Colormap',redbluecmap);

% check new simplified factors
data_forcorr = data_all(:,[63:71,14,10,18:35,42:46,48:51,54:62]);
[corr_allvars,p_allvars] = corr(table2array(data_forcorr),'rows','complete');
varnames = {'promax F1','promax F2','promax F3','oblimin F1','oblimin F2','oblimin F3',...
    'oblimin F4','oblimin F5','oblimin F6',...
    'ACC','EMprop','RT','glmeImi','glmeEmu',...
    'Dynbeta','Dyneta','Dynbias','Dynhand','Dyngreen','DynRB','DynSA','DynSC',...
    'Fixbeta','Fixweight','Fixhand','Fixgreen','FixRB','FixSA','FixSC',...
    'R2Base','R2Imi','R2Emu','R2FixSing','R2DynFix',...
    'MBMF_MF','MBMF_MB','MBMF_score','Age','STAI_T','BDI','Barratt','EDEQ',...
    'OCI_R','PDSS','PSWQ','AES','Education'};
heatmap(corr_allvars,'XData',varnames,'YData',varnames,'ColorLimits',[-1 1],'Colormap',redbluecmap);


% check F and P of model
[p,f]=coefTest(mdl_F1.EM_prop)
ci = coefCI(mdl_OL.bias_Qcommon)
aa = fitlm(data_standardized,'SRS_F1 ~ EM_prop + MBMF_score + Age + Gender_conv');

[p f r] = coefTest(aa,[0 1 0 0 0])

tbl = anova(aa)
%% plot figures
% F1 ~ emulation
figure;
h1= plotEffects(mdl_F1.EM_prop);
h1(1).Marker = 's';
h1(1).MarkerSize = 10;
h1(1).MarkerEdgeColor = [214/255,121/255,81/255]; % change the marker color
h1(1).MarkerFaceColor = [214/255,121/255,81/255]; % change the marker color
for k=2:5
    h1(k).Color = [81/255,168/255,214/255]; % change the line color
    h1(k).LineWidth = 1.5;
end
varnames = {'Emulation Propensity','2-Step task','Age','Gender'};
yticklabels(varnames);
set(gca,'FontSize',15)
% extract parameters
data_table = struct();
data_table.F1_EMprop = {'Var','Main','Lower','Upper'};
for k=2:5
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
for k=2:12
    h3(k).Color = [81/255,168/255,214/255]; % change the line color
    h3(k).LineWidth = 1.5;
end
xlim([-2,1.5]);
varnames = {'Beta','Uncertainty weight','Emulation bias','Action bias','Color bias 1','Color bias 2','Sticky Action','Sticky Color','2-Step score','Age','Sex'};
yticklabels(varnames);
set(gca,'FontSize',15)
% extract parameters
data_table = struct();
data_table.F1_EMbias = {'Var','Main','Lower','Upper'};
for k=2:12
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
varnames = {'Factor 1','Age','STAI-Trait','BDI','Impulsiveness','OCI-R','LSAS','Gender'};
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
varnames = {'Factor 1','Age','STAI-Trait','BDI','Impulsiveness','OCI-R','LSAS','Gender'};
yticklabels(varnames);
set(gca,'FontSize',15)
xlim([-1.5,1.5]);
% extract parameters
data_table.bias_F1 = {'Var','Main','Lower','Upper'};
for k=2:9
    data_table.bias_F1{k,1}=varnames{k-1};
    data_table.bias_F1{k,2}=h4(1).XData(k-1);
    data_table.bias_F1{k,3}=h4(k).XData(1);
    data_table.bias_F1{k,4}=h4(k).XData(2);
end

%% plot f1 difference between male & female
[gender,gender_count,f1_mean,f1_std] = grpstats(data_all.SRS_F1,gender_conv,["gname","numel","mean","sem"]); % SRS total, hbi
% 0 = female, 1 = male
figure;
hold on
b1 = bar([1:2],f1_mean);
errorbar([1:2],f1_mean, f1_std);
xticks([1:2]);
xticklabels({'Female','Male'});
ylabel('F1');

%% How sex affect the pattern of emulation_bias ~ F1
[r_male,p_male] = corr(data_all.SRS_F1(gender_conv == 1), data_all.IntDyn_hbi_bias(gender_conv == 1));
[r_female,p_female] = corr(data_all.SRS_F1(gender_conv ==0), data_all.IntDyn_hbi_bias(gender_conv == 0));

figure;
% male
subplot(1,2,1)
hold on
scatter(data_all.SRS_F1(gender_conv == 1), data_all.IntDyn_hbi_bias(gender_conv == 1))
xlabel('F1');
ylabel('Emu bias')
title('Male');
lsline;
% female
subplot(1,2,2)
hold on
scatter(data_all.SRS_F1(gender_conv == 0), data_all.IntDyn_hbi_bias(gender_conv == 0))
xlabel('F1');
ylabel('Emu bias')
title('Female');
lsline;

disp(['r in male =',num2str(r_male),'p = ',num2str(p_male)]);
disp(['r in female =',num2str(r_female),'p = ',num2str(p_female)]);

%% How Age affect the pattern of emulation_bias ~ F1
[r_young,p_young] = corr(data_all.SRS_F1(data_all.Age <= 30), data_all.IntDyn_hbi_bias(data_all.Age <= 30));
[r_middle,p_middle] = corr(data_all.SRS_F1(find((data_all.Age >30) .* (data_all.Age <= 40))), data_all.IntDyn_hbi_bias(find((data_all.Age >30) .* (data_all.Age <= 40))));
[r_old,p_old] = corr(data_all.SRS_F1(data_all.Age >40), data_all.IntDyn_hbi_bias(data_all.Age >40));

figure;
% young
subplot(1,3,1)
hold on
scatter(data_all.SRS_F1(data_all.Age <= 30), data_all.IntDyn_hbi_bias(data_all.Age <= 30))
xlabel('F1');
ylabel('Emu bias')
title('<=30');
lsline;
% middle
subplot(1,3,2)
hold on
scatter(data_all.SRS_F1(find((data_all.Age >30) .* (data_all.Age <= 40))), data_all.IntDyn_hbi_bias(find((data_all.Age >30) .* (data_all.Age <= 40))));
xlabel('F1');
ylabel('Emu bias')
title('>30, <=40');
lsline;
% old
subplot(1,3,3)
hold on
scatter(data_all.SRS_F1(data_all.Age >40), data_all.IntDyn_hbi_bias(data_all.Age >40));
xlabel('F1');
ylabel('Emu bias')
title('>40');
lsline;

disp(['r in young =',num2str(r_young),'p = ',num2str(p_young)]);
disp(['r in middle =',num2str(r_middle),'p = ',num2str(p_middle)]);
disp(['r in old =',num2str(r_old),'p = ',num2str(p_old)]);

%% check the IQ (mbmf_perf), Age, Gender across 4 clustering groups
[ol_grp,grp_count,iq_mean,iq_std] = grpstats(data_all.MBMF_score,data_all.cluster_group,["gname","numel","mean","sem"]); % SRS total, hbi
[ol_grp,grp_count,age_mean,age_std] = grpstats(data_all.Age,data_all.cluster_group,["gname","numel","mean","sem"]); % SRS total, hbi
[ol_grp,grp_count,sex_mean,sex_std] = grpstats(gender_conv,data_all.cluster_group,["gname","numel","mean","sem"]); % SRS total, hbi

% Plot MBMF score
figure;
hold on
b1 = bar([1:4],iq_mean);
errorbar([1:4],iq_mean, iq_std);
xticks([1:4]);
xticklabels(ol_grp);
ylabel('MBMF score');
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


