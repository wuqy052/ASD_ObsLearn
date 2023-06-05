% summary stats about the SRS questionnaire
% and association between SRS & OL task
% factor analysis done in R
% original data
%% load SRS raw data
% SRS total score + subscale score
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/SRS_data_20210922.mat');
% load final subject list
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/sublist_original.mat');
[~,~,srsid] = intersect(sublist,srsdata.final.subid);
srsraw_final = cell2mat(srsdata.final.alldata(srsid,:));

%% descriptive stats & visualisation
% total score
figure;
histogram(srsraw_final(:,1),'FaceColor',[239/256,164/256,245/256]); 
xline(mean(srsraw_final(:,1)),'Color',[232/256,54/256,74/256],'LineWidth',1);
ylim([0,140]);
ylabel('Count');
xlabel('SRS total score');
title({'Distribution of SRS total','original'});
disp(['Mean =',num2str(mean(srsraw_final(:,1)))]);
disp(['STD =', num2str(std(srsraw_final(:,1)))]);

% subscales
figure('Renderer', 'painters', 'Position', [0 0 600 450]);
hm = heatmap(corr(srsraw_final(:,2:6)),'YData',["MOT","AWR","RRP","COG","COM"], 'XData', ["MOT","AWR","RRP","COG","COM"],'ColorLimits',[0 1]);
hm.CellLabelFormat = '%.3g';
caxis([0 1]);
J = customcolormap([0 1], {'#e66aac','#ffffff'});
colorbar; 
colormap(J);
%title({'Correlation among subscales',"Discovery sample"});

%% load factor score
SRS_factors = readtable('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/factor_analysis/SRS_fa_score_8_factor_promax_original.csv');

% the order of subID in the FA score data is different from that in the
% final list
% align with the final list
[~,~,faid] = intersect(sublist,SRS_factors.subIDs_inc);
factors_final = SRS_factors(faid,:);
factors_final.subIDs_inc = [];

figure('Renderer', 'painters', 'Position', [0 0 600 450]);
hm = heatmap(round(corr(table2array(factors_final)),3),'YData',["F1","F2","F3","F4","F5","F6","F7","F8"], 'XData',["F1","F2","F3","F4","F5","F6","F7","F8"],'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm.CellLabelFormat = '%.3g';
J = customcolormap([0 0.5 1], {'#e66aac','#ffffff','#78db76'});
colorbar; 
colormap(J);


%% F1 is correlated with SRS total
figure;
scatter(srsraw_final(:,1), factors_final.Factor1,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[239/256,164/256,245/256]); 
xlabel('SRS total score');
ylabel('F1 score');
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
[r.fa,p.fa] = corr(srsraw_final(:,1), factors_final.Factor1);

%% 1.1 Model free analysis - accuracy/emulation prop/RT ~ ASD score
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/model_free_analysis/model_free_analyses_original.mat');
[~,~,mfid] = intersect(sublist,allID);

% Model-free measurement data structure
MF = struct();
MF.ACC_all = Accuracy(mfid,1);
MF.EM_prop_all = EM_prop(mfid,1);
MF.RT_all = RT(mfid,1);

% Accuracy ~ ASD level
% SRS total
% figure;
% scatter(srsraw_final(:,1),MF.ACC_all,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
% ll = lsline;
% ll.LineWidth = 1;
% ll.Color = [255/256,102/256,109/256];
% xlabel('SRS total score');
% ylabel('OL Accuracy');
% title({'OL task accuracy ~ ASD level','orignal'});
% [r.acc_srs,p.acc_srs] = corr(srsraw_final(:,1),MF.ACC_all);
% disp(['r=',num2str(r.acc_srs)]);
% disp(['p=',num2str(p.acc_srs)]);
% SRS F1
figure;
scatter(factors_final.Factor1,MF.ACC_all,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
xlabel('F1 score');
ylabel('OL Accuracy');
title({'OL task accuracy ~ ASD level','orignal'});
[r.acc_f1,p.acc_f1] = corr(factors_final.Factor1,MF.ACC_all);
disp(['r=',num2str(r.acc_f1)]);
disp(['p=',num2str(p.acc_f1)]);
   
% Emulation propensity ~ ASD level
% SRS total
% figure;
% scatter(srsraw_final(:,1),MF.EM_prop_all,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
% ll = lsline;
% ll.LineWidth = 1;
% ll.Color = [255/256,102/256,109/256];
% xlabel('SRS total score');
% ylabel('Emulation Propensity');
% title({'OL emulation propensity ~ ASD level','orignal'});
% [r.emu_srs,p.emu_srs] = corr(srsraw_final(:,1),MF.EM_prop_all);
% disp(['r=',num2str(r.emu_srs)]);
% disp(['p=',num2str(p.emu_srs)]);
% SRS F1
figure;
scatter(factors_final.Factor1,MF.EM_prop_all,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
xlabel('F1 score');
ylabel('Emulation Propensity');
title({'OL emulation propensity ~ ASD level','orignal'});
[r.emu_f1,p.emu_f1] = corr(factors_final.Factor1,MF.EM_prop_all);
disp(['r=',num2str(r.emu_f1)]);
disp(['p=',num2str(p.emu_f1)]);

% RT ~ ASD level
% SRS total
% figure;
% scatter(srsraw_final(:,1),MF.RT_all,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
% ll = lsline;
% ll.LineWidth = 1;
% ll.Color = [255/256,102/256,109/256];
% xlabel('SRS total score');
% ylabel('OL Reaction Time');
% title({'OL RT ~ ASD level','orignal'});
% [r.rt_srs,p.rt_srs] = corr(srsraw_final(:,1),MF.RT_all);
% disp(['r=',num2str(r.rt_srs)]);
% disp(['p=',num2str(p.rt_srs)]);
% SRS F1
figure;
scatter(factors_final.Factor1,MF.RT_all,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
xlabel('F1 score');
ylabel('OL Reaction Time');
title({'OL RT ~ ASD level','orignal'});
[r.rt_f1,p.rt_f1] = corr(factors_final.Factor1,MF.RT_all);
disp(['r=',num2str(r.rt_f1)]);
disp(['p=',num2str(p.rt_f1)]);

%% 1.2 Model free analysis - accuracy/emulation prop ~ ASD median split
% SRS total
med_SRS = median(srsraw_final(:,1));
SRS_group = srsraw_final(:,1) > med_SRS; % 0 = control; 1 = more asd
% F1
med_F1 = median(factors_final.Factor1);
F1_group = factors_final.Factor1 > med_F1; % 0 = control; 1 = more asd
% MF measures
MF.ACC_lu_hu = Accuracy(mfid,2:3);
MF.EM_prop_lu_hu = EM_prop(mfid,2:3);
MF.ACC_switch = Acc_switch(mfid,:);
% calculate stats
[grp.srs_acc_mean,grp.srs_acc_se] = grpstats(MF.ACC_lu_hu,SRS_group,["mean","sem"]); % SRS total, hbi
[grp.srs_emu_mean,grp.srs_emu_se] = grpstats(MF.EM_prop_lu_hu,SRS_group,["mean","sem"]); % SRS total, nonhbi
[grp.srs_switch_mean,grp.srs_switch_se] = grpstats(Acc_switch(mfid,:),SRS_group,["mean","sem"]); % SRS total, hbi
[grp.f1_acc_mean,grp.f1_acc_se] = grpstats(MF.ACC_lu_hu,F1_group,["mean","sem"]); % F1, hbi
[grp.f1_emu_mean,grp.f1_emu_se] = grpstats(MF.EM_prop_lu_hu,F1_group,["mean","sem"]); % F1, nonhbi
[grp.f1_switch_mean,grp.f1_switch_se] = grpstats(Acc_switch(mfid,:),F1_group,["mean","sem"]); % SRS total, hbi

% make plots
% Accuracy low/high uncertainty ~ SRS
figure;
hold on
b1 = bar([1:2],grp.srs_acc_mean');
b1(1).FaceColor = [144/256 209/256 112/256];
b1(2).FaceColor = [209/256 112/256 190/256];
errorbar([0.85,1.15,1.85,2.15],reshape(grp.srs_acc_mean,4,1),reshape(grp.srs_acc_se,4,1));
legend({'Low SRS','High SRS'});
xticks([1:2]);
xticklabels({'Low Uncertainty','High Uncertainty'});
ylabel('Accuracy');
ylim([0,1]);
title({'Accuracy changes by uncertainty','SRS - original'});
% Accuracy low/high uncertainty ~ F1
figure;
hold on
b2 = bar([1:2],grp.f1_acc_mean');
b2(1).FaceColor = [144/256 209/256 112/256];
b2(2).FaceColor = [209/256 112/256 190/256];
errorbar([0.85,1.15,1.85,2.15],reshape(grp.f1_acc_mean,4,1),reshape(grp.f1_acc_se,4,1));
legend({'Low F1','High F1'});
xticks([1:2]);
xticklabels({'Low Uncertainty','High Uncertainty'});
ylabel('Accuracy');
ylim([0,1]);
title({'Accuracy changes by uncertainty','F1 - original'});

% Emulation propensity - low/high uncertainty ~ SRS
figure;
hold on
b1 = bar([1:2],grp.srs_emu_mean');
b1(1).FaceColor = [144/256 209/256 112/256];
b1(2).FaceColor = [209/256 112/256 190/256];
errorbar([0.85,1.15,1.85,2.15],reshape(grp.srs_emu_mean,4,1),reshape(grp.srs_emu_se,4,1));
legend({'Low SRS','High SRS'});
xticks([1:2]);
xticklabels({'Low Uncertainty','High Uncertainty'});
ylabel('Emulation propensity');
ylim([0,1]);
title({'Emulation propensity changes by uncertainty','SRS - original'});
% Emulation low/high uncertainty ~ F1
figure;
hold on
b4 = bar([1:2],grp.f1_emu_mean');
b4(1).FaceColor = [144/256 209/256 112/256];
b4(2).FaceColor = [209/256 112/256 190/256];
errorbar([0.85,1.15,1.85,2.15],reshape(grp.f1_emu_mean,4,1),reshape(grp.f1_emu_se,4,1));
legend({'Low F1','High F1'});
xticks([1:2]);
xticklabels({'Low Uncertainty','High Uncertainty'});
ylabel('Emulation propensity');
ylim([0,1]);
title({'Emulation propensity changes by uncertainty','F1 - original'});

% Accuracy - switch ~ SRS
figure;
hold on
b5 = bar([1:2],grp.srs_switch_mean');
b5(1).FaceColor = [144/256 209/256 112/256];
b5(2).FaceColor = [209/256 112/256 190/256];
errorbar([0.85,1.15,1.85,2.15],reshape(grp.srs_switch_mean,4,1),reshape(grp.srs_switch_se,4,1));
legend({'Low SRS','High SRS'});
xticks([1:2]);
xticklabels({'After switch','No switch'});
ylabel('Accuracy');
ylim([0,1]);
title({'Accuracy changes by switch','SRS - original'});
% Accuracy - switch ~ F1
figure;
hold on
b6 = bar([1:2],grp.f1_switch_mean');
b6(1).FaceColor = [144/256 209/256 112/256];
b6(2).FaceColor = [209/256 112/256 190/256];
errorbar([0.85,1.15,1.85,2.15],reshape(grp.f1_switch_mean,4,1),reshape(grp.f1_switch_se,4,1));
legend({'Low F1','High F1'});
xticks([1:2]);
xticklabels({'After switch','No switch'});
ylabel('Accuracy');
ylim([0,1]);
title({'Accuracy changes by switch','F1 - original'});

% calculate on the continuous scale
[r.accunc_f1,p.accunc_f1] = corr(factors_final.Factor1, MF.ACC_lu_hu(:,1) - MF.ACC_lu_hu(:,2));
[r.emuunc_f1,p.emuunc_f1] = corr(factors_final.Factor1, MF.EM_prop_lu_hu(:,1) - MF.EM_prop_lu_hu(:,2));
[r.accswi_f1,p.accswi_f1] = corr(factors_final.Factor1, MF.ACC_switch(:,1) - MF.ACC_switch(:,2));
[rho,pval] = partialcorr([factors_final.Factor1, MF.ACC_switch(:,1) - MF.ACC_switch(:,2)],MF.ACC_all);

% 2-way anova with interaction
stats.anova2_accunc_f1 = anovan([MF.ACC_lu_hu(:,1);MF.ACC_lu_hu(:,2)],...
    {[ones(887,1);repmat(2,887,1)],[F1_group;F1_group]},...
    'model','interaction','varnames',{'Uncertainty','ASD(F1)'});
stats.anova2_emuunc_f1 = anovan([MF.EM_prop_lu_hu(:,1);MF.EM_prop_lu_hu(:,2)],...
    {[ones(887,1);repmat(2,887,1)],[F1_group;F1_group]},...
    'model','interaction','varnames',{'Uncertainty','ASD(F1)'});
stats.anova2_accswi_f1 = anovan([MF.ACC_switch(:,1);MF.ACC_switch(:,2)],...
    {[ones(887,1);repmat(2,887,1)],[F1_group;F1_group]},...
    'model','interaction','varnames',{'Switch','ASD(F1)'});

%% 1.3 Model free analysis - glm effect
% mixed GLM, with intercept + partnerAct + tokenInf for fixed and random
% effects 
% fixed + random effects
glme_effects = GLME1.Reffects;

% Correlation between coefficients and F1 
% 1. Intercept
figure;
scatter(factors_final.Factor1,glme_effects.Intercept,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
xlabel('F1 score');
ylabel('Intercept');
title({'Choice bias ~ ASD level','orignal'});
[r.intercept_f1,p.intercept_f1] = corr(factors_final.Factor1,glme_effects.Intercept);
disp(['r=',num2str(r.intercept_f1)]);
disp(['p=',num2str(p.intercept_f1)]);

% 2. Imitation
figure;
scatter(factors_final.Factor1,glme_effects.partnerAct,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
xlabel('F1 score');
ylabel('Beta of Partner Action');
title({'Imitation effect ~ ASD level','orignal'});
[r.partner_f1,p.partner_f1] = corr(factors_final.Factor1,glme_effects.partnerAct);
disp(['r=',num2str(r.partner_f1)]);
disp(['p=',num2str(p.partner_f1)]);

% 2. Emulation
figure;
scatter(factors_final.Factor1,glme_effects.tokenInf,'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
xlabel('F1 score');
ylabel('Beta of Inferred token');
title({'Emulation effect ~ ASD level','orignal'});
[r.token_f1,p.token_f1] = corr(factors_final.Factor1,glme_effects.tokenInf);
disp(['r=',num2str(r.token_f1)]);
disp(['p=',num2str(p.token_f1)]);

% Run a regression: F1 ~ intercept + imitation + emulation
mdl_glme_f1 = fitlm(table2array(glme_effects(:,3:4)),factors_final.Factor1);

%% 2.1 Model based analysis - subject classification ~ ASD score
% load data
% model fitting, no need to reorder, already match the sublist order
res_hbi = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/hbi_5mods_original.mat');
res_nonhbi = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/5models_recap_original.mat');

% grouping
OL_groups_nonhbi = res_nonhbi.fitRecap.best_model(:,3); % nonhbi, AIC
% hbi, responsibility
for s = 1:length(res_hbi.cbm.output.responsibility)
    OL_groups_hbi(s,1) = find(res_hbi.cbm.output.responsibility(s,:)==max(res_hbi.cbm.output.responsibility(s,:)));
end

% calculate stats
[grp.hbi_srs_mean,grp.hbi_srs_se] = grpstats(srsraw_final(:,1),OL_groups_hbi,["mean","sem"]); % SRS total, hbi
[grp.nonhbi_srs_mean,grp.nonhbi_srs_se] = grpstats(srsraw_final(:,1),OL_groups_nonhbi,["mean","sem"]); % SRS total, nonhbi
[grp.hbi_f1_mean,grp.hbi_f1_se] = grpstats(factors_final.Factor1,OL_groups_hbi,["mean","sem"]); % F1, hbi
[grp.nonhbi_f1_mean,grp.nonhbi_f1_se] = grpstats(factors_final.Factor1,OL_groups_nonhbi,["mean","sem"]); % F1, nonhbi

% plots
% hbi - SRS total
figure;
hold on
bar([1:5],grp.hbi_srs_mean,'FaceColor',[153/256,220/256,196/256]);
errorbar([1:5],grp.hbi_srs_mean,grp.hbi_srs_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('SRS total');
title({'SRS ~ best-fitting model','hbi - original'});
xtickangle(45);
% nonhbi - SRS total
figure;
hold on
bar([1:5],grp.nonhbi_srs_mean,'FaceColor',[255/256,195/256,102/256]);
errorbar([1:5],grp.nonhbi_srs_mean,grp.nonhbi_srs_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('SRS total');
title({'SRS ~ best-fitting model','nonhbi - original'});
xtickangle(45);
% hbi - F1
figure;
hold on
bar([1:5],grp.hbi_f1_mean,'FaceColor',[153/256,220/256,196/256]);
errorbar([1:5],grp.hbi_f1_mean,grp.hbi_f1_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('F1 score');
title({'F1 ~ best-fitting model','hbi - original'});
xtickangle(45);
% nonhbi - SRS total
figure;
hold on
bar([1:5],grp.nonhbi_f1_mean,'FaceColor',[255/256,195/256,102/256]);
errorbar([1:5],grp.nonhbi_f1_mean,grp.nonhbi_f1_se);
xticks([1:5]);
xticklabels( {'Baseline','Imitation','Emulaiton','FixArb','DynArb'});
ylabel('F1 score');
title({'F1 ~ best-fitting model','nonhbi - original'});
xtickangle(45);

[statstable.hbi_f1_anova.p, statstable.hbi_f1_anova.anovatab, statstable.hbi_f1_anova.stats] = anova1(factors_final.Factor1,OL_groups_hbi);
%[statstable.nonhbi_acc_anova.p, statstable.nonhbi_acc_anova.anovatab, statstable.nonhbi_acc_anova.stats] = anova1(Accuracy(incl,1),OL_groups_nonhbi);
%[statstable.hbi_emu_anova.p, statstable.hbi_emu_anova.anovatab, statstable.hbi_emu_anova.stats] = anova1(EM_prop(incl,1),OL_groups_hbi);
%[statstable.nonhbi_emu_anova.p, statstable.nonhbi_emu_anova.anovatab, statstable.nonhbi_emu_anova.stats] = anova1(EM_prop(incl,1),OL_groups_nonhbi);

%% 2.2 Model based analysis - integrated model parameter ~ ASD score
% load data
% model fitting, no need to reorder, already match the sublist order
IntDyn.mdl = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/hbi_IntDyn_original.mat');
IntDyn.params = IntDyn.mdl.cbm.output.parameters{1,1};

% correlation among parameters
param_name = ["beta" "eta" "bias" "hand" "col1" "col2" "stickact" "stickch"];
figure;
hm_param = heatmap(corr(IntDyn.params),'XData', param_name, 'YData', param_name,'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm_param.CellLabelFormat = '%.3f';
title({'Correlation among parameters','hbi - original'});

% correlation between model parameter and ASD measure
srs_name = ["total" "mot" "awr" "rrb" "cog" "com"];
% heatmap - SRS total
[r.mdl_srs,p.mdl_srs] = corr([srsraw_final,IntDyn.params]);
% horizontal - srs scales; vertical - parameters
figure;
hm_mdl_srs = heatmap(r.mdl_srs(7:14,1:6),'YData', param_name, 'XData', srs_name,'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm_mdl_srs.CellLabelFormat = '%.3f';
title({'Correlation between OL parameters & SRS scales','hbi - original'});
% heatmap - Factors
fa_name = ["F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8"];
[r.mdl_fa,p.mdl_fa] = corr([table2array(factors_final),IntDyn.params]);
% horizontal - srs scales; vertical - parameters
figure;
hm_mdl_fa = heatmap(r.mdl_fa(9:16,1:8),'YData', param_name, 'XData', fa_name,'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm_mdl_fa.CellLabelFormat = '%.3f';
title({'Correlation between OL parameters & SRS Factors','hbi - original'});

% only F1 ~ bias
figure;
scatter(factors_final.Factor1,IntDyn.params(:,3),'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
ylabel('OL bias');
xlabel('F1 score');
title({'OL emulation bias ~ ASD level','hbi - orignal'});
disp(['r=',num2str(r.mdl_fa(1,11))]);
disp(['p=',num2str(p.mdl_fa(1,11))]);

%% 2.3 Model based analysis - fix integrated model parameter ~ ASD score
% load data
% model fitting, no need to reorder, already match the sublist order
IntFix.mdl = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/hbi_intfix_original.mat');
IntFix.params = IntFix.mdl.cbm.output.parameters{1,1};
% correlation among parameters
param_name = ["beta" "weight" "hand" "col1" "col2" "stickact" "stickch"];
figure;
hm_param = heatmap(corr(IntFix.params),'XData', param_name, 'YData', param_name,'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm_param.CellLabelFormat = '%.3f';
title({'Correlation among parameters','hbi - original'});

% correlation between model parameter and ASD measure
srs_name = ["total" "mot" "awr" "rrb" "cog" "com"];
% heatmap - SRS total
[r.mdl_srs,p.mdl_srs] = corr([srsraw_final,IntFix.params]);
% horizontal - srs scales; vertical - parameters
figure;
hm_mdl_srs = heatmap(r.mdl_srs(7:13,1:6),'YData', param_name, 'XData', srs_name,'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm_mdl_srs.CellLabelFormat = '%.3f';
title({'Correlation between OL parameters & SRS scales','hbi - original'});
% heatmap - Factors
fa_name = ["F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8"];
[r.mdl_fa,p.mdl_fa] = corr([table2array(factors_final),IntFix.params]);
% horizontal - srs scales; vertical - parameters
figure;
hm_mdl_fa = heatmap(r.mdl_fa(9:15,1:8),'YData', param_name, 'XData', fa_name,'ColorLimits',[-1 1],'Colormap',redbluecmap);
hm_mdl_fa.CellLabelFormat = '%.3f';
title({'Correlation between OL parameters & SRS Factors','hbi - original'});

% only F1 ~ weight
figure;
scatter(factors_final.Factor1,IntFix.params(:,2),'filled','MarkerFaceAlpha',0.5,'MarkerFaceColor',[102/256,153/256,255/256]);
ll = lsline;
ll.LineWidth = 1;
ll.Color = [255/256,102/256,109/256];
ylabel('OL weight');
xlabel('F1 score');
title({'OL arbitration weithg ~ ASD level','hbi - orignal'});
disp(['r=',num2str(r.mdl_fa(1,10))]);
disp(['p=',num2str(p.mdl_fa(1,10))]);


%% 2.4 Model based analysis - clustering dimensions ~ ASD score
% clustering dimensions are variables used for subject clustering
% including: 1) R2_baseline 2) R2_imitation 3) R2_emulation
% 4) R2_fixarb - R2_bestsingle 5) R2_dyn - R2_fixarb 6) eta/abs_eta
% import data
intdata = load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/lap_Integrated_expbeta_original.mat');
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/5models_recap_original.mat');
fitcriteria = fitRecap.pseudoR2;
varnames = {'R_2Baseline','R_2Imitation','R_2Emulation','R_2Fix-bestSin','R_2Dyn-Fix','eta','abs eta'};

% select a set of parameters
clustervars = table;
clustervars.R2_Baseline = fitcriteria(:,1);
clustervars.R2_Imitation = fitcriteria(:,2);
clustervars.R2_Emulation = fitcriteria(:,3);
clustervars.R2_fix_bestSin = fitcriteria(:,4) - max(fitcriteria(:,2:3)')';
clustervars.R2_dyn_fix = fitcriteria(:,5) - fitcriteria(:,4);
clustervars.eta = intdata.cbm.output.parameters(:,2);
clustervars.abseta = abs(intdata.cbm.output.parameters(:,2));

% calculate correlations
fa_name = ["F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8"];
[r.clust_fa,p.clust_fa] = corr([table2array(factors_final),table2array(clustervars)]);
figure;
heatmap(r.clust_fa(9:15,1:8),'XData', fa_name, 'YData', varnames,...
    'ColorLimits',[-1 1],'Colormap',redbluecmap,'CellLabelFormat','%.3f');
title({'Correlation between clustering variables and F scores','original'});

%% 2.5 Model based analysis - dynamic arbitration weight change ~ F1
% load OL task data
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/data/data_original.mat');
% load parameter fitting 
load('/Users/wuqy0214/Library/CloudStorage/Box-Box/OL_shared/analysis/modelling/original_data/lap_ArbF_AV_expbeta_original.mat');
% calculate the dynamic weight
for sub=1:length(data_original)
    [~,vals] = LL_ArbF_AV_expbeta(cbm.output.parameters(sub,:),data_original{sub}); % weight is the last column
    w_fluc(:,sub) = vals(:,end);
end

% F1
med_F1 = median(factors_final.Factor1);
F1_group = factors_final.Factor1 > med_F1; % 0 = control; 1 = more asd
figure;
hold on
errorbar(mean(w_fluc(:,find(F1_group==1)),2),std(w_fluc(:,find(F1_group==1)),[],2)/sqrt(444),'CapSize',1);
errorbar(mean(w_fluc(:,find(F1_group==0)),2),std(w_fluc(:,find(F1_group==1)),[],2)/sqrt(443),'CapSize',1);
legend({'High F1','Low F1'});
xlabel('Trial');
ylabel('DynArb Weight');